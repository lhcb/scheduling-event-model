# Design Considerations

The framework will have to work efficiently on many/multi core systems.
Presumably, this will imply some level of concurrency. As a result, scheduling
operations to be performed on the data will become more dynamic, and much
more complex then our current serial case, where 'Algorithm's are statically
scheduled, and the only dynamic aspects are the early abort of certain branches 
of the graph of algorithms, and the skipping of Algorithms that have already 
executed for the current event.

As concurrent programming is non-trivial, the concurrency aspects should be hidden 
as much as feasible from the implementation of the reconstruction and selection code,
as these will be dominantly implemented by those who should not have to deal with 
the implementation details of the concurrency. A total isolation will most likely
not be feasible, so guidelines should be formulated that will allow developers to write
'concurrency friendly' code, i.e. code that does not misbehave in a concurrent system.

To enable concurrency, the first hurdle seems to be the description of data dependencies
amongst Algorithms. One option could be to add sufficient introspection to Algorithms,
and thus allow the framework to deduce the input(s) and output(s) of each Algorithm. This
could eg. be done by requiring all interaction with the TES to be done through an API which
enforces the use of dedicated Properties which specify TES locations and the type of 
access (read, write, or update). (note: update should be forbidden).

An alternative approach would be to recognize that most (all?) Algorithms actually 
follow the same pattern: read data and then transform it new data, and then make this
data available in the TES. As such, one could consider writing one single generic algorithm
which wraps this functionality (and thus provides a uniform pattern), and delegate the
computational work. This suggests a new type of Gaudi component, which is explictly provided
with input data, and explicitly provides output data -- lets define this as a Transform.. 
Note that there is no direct interaction between these Transform components and the TES -- this
has been moved to higher level of abstraction. Note that one can further more imagine that
these Transforms work on vectors of input, and provide vectors of output, allowing them to eg.
work on input from multiple events in a single invocation.






