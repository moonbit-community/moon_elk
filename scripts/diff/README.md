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

## Full Plugin Diff

Script:

- `/Users/zhengyu/Documents/projects/moon_elk/scripts/diff/run_full_plugin_diff.sh`

It runs:

1. MoonBit tests for mapped package set:
   - `src/alg/common`
   - `src/alg/disco`
   - `src/alg/force`
   - `src/alg/layered`
   - `src/alg/mrtree`
   - `src/alg/radial`
   - `src/alg/rectpacking`
   - `src/alg/spore`
   - `src/alg/test`
   - `src/alg/topdownpacking`
   - `src/core`
   - `src/graph`
   - `src/graph/json`
   - `src/shared`
2. ELK-reference runs for all corresponding test plugins:
   - `org.eclipse.elk.alg.common.test`
   - `org.eclipse.elk.alg.disco.test`
   - `org.eclipse.elk.alg.force.test`
   - `org.eclipse.elk.alg.layered.test`
   - `org.eclipse.elk.alg.mrtree.test`
   - `org.eclipse.elk.alg.radial.test`
   - `org.eclipse.elk.alg.rectpacking.test`
   - `org.eclipse.elk.alg.spore.test`
   - `org.eclipse.elk.alg.test`
   - `org.eclipse.elk.alg.topdown.test`
   - `org.eclipse.elk.core.test`
   - `org.eclipse.elk.graph.test`
   - `org.eclipse.elk.graph.json.test`
   - `org.eclipse.elk.shared.test`
3. A plugin-pair matrix report (`reference plugin` <-> `moon package`).

### Usage

```bash
/Users/zhengyu/Documents/projects/moon_elk/scripts/diff/run_full_plugin_diff.sh
```

Prerequisite:

- Clone models repository to `/Users/zhengyu/Documents/projects/moon_elk/elk-models` (or pass `--models-repo`):

```bash
cd /Users/zhengyu/Documents/projects/moon_elk
git clone https://github.com/eclipse-elk/elk-models.git elk-models
```

### Output

- JSON report:
  - `/Users/zhengyu/Documents/projects/moon_elk/artifacts/diff/full/full_plugin_diff_report.json`
- Markdown report:
  - `/Users/zhengyu/Documents/projects/moon_elk/artifacts/diff/full/full_plugin_diff_report.md`

## elkjs vs moon_elk JSON Diff

Script:

- `/Users/zhengyu/Documents/projects/moon_elk/scripts/diff/run_elkjs_moon_json_diff.sh`

It runs:

1. Handcrafted JSON graph inputs.
2. Layout by elkjs (`elkjs/lib/elk.bundled.js`).
3. Layout by moon_elk (`src/diff/elkjs_compare_runner`).
4. Normalized JSON diff and case-level mismatch report.

### Prerequisite

Install elkjs once in a temp folder:

```bash
mkdir -p /tmp/moon_elk_elkjs_runner
cd /tmp/moon_elk_elkjs_runner
npm init -y
npm install elkjs@0.11.0
```

### Usage

```bash
/Users/zhengyu/Documents/projects/moon_elk/scripts/diff/run_elkjs_moon_json_diff.sh
```

### Output

- JSON report:
  - `/Users/zhengyu/Documents/projects/moon_elk/artifacts/diff/elkjs_moon_json/elkjs_moon_json_diff_report.json`
- Markdown report:
  - `/Users/zhengyu/Documents/projects/moon_elk/artifacts/diff/elkjs_moon_json/elkjs_moon_json_diff_report.md`

## elkjs vs moon_elk/core Expanded JSON Diff

Script:

- `/Users/zhengyu/Documents/projects/moon_elk/scripts/diff/run_elkjs_moon_core_json_diff.sh`

It runs:

1. Core API path (`Milky2018/moon_elk/core`, i.e. `new_elk_engine().layout`) via:
   - `src/diff/elkjs_core_compare_runner`
2. elkjs (`elkjs/lib/elk.bundled.js`)
3. Case set:
   - Static regression cases (including issue #1 include-children case)
   - Deterministic random cases (flat / hierarchy / ports)
4. Normalized JSON diff and mismatch report.

### Usage

```bash
/Users/zhengyu/Documents/projects/moon_elk/scripts/diff/run_elkjs_moon_core_json_diff.sh \
  --random-case-count 120 \
  --seed 20260222
```

### Output

- JSON report:
  - `/Users/zhengyu/Documents/projects/moon_elk/artifacts/diff/elkjs_moon_core_json/elkjs_moon_core_json_diff_report.json`
- Markdown report:
  - `/Users/zhengyu/Documents/projects/moon_elk/artifacts/diff/elkjs_moon_core_json/elkjs_moon_core_json_diff_report.md`
