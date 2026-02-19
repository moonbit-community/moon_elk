# Local Differential Test Scripts

This directory contains local-only differential checks between:

- MoonBit port (`/Users/zhengyu/Documents/projects/moon_elk/src/**`)
- Java reference (`/Users/zhengyu/Documents/projects/moon_elk/elk-reference/**`)

No CI integration is required.

## Graph JSON Paired Diff

Script:

- `/Users/zhengyu/Documents/projects/moon_elk/scripts/diff/run_graph_json_paired_diff.sh`

It runs:

1. MoonBit graph/json tests (file-by-file)
2. ELK-reference graph/json JUnit module (single Maven batch command)
3. A paired matrix report (`moon file` <-> `reference class`)

### Usage

```bash
/Users/zhengyu/Documents/projects/moon_elk/scripts/diff/run_graph_json_paired_diff.sh
```

### Output

- JSON report:
  - `/Users/zhengyu/Documents/projects/moon_elk/artifacts/diff/graph_json/graph_json_paired_diff_report.json`
- Markdown report:
  - `/Users/zhengyu/Documents/projects/moon_elk/artifacts/diff/graph_json/graph_json_paired_diff_report.md`

### Useful Flags

Skip Java execution and only parse existing JUnit XML:

```bash
/Users/zhengyu/Documents/projects/moon_elk/scripts/diff/run_graph_json_paired_diff.sh \
  --skip-ref-run
```

Override ELK-reference Maven command:

```bash
/Users/zhengyu/Documents/projects/moon_elk/scripts/diff/run_graph_json_paired_diff.sh \
  --ref-mvn-cmd "mvn -q -f pom.xml -pl ../plugins/org.eclipse.elk.core,../plugins/org.eclipse.elk.graph,../plugins/org.eclipse.elk.alg.layered,../plugins/org.eclipse.elk.graph.json,../test/org.eclipse.elk.graph.json.test -DskipTests=false test"
```

### Notes

- ELK-reference uses Tycho. First run may be slow due dependency resolution.
- If JUnit XML reports are not generated in the default folder, pass `--ref-report-dir`.
- This script is intentionally package-focused (`graph/json`) and can be extended to other packages with the same structure.

