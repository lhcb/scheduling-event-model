# Syntax Proposal for Control Flow Structures

Currently the control flow of Gaudi applications is implemented by chaining various GaudiSequencer algorithms, that implement the logic internally.

With the move to parallel applications, the handling of control flow cannot happen in this implicit way any more. This opens as well the possibility to  go for a more intuitive way of declaring the control flow in Gaudi.

The proposal is to define the control flow via operator-syntax in Python. The created operator tree is then passed to Gaudi for building up the internal structures in C++.

## Simple constructs

### AND and OR
The simple
operations like 'and' and 'or' are mapped to '&' and '|'.

    someDecision = filter1 & filter2 | filter3

### Negation
Negation is denoted by "~":

    someDecision = ~filter1

## Composition - sequences and paths
Control flow constructs can be composed. Either implicitly:

    seq1 = filter1 & filter2  
    someDecision = seq1 | filter3

or explicitly, by creating "sequential" building-blocks

    seq1 = seq(filter1 & filter2)  
    someDecision = seq1 | filter3  

If a trigger decision is to be created from a control flow construct, it is denoted by

    triggerPath = path("HighPtMuons", filter1 & filter2)

**todo / proposal for a policy**: the control flow construct will be copied by value. Later changes to the original control flow construct won't be visible in the triggerPath.


## Lazy evaluation vs. parallel evaluation:

By default 'someDecision' follows a lazy evaluation and is purely sequential. However, sometimes one wants to have a parallel execution. The syntax for that could be

    someDecision = parallel(seq1 | filter2)

In this case 'seq1' and filter2 are executed in parallel. In case seq1 has been defined as 'seq( ...)' the parallelization ends at this level. Otherwise the entire decision tree underneath is being parallelized. Data flow dependencies may of course limit the level of parallelization

## Ordering
There are use cases, where algorithms just need to run in a certain order, but do not imply any trigger decision. In this case ">>" is used

     someOrderedAlgs = reco1 >> reco2 >> reco3

The ordering can be mixed with parallel evaluation. In this case, the following two expressions are equivalent, besides additional data dependency constrains:

     parallel(reco1 >> reco2)  vs.  parallel(reco2 >> reco1)

Please note that ">>" has precedence over "&". If this is not the desired behaviour one can use ">" instead, where "&" has precedence.

## Late binding / forward declaration
If the logical structure of a certain trigger decision is clear, but the actual algorithms to fill these structures are to be kept dynamic or can only be defined later in the config, so-called placeholders can be used:

    myDecision = placeholder("unpacking") >> recoSequence >> placeholder("analysis")

with later to be defined:

    myRecoSequence = named("unpacking", unpackingSequence)
    myAnalysis     = named("analysis",  plottingAlgo)

Obviously the usage of placeholders implies the risk of introducing non-localized "magic" names, but this is a matter of coding discipline.

## Additional benefits

Additional benefits of this approach are the possibilities to

  * consistency check the control flow outside Gaudi
  * visualize the control flow w/ Python applications
  * code any fancy tree inspecting algorithm you like

## Migration path

While this proposal is foreseen to be implemented for next generation Gaudi using parallel scheduling, it could as well be retrofit to current Gaudi versions. From the control flow definition, the required GaudiSequencer setup could be created on the fly. Every addition would reside purely in the Python layer.
