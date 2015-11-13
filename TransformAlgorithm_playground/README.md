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
eg. 'git diff Paris2015-baseline HEAD'

1 > git diff -b --stat  Paris2015-baseline HEAD 
 Calo/CaloReco/src/CaloSinglePhotonAlg.cpp          |  222 +++++++-------------
 Calo/CaloReco/src/CaloSinglePhotonAlg.h            |   69 +++----
 Hlt/HltMonitors/src/MuMonitor.cpp                  |   36 ++--
 Hlt/HltMonitors/src/MuMonitor.h                    |   21 +--
 Muon/MuonID/src/component/MakeMuonMeasurements.cpp |   72 +++----
 Muon/MuonID/src/component/MakeMuonMeasurements.h   |   23 +--
 Muon/MuonID/src/component/SmartMuonMeasProvider.h  |   26 +--
 Rec/RecAlgs/src/EventTimeMonitor.cpp               |   42 +---
 Rec/RecAlgs/src/EventTimeMonitor.h                 |   21 +--
 Tf/PatAlgorithms/src/PatMatch.cpp                  |   59 +-----
 Tf/PatAlgorithms/src/PatMatch.h                    |   35 +---
 Tr/TrackUtils/src/TTrackFromLong.cpp               |   65 ++----
 Tr/TrackUtils/src/TTrackFromLong.h                 |   31 +--
 Tr/TrackUtils/src/TrackFromDST.cpp                 |   97 ++++-----
 Tr/TrackUtils/src/TrackFromDST.h                   |   27 +--
 Tr/TrackUtils/src/TrackListMerger.cpp              |   23 +--
 16 files changed, 298 insertions(+), 571 deletions(-)

In case you don't want to check out the code in git, you can see the differences
directly on gitlab using the following URL:

https://gitlab.cern.ch/graven/Rec/compare/Paris2015-baseline...Paris2015

or in a (nicer) side-by-side view:

https://gitlab.cern.ch/graven/Rec/compare/Paris2015-baseline...Paris2015?view=parallel


