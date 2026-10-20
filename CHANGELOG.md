# Changelog

## 0.3.4 (moonbit-community/elk) - 2026-10-20

- Continue maintenance under `moonbit-community/elk` in the community repository.
- Incorporate all commits from `bobzhang/elk` through `cb509224`, preserving
  their history and the elkjs 0.9.3 compatibility changes.
- Deprecate all existing `Milky2018/moon_elk` releases in favor of the community
  module.
- Add a manual Mooncakes publishing workflow using the organization's
  `MOONCAKES_MOONBIT_COMMUNITY_TOKEN` secret. The workflow defaults to a dry run;
  disable `dry_run` to publish after validation.

## 0.3.4 - 2026-10-14

Released from the fork `bobzhang/elk`. Every change brings the port closer
to elkjs 0.9.3 (ELK 0.9.1).

### Fixed

- Layered, `LINEAR_SEGMENTS`: a node's deflection adds each edge's term as
  one sum, as Java's `+=` does; about forty other compound assignments had
  the same rounding difference, among them stacked edge-label sizes.
- Layered: spacing options set on the graph (`spacing.edgeLabel`,
  `spacing.labelLabel`, ...) reach the algorithm.
- Options given as strings of a set (`"[MINIMUM_SIZE, NODE_LABELS]"`) are
  read, and `edgeLabels.inline` is a known option.
- A container laid out by a non-layered algorithm gets a fixed size, as
  `ElkUtil.resizeNode` does.
- Rectpacking: a new row in a block fits by the row's height, or always in
  a row of one block.
- Mrtree follows ELK 0.9.1: edge routing, node positions, packing, the
  write-back, model-order weighting by default, and the compaction
  scanline; a cycle among siblings raises instead of looping.
- Force and stress follow ELK 0.9.1's loop and label handling.
- Radial, `KVector`, DisCo and splines use JavaScript's correctly rounded
  `sin`, `cos`, `acos` and `atan2` (new package `jsmath`); a cycle below the
  root raises instead of crashing.

## 0.3.3 - 2026-10-14

Released from the fork `bobzhang/elk`.

### Fixed

- Layered: the connected components of a graph share its random number
  generator, as in ELK, instead of each seeding one of its own.
- Layered: edge labels are written back by the label they came from, not
  by their position in the list, which swapped a centre label with a head
  or tail label.
- Layered: the labels of a self loop stack by the direction the graph was
  given (they were placed side by side in left-to-right graphs).
- Layered: node margins use `NodeMarginCalculator`'s bounding-box
  arithmetic, which removes last-bit differences from elkjs with groups.

## 0.3.2 (bobzhang/elk) - 2026-10-14

- The module is named `bobzhang/elk`; it is `moon_elk` 0.3.2 with the
  elkjs 0.9.3 parity fixes that mermaid's graphs need.

## 0.3.0 - 2026-09-18

### Added

- Integrated DisCo and Topdown Packing into the core JSON engine.
- Added Graphviz DOT model serialization and byte parsing.
- Added Graphviz family registration for `dot`, `neato`, `fdp`, `sfdp`,
  `twopi`, and `circo`.
- Added Graphviz text runner process adapters and one-step registration.
- Added Libavoid transport, text runner, server output protocol parsing, and
  explicit engine registration.
- Added a runnable minimal JSON layout example.
- Added a multi-target CI matrix for wasm, wasm-gc, js, and native.

### Changed

- Removed unused package imports and enabled `moon check --deny-warn`.
- Made Graphviz and Libavoid opt-in capabilities instead of default engine
  algorithms.
- Replaced Graphviz provider serializer/parser test stubs with real DOT
  serialization and parsing.

### Fixed

- Fixed DisCo related-port movement after component compaction.
- Fixed Libavoid cluster child coordinate conversion.

### Known Limits

- Graphviz and Libavoid executables are supplied by the host runtime.
- Native process adapters remain host-provided through synchronous runner or
  process factory APIs.
- Windows CI remains disabled for the full repository build.
