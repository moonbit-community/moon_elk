# Common algorithm packages

`alg/common` retains only the small utilities that are genuinely shared as one
package. Larger independent capabilities use explicit subpackages:

- `compaction` owns scanline constraints and the reusable one-dimensional
  compaction model.
- `networksimplex` owns the generic network-simplex graph and solver.
- `nodespacing` owns generic node, port, and label size calculation.
- `overlaps` owns rectangle-strip overlap removal.
- `polyomino` owns polyomino packing structures and traversal strategies.

Consumers import the capability package directly. The parent package is not a
facade and does not re-export these APIs.
