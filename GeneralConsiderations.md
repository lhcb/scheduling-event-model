# General considerations

## Mode of operation

In any processing chain, there are essentially two modes of operation that a
framework can support:

1. pull operation: the framework pulls out results from the end of the chain
   (think of putting a pump at the end of of some chain of pipes)
2. push operation: the framework pushes in the input data into the beginning of
   the processing chain, and things start to flow from there

In our use case, we have to rely on the push mode, since the input (events)
trickle in at a fixed rate, and we have multiple outputs (various "streams"
that get written to different files) for which we do not know a priori which
events will end up in which output, or even whether they will be accepted in 
the first place (so "pulling" at the end is not easily possible).

## Types of concurrency

Having established why we need to work by pushing events into the input of our
processing chain, it becomes important to think about how this chain is best
constructed, and how to exploit concurrency. First, we have to distinguish the
typical use cases that are expected to occur:

1. Algorithms (in the Gaudi sense) with well-defined inputs and outputs on the
   TES; several of these can execute in parallel if there are no
   data-dependencies.
2. Embarrasingly parallel compute kernels (EBCK): these are typically building
   blocks of tools or algorithms that take some input data, transform it in
   some way, and return the result to the caller; for example vectorised
   fitting of tracks, potentially on some kind of accelerator card (GPU, FPGA,
   or similar...). EBCKs are usually a building block of algorithms.

## Communication mechanism among concurrent threads of execution

To facilitate the job of the programmer (and the poor souls who have to debug a
piece of code later on), concurrently executing code should communicate via
message passing, if at all possible, not sharing data by default (constant
immutable data can be an exception to this rule). Here, I am thinking of the
default threading model in the D programming language (see e.g. A.
Alexandrescu's book on the subject). Most people experienced with (debugging
of) multi-threaded programs tend to come up with a similar design anyway,
unless the task at hand has very special requirements (and merits the increased
time in writing the code and debugging it).

In this model, different threads (or whatever other technology is used to
achieve concurrency) do share the same address space, but it is a breach of
good practice to expose mutable data to more than one thread (it would be nice
to enforce this at the language level as D does - to be seen if this is
feasible). If objects need to be passed around from one thread to another, this
should be done by sending a message with an object handle (a message with a
std::unique_ptr or something similar comes to mind). That way, data corruption
due to different threads writing to the same data structure at the same time is
avoided. Sending object handles (except for small objects) keeps the
communication overhead low, since only tiny amounts of data actually have to
pass through the pipe.

At the same time, if a thread is waiting for more than one resource or message,
some kind of arbitration should be built into the framework such that no
deadlocks occur (see e.g. D's synchronized clause which acquires mutexes in a
defined order on all threads, so that different threads cannot block each
other).

Interface-wise, it would be nice if the message passing could be implemented
using (bidirectional) pipes (and potentially named pipes, or sockets) as a
model at the lowest level, since they are fairly easy to reason about. Clearly,
more complex primitives can be built based on these primitives. (It should be
understood that I'm only borrowing the terminology of good operating systems
here, the actual primitves can be implemented in a very different way in the
framework.)

Unnamed pipes work well in the situation where an algorithm spawns multiple
worker threads to treat some problem; each thread can then read its input from
its end of the pipe, and write back the result once it's done. The parent
should block on reads from a pipe which does not have data to be read. Some
kind of poll(2) functionality to wait on a set of pipes would also be useful
(e.g. waiting for the first worker to return the result). Poll should block
until one of the polled pipes becomes available, or until a timeout expires,
just as the poll syscall does, to avoid taking CPU from other threads while
busy-waiting on the pipes. See the BidirMMapPipe class in RooFit where this
kind of idea is used for IPC between a parent process and its children, the
worker processes.

Named pipes (or sockets) should work well when there is some kind of "service"
to communicate with that has no direct relation to the algorithm itself, for
example an EPCK which does parts of the pattern reco or track fit very
efficiently on large vectors of input data.

These pipes should have some kind of mailbox mechanism to queue messages until
consumption. For named pipes, this also permits the scenario in which one
master process keeps queuing up work packets in a tight loop, and multiple
worker threads consume them from the same named pipe, each unqueuing one
message from the mailbox. In any case, message delivery should be guaranteed by
blocking the sending process until space for the new message is available.


## Embarrasingly Parallel Compute Kernels (EPCK) and Event Batching

In many applications, it is beneficial to process data in vectorised form,
since the operation(s) performed on the data elemets are the same. To this end,
modern CPUs feature vector-units, and GPUs and FPGAs allow even more parallel
processing that is feasible on a CPU. Naturally, LHCb wants to tap into the
power of these technologies for the Upgrade, and several prototype studies have
been and are being performed by members of the collaboration.

A result of these studies has been that one would like to batch data from
multiple events (up to O(500) events depending on the problem) to give these
massively parallel compute elements enough data that the communication time
with the compute element is amortised (e.g. copying data and compute kernel to
a GPU, initialise the hardware, perform the computation, and ship back the
results to the CPU).

Even vectorised code for CPUs may require some "preprocessing" and
"postprocessing" of data, e.g. to adapt memory layout; having a large body of
input data helps to hide the cost to such processing.

While it is not completely clear how this will be implemented in the framework,
it seems evident that we need some kind of processing model with multiple
events "in flight", so that the latencies of such pre- and post-processing can
be "hidden" by sharing the cost among many events in flight.

## Interaction with the Transient Event Store

The Transient Event Store (TES) is a kind of global variable, and will
therefore need to be protected from race conditions in a multi-threaded
program. If updates to the TES could be implemented by some back-end service
which communicates with user code via message passing (as described above),
most race conditions could be avoided.

Moreover, such a model lends itself naturally to event batching as described in
the last paragraph; the underlying service keeps one TES for each event, and
returns the appropriate one for each algorithm (or thread of an algorithm
launched to process a given event).

It also has advantages in terms of scheduling, since message passing can block
until the input data is available. That would allow the framework (or OS, in
case of OS-level threads) to take care of all scheduling, and data dependencies
among algorithms are resolved automatically because the algorithms will block
until their input is available.

Such a mode of concurrent operation does imply that the data on the TES has to
be immutable once it has been put there - otherwise algorihms may see outdated
versions of objects on the TES.

## Implications for Gaudi's Tools and Algorithms

In a concurrent running scenario, Tools and Algorithms must use state
sparingly. Immutable state is fine, but state that changes within an event, or
from event to event will need to be protected from concurrent access, and
therefore limit the parallelisation opportunities.

Special care must be taken with counter-like data like counters, histograms and
ntuples. Again, these services should be implemented in services that talk to
the tools and algorithms using message passing. That way, the most frequent
type of message (increment counter, fill histogram, fill tuple) can be queued
in the pipe's mailbox without blocking the time-sensitive part of the
algorithm. Obviosuly, care must be taken that these services are given enough
priority to avoid the calling tools or algorithms blocking on a full mailbox.





