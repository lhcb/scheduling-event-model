# Something something hacks

These are a list of small projects that can be tackled on Tuesday
and Wednesday. The goal is to gain some experience with each topic,
share this experience with others, and build models that will make it
easier to discuss each idea in a concrete way.


## abstraction levels

The higher level abstraction we can offer the "user" the more
opportunity we have for optimising things. What is the right level of
abstraction? Use cases from fitting tracks, doing things to a group of
particles, selecting a range of events to store in a file.


## Random access store

What technology exists out there for efficient storage that fits our
needs *and* allows for random access. A small review of the existing
chunked, column stores could be a good starting point. The advantage
of being able to do random access would be not having to read through
large numbers of files that are in the same stripping stream.


## storing objects

Right now it is impossible to add a new class to be stored in a
DIGI/DST. This leads to all sorts of hacks. `boost::any`?
`captnproto`? What are possible answers? This is related to backwards
compatibility in #12. Keyword: type erasure. The IO layer should
be contained in a small, standalone library which will make it more
portable/reusable. Think toolkit instead of framework.


## linking information across objects

We invented `ExtraInfo` as some crazy hack that does not work very
well. We need a better way to be able to add more information to a
given object (be that a track, particle, hit, ...). This information
will exist for some but not all objects in a collection. If you think
of the information in an event as a big table, then this is natural,
you simply add a new column. Think of composing more complex objects
from simpler ones.


## best way to express a processing pipeline

How do you express something like "take these hits, build tracks from
them, filter on X, take these other hits, build different kinds of
tracks from them, filter them on Y, merge the two track collections,
evaluate PID info for them, select pions with pt>5GeV" in a way that
is flexible and extremely easy for humans to read, and also possible
for computer to parse? The aim is to write this kind of processing
using ideas from functional programming:

```python
even = filter(lambda x: x%2, range(10))
even_squared = map(lambda x: x**2, even)

# comapred to
def make_even_squares():
  out = []
  for n in range(10):
    if n%2:
      out.append(n**2)
  return out
```