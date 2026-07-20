# Layered package structure

The top-level `layered` package is a compatibility facade. It keeps the public
algorithm identifier, option vocabulary, and layout-provider constructor at
their established import path, but it does not own their implementations.

The implementation is split by dependency direction:

- `options` owns all layered option identifiers, enums, parsing helpers, and
  option metadata. No algorithm package owns a second copy of these types.
- `runtime` owns the shared layered graph model, internal properties, processor
  protocol, and the mutually dependent ordering, routing, spacing, and
  intermediate-processing kernel.
- `pipeline` owns ELK graph import and layout transfer, graph configuration,
  component and compound orchestration, and the public layout provider.
- `engine` is the composition root. Importing it links concrete phase and
  processor packages and runs their registration initializers.
- `phases/cycle`, `phases/layering`, and `phases/placement` own the concrete
  implementations for the first, second, and fourth layered phases.
- `processors/comments` and `processors/partition` own the extracted
  intermediate processor families.
- `compaction` owns the independent one-dimensional compaction model and
  algorithms.
- `tests/issues` owns black-box regressions for reported issues.

The production dependency graph is intentionally acyclic:

```text
layered facade ──> pipeline ──> runtime ──> options
       │              │
       └──> engine ───┴──> concrete phases/processors ──> runtime
```

Concrete packages register factories through the runtime composition seam.
The runtime package must never import `pipeline`, `engine`, the top-level
facade, or a concrete implementation package in production code.

## Why ordering, routing, and spacing remain in runtime

These files are not merely independent phase implementations. The layered
graph's typed property stores contain ordering random state, spacing state,
self-loop state, wrapping state, end-label cells, and spline segments. Those
types in turn operate directly on `LGraph`, `LNode`, `LPort`, and `LEdge`.
Source-level dependency analysis therefore places the model and most of these
processors in one strong component.

Moving the files into separate directories while widening fields or using
global handle maps would hide the cycle rather than remove it, and global maps
would also reintroduce the lifetime risks that explicit graph disposal avoids.
A future split must first redesign algorithm-specific property storage so that
per-run state is owned outside the graph model. Until then, `runtime` is the
explicit internal kernel rather than a public facade or a collection of
unrelated definitions.
