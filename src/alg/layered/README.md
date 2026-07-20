# Layered package structure

`alg/layered` is a namespace directory, not a MoonBit package. Callers import
the package that owns the capability they use; there is deliberately no
compatibility facade at `Milky2018/moon_elk/alg/layered`.

The implementation is split by dependency direction:

- `options` owns all layered option identifiers, enums, parsing helpers, and
  option metadata. No algorithm package owns a second copy of these types.
- `runtime` owns the shared layered graph model, internal properties, processor
  protocol, and the mutually dependent ordering, routing, spacing, and
  intermediate-processing kernel. Its `state` subpackage owns mutable state
  shared for the duration of one layout run.
- `pipeline` owns the public layout provider and composition flow. Its
  `transform`, `components`, and `compound` subpackages own graph conversion,
  disconnected-component placement, and compound-graph preprocessing
  respectively.
- `engine` links concrete phase and processor packages and runs their
  registration initializers.
- `phases/cycle`, `phases/layering`, and `phases/placement` own the concrete
  implementations for the first, second, and fourth layered phases.
- `processors/comments` and `processors/partition` own the extracted
  intermediate processor families.
- `compaction` is a namespace for independent compaction packages: `oned`
  owns the one-dimensional constraint model, `components` owns component
  compaction, and `recthull` owns rectilinear hull utilities.
- `tests/issues` owns black-box regressions for reported issues.

The production dependency graph is intentionally acyclic:

```text
application ──> options
     ├───────> pipeline ──> runtime ──> options
     └───────> engine ──> concrete phases/processors ──> runtime
```

Applications that execute layered layout import both `pipeline` and `engine`:
the former installs the layout-provider adapter and the latter installs the
concrete phase factories. Code that only declares layered options imports
`options`; code that directly manipulates the internal layered graph imports
`runtime`.

Concrete packages register factories through the runtime composition seam.
The runtime package must never import `pipeline`, `engine`, or a concrete
implementation package in production code.

## Why most ordering, routing, and spacing code remains in runtime

These files are not merely independent phase implementations. The layered
graph's typed property stores still contain spacing state, self-loop state,
wrapping state, end-label cells, and spline segments. Those types in turn
operate directly on `LGraph`, `LNode`, `LPort`, and `LEdge`. Source-level
dependency analysis therefore places the model and most of these processors in
one strong component.

The ordering random state is the first state extracted from that component.
The execution plan retains `runtime/state::LayeredLayoutState` for the full
run, while the root graph and its split component graphs carry the same
reference so existing processors consume one deterministic random sequence.
Disposal clears the state explicitly; the random object is neither stored in a
generic property map nor retained in a global registry.

Horizontal compaction follows a narrower lifetime: its origin lookup is owned
by one `LGraphToCGraphTransformer` and is injected into spacing, scanline, and
network-simplex closures. This keeps `LNode` and `VerticalSegment` references
out of process-wide maps and lets concurrent transformations remain isolated.

Moving the files into separate directories while widening fields or using
global handle maps would hide the cycle rather than remove it, and global maps
would also reintroduce the lifetime risks that explicit graph disposal avoids.
Further splits must continue moving algorithm-specific state behind similarly
explicit lifetime boundaries before moving dependent processors. Until then,
`runtime` is the explicit internal kernel rather than a public facade or a
collection of unrelated definitions.
