# STATUS

Last Updated: 2026-02-16

## Repository State

- Branch: `main`
- Sync state: `main` is up to date with `origin/main`
- Working tree status at update time: clean

## ELK 1:1 Porting Progress

Porting is in progress under the `moon_elk-tpz` epic with strict direct transliteration (no compatibility layer behavior changes).

### Recent Completed Milestones (latest first)

- `4b327c2`: Ported layered ElkGraph transform bridge (`ElkGraphImporter`, `ElkGraphLayoutTransferrer`, `ElkGraphTransformer`), wired recursive transform-context apply/import hooks, and added dedicated bridge tests.
- `bbe9f62`: Ported layered debug utility slice (`DebugUtil`, `DotDebugUtil`, `JsonDebugUtil`) with executable test coverage.
- `07fd170`: Ported `InteractiveNodePlacer` (`p4nodes`) with direct behavior and added dedicated tests.
- `6c9e7fe`: Ported `LabelManagementProcessor` (`layered.intermediate`) and supporting label manager property plumbing.
- `e93b1b6`: Ported `FinalSplineBendpointsCalculator` with tests.
- `9edce38`: Ported `HighDegreeNodeLayeringProcessor` with tests.
- `34ed322`: Ported `HierarchicalNodeResizingProcessor` with tests.
- `2396c4b`: Ported wrapping breaking-point inserter/processor.
- `76d4e1f`: Ported end-label pre/post processors with tests.

### Layered Graph Transform Bridge Slice (current session)

- Replaced marker counterparts with concrete implementations:
  - `alg_layered_graph_transform_elk_graph_importer.mbt`
  - `alg_layered_graph_transform_elk_graph_layout_transferrer.mbt`
  - `alg_layered_graph_transform_elk_graph_transformer.mbt`
  - `alg_layered_layered_layout_provider.mbt`
- Added transform-context registration and replay hooks in `core_recursive_graph_layout_engine.mbt`:
  - `recursive_layered_import_graph_for_transform`
  - `recursive_layered_apply_transformed_graph`
- Added dedicated test suite `alg_layered_graph_transform_elk_graph_transformer_test.mbt` (3 tests):
  - importer + transferrer geometry round-trip
  - `LayeredIGraphTransformer` bridge behavior
  - layered layout provider invocation path
- Updated affected regression expectations after transform-context wiring:
  - `alg_graphviz_dot_transform_dot_exporter_test.mbt`
  - `alg_layered_issues_issue552_test.mbt`
  - `alg_layered_p1cycles_basic_cycle_breaker_test.mbt`
  - `alg_libavoid_layout_provider_test.mbt`
  - `core_issues_457_489_test.mbt`

## Verification Snapshot

Validated during recent porting work:

- `moon test -p username/moon_elk -f alg_layered_graph_transform_elk_graph_transformer_test.mbt --no-render` (3/3)
- `moon test -p username/moon_elk -f core_recursive_graph_layout_engine_test.mbt --no-render` (4/4)
- `moon test -p username/moon_elk -f core_recursive_graph_layout_engine_wbtest.mbt --no-render` (1/1)
- `moon test -p username/moon_elk -f alg_layered_issues_issue552_test.mbt --no-render` (1/1)
- `moon test -p username/moon_elk -f alg_layered_p1cycles_basic_cycle_breaker_test.mbt --no-render` (21/21)
- `moon test -p username/moon_elk -f alg_graphviz_dot_transform_dot_exporter_test.mbt --no-render` (13/13)
- `moon test -p username/moon_elk -f alg_libavoid_layout_provider_test.mbt --no-render` (4/4)
- `moon test -p username/moon_elk -f core_issues_457_489_test.mbt --no-render` (2/2)
- `moon info && moon fmt` (pass; existing repository warnings remain)

## bd Tracking Snapshot

Ready/in-progress high-level tasks currently include:

- `moon_elk-tpz` (epic): ELK Java -> MoonBit full 1:1 port
- `moon_elk-tpz.1`: `org.eclipse.elk.alg.common`
- `moon_elk-tpz.7`: `org.eclipse.elk.alg.layered`
- `moon_elk-tpz.36`: layered tests
- `moon_elk-tpz.7.3`: layered intermediate package
- `moon_elk-tpz.36.2`: layered intermediate tests

## Next Focus

- Continue package-by-package direct transliteration of remaining layered marker files:
  - `alg_layered_elk_layered.mbt`
  - `alg_layered_interactive_layered_graph_visitor.mbt`
  - `alg_layered_graph_l_graph_util.mbt`
  - `alg_layered_graph_l_graph_adapters.mbt`
  - `alg_layered_compound_compound_graph_preprocessor.mbt`
  - `alg_layered_compound_compound_graph_postprocessor.mbt`
- Keep the workflow: port tests first, port implementation file-by-file, then align behavior to tests.
- Continue updating bd comments for each completed slice and keep commits small and traceable.
