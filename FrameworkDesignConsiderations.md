# Framework Design Considerations

The framework will have to work efficiently on many/multi core systems.
Presumably, this will imply some level of concurrency. As a result, scheduling
operations to be performed on the data will become more dynamic, and much
more complex than our current serial case, where `Algorithm`s are statically
scheduled, and the only dynamic aspects are the early abort of certain branches 
of the graph of `Algorithm`s, and the skipping of `Algorithm`s that have already 
executed for the current event.

As concurrent programming is non-trivial, the concurrency aspects should be hidden 
as much as feasible from the implementation of the reconstruction and selection code,
as these will be dominantly implemented by those who should not have to deal with 
the implementation details of the concurrency. A total isolation will most likely
not be feasible, so guidelines should be formulated that will allow developers to write
'concurrency friendly' code, i.e. code that does not misbehave when exectued as part 
of a concurrent system.

To enable concurrency, the first hurdle seems to be the description of data dependencies
amongst Algorithms. One option could be to add sufficient introspection to `Algorithm`s,
and thus allow the framework to deduce the input(s) and output(s) of each `Algorithm`. This
could eg. be done by requiring all interactions with the global whiteboard, the transient
event store, or `TES` to be done through an API which
enforces the use of dedicated Properties which specify `TES` locations and the type of 
access (read, write, or update). (note: update should be forbidden).

An alternative approach would be to recognize that most (all?) Algorithms actually 
follow a very similar pattern: read data from the `TES`, then transform this to new data, 
and then make this data available once again in the `TES`. As such, one could consider 
writing one single generic algorithm which wraps this functionality (and thus provides 
a uniform pattern), and delegate the actual computational work. This suggests a new type 
of `Gaudi` component, which is explictly provided with its input data, and explicitly provides 
output data. Let us define this as a `Transform`. 
Note that there is no direct, explicit interaction between these `Transform` components 
and the `TES` -- this has been moved to higher level of abstraction. This is also consistent
with eg. the current HLT and Stripping use case, where the input location in the TES used
by a given `Algorithm`s, at the level of `Configurable`s is typically specied as the output 
location of another `Algorithm`.


Note that one can further more imagine that
these `Transform`s work on vectors of input, and provide vectors of output, allowing them to eg.
work on input from multiple events in a single invocation.


# Operations

In addtion to `Transform` there is at least one more operation required: reduction.
A prime example of reduction is `std::accumulate`. It operates on a vector of values,
and produces a single scalar result. An example of such a reduction is summation.
This operation is eg. needed to combine a list of Hlt decisions into one global decision -- in 
this case the binary operation used to combine two results is logical `OR`, and the initial 
value is `false`. Note that in this case the result is independent of the order in which one
iterates over the input vector. But that is not always the case.
Let us call the corresponding algorithm `Accumulator`. 

(note: N4505, 4.2 calls this 'generalized sum', and provides a commutative and a non-commutative version;
Stepanov correctly maps this operation to the concept of 'semi-ring', see e.g. https://en.wikipedia.org/wiki/Semiring,
structures with two binary operations, called 'addition' and 'multiplication' but note that these names are
more generic than the addition and mulitplication of numbers)



# More operations

In general we expect that the processing can be described by a directed, acyclic graph, through
which data flows. However, it is not always needed that the data flows through the entire graph.
In the trigger, where most data is rejected, one does not need all derived data to come to the 
conclusion that an event is not interesting. As a result, we need a means of short circuiting 
further processing.


# Concurrency Friendly
In the above, we outlined that code should be written in a 'concurrency friendly' style.
Here we detail what this entails:

* no statics.
* const interface.
* NEVER modify input data
* ...
