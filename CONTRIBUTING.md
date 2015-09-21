# Contributing

We use the [fork and pull](gh-fork-pull) model to manage changes. More information
about [forking a repository](gh-fork) and [making a Pull Request](gh-pull).

This set of documents and codes evolves by making a concrete proposal for a
change (a pull request), followed by a discussion of that proposal within the
PR, and then merging or not the PR. The aim is to keep the discussions on topic
and concrete by not discussing topics without a concrete patch to discuss.

To contribute to this repository:

1. fork [the project repository](https://github.com/lhcb/scheduling-event-model/).
   Click on the 'Fork' button near the top of the page. This creates a copy of
   the code under your account on the GitHub server.
2. clone this copy of the repository to your local disk:

        $ git clone git@github.com:YourLogin/scheduling-event-model.git
        $ cd scheduling-event-model

2. create a new branch in your clone `git checkout -b my-new-branch`. Never
   work in the ``master`` branch!
4. Work on this copy on your computer using Git to do the version
   control. When you're done editing, do:

          $ git add modified_files
          $ git commit

   to record your changes in Git, then push them to GitHub with:

          $ git push -u origin my-new-branch

Finally, go to the web page of your fork of the scheduling-event-model repo,
and click 'Pull request' to send your changes to the maintainers for
review. This will send an email to the committers.

There is one additional rule: no one can merge their own pull requests, someone
else has to press the button.


# Dependencies

All documents should be written in [markdown]() which is rendered automatically
when viewing the repository on github, to preview things locally [install Pandoc](http://www.pandoc.org/installing)
