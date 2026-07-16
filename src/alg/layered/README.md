# Layered package structure

The `layered` package is the shared foundation and facade for the layered
layout algorithm. It owns the graph model, phase descriptors, processor
configuration, shared intermediate data, and the public layout provider.

Concrete implementation clusters live in child packages:

- `engine` is the composition root. Importing it links the concrete phase and
  processor packages and runs their registration initializers.
- `phases/cycle` owns cycle-breaking implementations.
- `phases/layering` owns layer-assignment implementations.
- `phases/placement` owns node-placement implementations.
- `processors/comments` owns comment-related intermediate processors.
- `processors/partition` owns partition-related intermediate processors.
- `compaction` owns the independent one-dimensional compaction model and
  algorithms.
- `options` owns option definitions that do not depend on the shared layered
  model.
- `tests/issues` owns black-box regression tests for reported issues.

Concrete packages depend on the shared `layered` package and register their
factories through the composition seam. The shared package must not import a
concrete implementation package, because doing so would create an import cycle.

The `p3order_*` and `p5edges_*` files remain in the shared package for now.
Their apparent phase prefixes are misleading: crossing-minimization helpers
are also used by greedy-switch intermediate processors, while routing types
and spline helpers are stored in the graph model or consumed by self-loop and
final-bendpoint processors. They should move only after those shared
interfaces have been separated, not as a mechanical directory split.
