# STATUS

Last Updated: 2026-02-15

## Repository State

- Branch: `main`
- Sync state: `main` is up to date with `origin/main`
- Working tree status at update time: clean

## ELK 1:1 Porting Progress

Porting is in progress under the `moon_elk-tpz` epic with strict direct transliteration (no compatibility layer behavior changes).

### Recent Completed Milestones (latest first)

- `07fd170`: Ported `InteractiveNodePlacer` (`p4nodes`) with direct behavior and added dedicated tests.
- `6c9e7fe`: Ported `LabelManagementProcessor` (`layered.intermediate`) and supporting label manager property plumbing.
- `e93b1b6`: Ported `FinalSplineBendpointsCalculator` with tests.
- `9edce38`: Ported `HighDegreeNodeLayeringProcessor` with tests.
- `34ed322`: Ported `HierarchicalNodeResizingProcessor` with tests.
- `2396c4b`: Ported wrapping breaking-point inserter/processor.
- `76d4e1f`: Ported end-label pre/post processors with tests.

### Interactive Node Placer Slice (current session)

- Implemented direct transliteration in `alg_layered_p4nodes_interactive_node_placer.mbt`.
- Wired recursive factory mapping for `nodePlacement.strategy = INTERACTIVE` in `core_recursive_graph_layout_engine.mbt`.
- Added executable test suite `alg_layered_p4nodes_interactive_node_placer_test.mbt` (6 tests):
  - task name parity
  - dummy original y restoration (`ORIGINAL_DUMMY_NODE_POSITION`)
  - dummy y fallback placement
  - overlap push-down behavior
  - external-port dependency injection
  - no-external-port configuration path

## Verification Snapshot

Validated during recent porting work:

- `moon test -p username/moon_elk -f alg_layered_p4nodes_interactive_node_placer_test.mbt --no-render` (6/6)
- `moon test -p username/moon_elk -f alg_layered_p4nodes_basic_node_placement_test.mbt --no-render` (1/1)
- `moon test -p username/moon_elk -f core_recursive_graph_layout_engine_test.mbt --no-render` (4/4)
- `moon info && moon fmt && moon check --no-render` (pass, existing repository warnings remain)

## bd Tracking Snapshot

Ready/in-progress high-level tasks currently include:

- `moon_elk-tpz` (epic): ELK Java -> MoonBit full 1:1 port
- `moon_elk-tpz.1`: `org.eclipse.elk.alg.common`
- `moon_elk-tpz.7`: `org.eclipse.elk.alg.layered`
- `moon_elk-tpz.36`: layered tests
- `moon_elk-tpz.7.3`: layered intermediate package
- `moon_elk-tpz.36.2`: layered intermediate tests

## Next Focus

- Continue package-by-package direct transliteration of remaining layered components.
- Keep the workflow: port tests first, port implementation file-by-file, then align behavior to tests.
- Continue updating bd comments for each completed slice and keep commits small and traceable.
