# STATUS

Last Updated: 2026-02-19

## Repository State

- Branch: `milky/layout-refactor-src-one-shot`
- Module source root: `src`
- Working tree status at update time: clean after verification

## ELK 1:1 Porting + Layout Refactor Status

The one-shot `src/` hierarchy migration is complete for the planned scope:

- Flat root `.mbt` sources migrated into layered `src/**` package directories
- Root package implementation removed (`moon_elk.mbt`)
- Root `moon.pkg` removed
- CLI removed (`cmd/main/*`)
- Package manifests regenerated as `src/**/moon.pkg`
- Migration artifacts recorded under `migration/` (mapping, conflicts, check logs)

The porting policy remains:

- Keep behavior aligned to `./elk-reference`
- Prefer direct transliteration over local invention

## Verification Snapshot

Validated in this migration pass:

- `moon check --target-dir /tmp/moon_elk_check_after_commit` (0 errors, warnings only)
- `moon test --no-render --target-dir /tmp/moon_elk_test_after_commit` (`1547/1547` passed)

## bd Tracking Snapshot

Active epic: `moon_elk-z3p` (`layout-refactor-src-one-shot`)

- `moon_elk-z3p.1`: Task B (bulk move and rename)
- `moon_elk-z3p.2`: Task A (mapping and conflict report)
- `moon_elk-z3p.3`: Task E (verify docs and ship)
- `moon_elk-z3p.4`: Task C (package manifests and deps)
- `moon_elk-z3p.5`: Task D (remove root package and CLI)

## Next Focus

- Close remaining `moon_elk-z3p.*` tasks and epic after final sync/push.
- Keep full-suite regression (`moon test --no-render`) green while continuing strict elk-reference parity fixes.
