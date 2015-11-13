# TransformAlgorithm Playground

The setup-lhcb-build.sh script in this directory will checkout versions
of Guadi, LHCb, Lbcom, Rec and Brunel from a git branch dedicated to 
playing around with 'TransformAlgorithm'.


The aim of 'TransformAlgorithm' is to demonstrate 
 - one can remove explicit TES interactions from non-framework code
 - one can make many algorithms 'const' during the actual processing of events
 - one can pass input and output 'by const reference' resp. 'by value' without
   loss of efficiency

The above results in 
  - less 'boiler plate', 
  - more uniform 'look and feel'
  - naturally provides a more 'declarative' style of codeing
  - code which is more 'future proof', i.e.
      o  can be wrapped in futures
      o  can be run asychonously
      o  can allow for automatic scalar->vector adaption
         (i.e. 'user' only needs to provide scalar operation)


The changes can be shown by going into the Rec directory, and
comparing the 'Paris2015-baseline' tag and the 'HEAD' of the Paris2015 branch,
eg. 'git diff Paris2015-baseline HEAD'.

In case you don't want to check out the code in git, you can see the differences
directly on gitlab using the following URL:

https://gitlab.cern.ch/graven/Rec/compare/Paris2015-baseline...Paris2015

or in a (nicer) side-by-side view:

https://gitlab.cern.ch/graven/Rec/compare/Paris2015-baseline...Paris2015?view=parallel


