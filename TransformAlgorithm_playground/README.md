# TransformAlgorithm Playground

The setup-lhcb-build.sh script in this directory will checkout versions of Gaudi, LHCb,
Lbcom, Rec and Brunel from a git branch dedicated to playing around with 'TransformAlgorithm'.

The aim of 'TransformAlgorithm' is to demonstrate one can

1. remove explicit TES interactions from non-framework code 
-  make algorithms 'const' during the event loop
-  pass input and output 'by const reference' resp. 'by value' without loss of efficiency

The above results in

1. less 'boiler plate',
-  more uniform 'look and feel'
-  naturally provides a more 'declarative' style of coding
-  code which is more 'future proof', i.e. it can
    +  be wrapped in futures
    +  be run asychonously
    +  allow for automatic scalar to vector adaption
            (i.e. 'user' only needs to provide scalar operation)


The corresponding JIRA task for the GAUDI infrastructure changes is [GAUDI-1132](https://its.cern.ch/jira/browse/GAUDI-1132). 
If you have suggestions and/or requests, eg. you find that features are missing for your particular use, please add them to this JIRA task.

The changes can be shown by going into the Rec directory, and
comparing the 'Paris2015-baseline' tag and the 'HEAD' of the Paris2015 branch,
eg. 'git diff Paris2015-baseline HEAD'.

In case you don't want to check out the code in git, you can see the differences
directly on gitlab using the following URL:

https://gitlab.cern.ch/graven/Rec/compare/Paris2015-baseline...Paris2015

or in a (nicer) side-by-side view:

https://gitlab.cern.ch/graven/Rec/compare/Paris2015-baseline...Paris2015?view=parallel

