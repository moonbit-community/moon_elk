#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


CASES: List[Tuple[str, Dict[str, Any]]] = [
    (
        "line_two_nodes",
        {
            "id": "root",
            "layoutOptions": {
                "elk.algorithm": "layered",
                "elk.direction": "RIGHT",
                "elk.spacing.nodeNode": "40",
            },
            "children": [
                {"id": "n1", "width": 30, "height": 30},
                {"id": "n2", "width": 30, "height": 30},
            ],
            "edges": [
                {"id": "e1", "sources": ["n1"], "targets": ["n2"]},
            ],
        },
    ),
    (
        "diamond_graph",
        {
            "id": "root",
            "layoutOptions": {
                "elk.algorithm": "layered",
                "elk.direction": "DOWN",
                "elk.layered.spacing.nodeNodeBetweenLayers": "50",
            },
            "children": [
                {"id": "a", "width": 40, "height": 30},
                {"id": "b", "width": 40, "height": 30},
                {"id": "c", "width": 40, "height": 30},
                {"id": "d", "width": 40, "height": 30},
            ],
            "edges": [
                {"id": "e1", "sources": ["a"], "targets": ["b"]},
                {"id": "e2", "sources": ["a"], "targets": ["c"]},
                {"id": "e3", "sources": ["b"], "targets": ["d"]},
                {"id": "e4", "sources": ["c"], "targets": ["d"]},
            ],
        },
    ),
    (
        "ports_case",
        {
            "id": "root",
            "layoutOptions": {
                "elk.algorithm": "layered",
                "elk.direction": "RIGHT",
            },
            "children": [
                {
                    "id": "left",
                    "width": 60,
                    "height": 40,
                    "ports": [
                        {"id": "left_out", "width": 8, "height": 8},
                    ],
                },
                {
                    "id": "right",
                    "width": 60,
                    "height": 40,
                    "ports": [
                        {"id": "right_in", "width": 8, "height": 8},
                    ],
                },
            ],
            "edges": [
                {
                    "id": "e1",
                    "sources": ["left_out"],
                    "targets": ["right_in"],
                },
            ],
        },
    ),
    (
        "compound_inner_edge",
        {
            "id": "root",
            "layoutOptions": {
                "elk.algorithm": "layered",
                "elk.direction": "RIGHT",
            },
            "children": [
                {
                    "id": "cluster",
                    "children": [
                        {"id": "c1", "width": 30, "height": 30},
                        {"id": "c2", "width": 30, "height": 30},
                    ],
                    "edges": [
                        {"id": "ce1", "sources": ["c1"], "targets": ["c2"]},
                    ],
                },
                {"id": "outside", "width": 30, "height": 30},
            ],
        },
    ),
]


def run_cmd(
    cmd: List[str],
    cwd: Path,
    env: Optional[Dict[str, str]] = None,
) -> Tuple[int, str]:
    proc = subprocess.run(
        cmd,
        cwd=str(cwd),
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    return proc.returncode, proc.stdout


def extract_json_from_output(output: str) -> Dict[str, Any]:
    lines = [line.strip() for line in output.splitlines() if line.strip()]
    for line in reversed(lines):
        if line.startswith("{") and line.endswith("}"):
            return json.loads(line)
    raise ValueError("No JSON object line found in output.")


def run_elkjs_case(input_graph: Dict[str, Any], elkjs_module_path: Path) -> Dict[str, Any]:
    node_script = (
        "const ELK = require(process.env.ELKJS_MODULE);"
        "const elk = new ELK();"
        "const graph = JSON.parse(process.env.INPUT_JSON);"
        "elk.layout(graph)"
        ".then((result) => { console.log(JSON.stringify(result)); })"
        ".catch((err) => { console.error(err && err.stack ? err.stack : String(err)); process.exit(1); });"
    )
    env = os.environ.copy()
    env["ELKJS_MODULE"] = str(elkjs_module_path)
    env["INPUT_JSON"] = json.dumps(input_graph, ensure_ascii=False, separators=(",", ":"))
    code, out = run_cmd(["node", "-e", node_script], cwd=Path("."), env=env)
    if code != 0:
        raise RuntimeError(f"elkjs run failed: {out}")
    return extract_json_from_output(out)


def write_moon_case_input(case_input_path: Path, input_graph: Dict[str, Any]) -> None:
    input_json = json.dumps(input_graph, ensure_ascii=False, separators=(",", ":"))
    moon_string_literal = json.dumps(input_json, ensure_ascii=False)
    content = f"""///|
fn case_input_graph_json() -> String {{
  {moon_string_literal}
}}
"""
    case_input_path.write_text(content, encoding="utf-8")


def run_moon_case(repo_root: Path, moon_target_root: Path) -> Dict[str, Any]:
    cmd = [
        "moon",
        "run",
        "src/diff/elkjs_compare_runner",
        "--target-dir",
        str(moon_target_root),
    ]
    code, out = run_cmd(cmd, cwd=repo_root)
    if code != 0:
        raise RuntimeError(f"moon run failed: {out}")
    return extract_json_from_output(out)


def normalize_json(value: Any, parent_key: Optional[str] = None) -> Any:
    if isinstance(value, float):
        return round(value, 6)
    if isinstance(value, list):
        normalized = [normalize_json(v, parent_key=parent_key) for v in value]
        if parent_key in {"children", "edges", "ports", "labels", "sections"}:
            def sort_key(item: Any) -> str:
                if isinstance(item, dict) and "id" in item:
                    return f"id:{item['id']}"
                return json.dumps(item, ensure_ascii=False, sort_keys=True)
            normalized.sort(key=sort_key)
        return normalized
    if isinstance(value, dict):
        out: Dict[str, Any] = {}
        for key, child in value.items():
            if key == "$H":
                continue
            out[key] = normalize_json(child, parent_key=key)
        return out
    return value


def first_diff_path(left: Any, right: Any, path: str = "$") -> Optional[str]:
    if type(left) != type(right):
        return path
    if isinstance(left, dict):
        left_keys = set(left.keys())
        right_keys = set(right.keys())
        if left_keys != right_keys:
            return path
        for key in sorted(left_keys):
            diff = first_diff_path(left[key], right[key], f"{path}.{key}")
            if diff is not None:
                return diff
        return None
    if isinstance(left, list):
        if len(left) != len(right):
            return path
        for i, (lv, rv) in enumerate(zip(left, right)):
            diff = first_diff_path(lv, rv, f"{path}[{i}]")
            if diff is not None:
                return diff
        return None
    if left != right:
        return path
    return None


def write_report(out_dir: Path, rows: List[Dict[str, Any]]) -> Tuple[Path, Path, int]:
    out_dir.mkdir(parents=True, exist_ok=True)
    mismatches = sum(1 for row in rows if not row["matched"])
    report_json = out_dir / "elkjs_moon_json_diff_report.json"
    report_md = out_dir / "elkjs_moon_json_diff_report.md"

    payload = {
        "case_count": len(rows),
        "mismatch_count": mismatches,
        "rows": rows,
    }
    report_json.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    lines = []
    lines.append("# elkjs vs moon_elk JSON Diff Report")
    lines.append("")
    lines.append(f"- Cases: `{len(rows)}`")
    lines.append(f"- Mismatches: `{mismatches}`")
    lines.append("")
    lines.append("| Case | Matched | Diff Path |")
    lines.append("|---|---:|---|")
    for row in rows:
        lines.append(
            f"| `{row['case']}` | `{'YES' if row['matched'] else 'NO'}` | `{row.get('first_diff_path') or '-'}` |"
        )
    report_md.write_text("\n".join(lines), encoding="utf-8")

    return report_json, report_md, mismatches


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run handcrafted JSON case diffs between elkjs and moon_elk.",
    )
    parser.add_argument(
        "--repo-root",
        default=".",
        help="Repository root of moon_elk.",
    )
    parser.add_argument(
        "--out-dir",
        default="artifacts/diff/elkjs_moon_json",
        help="Output report directory.",
    )
    parser.add_argument(
        "--elkjs-module",
        default="/tmp/moon_elk_elkjs_runner/node_modules/elkjs/lib/elk.bundled.js",
        help="Path to elkjs bundled module.",
    )
    parser.add_argument(
        "--moon-target-root",
        default="/tmp/moon_elk_elkjs_moon_diff",
        help="Moon target dir root.",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    out_dir = Path(args.out_dir).resolve()
    elkjs_module_path = Path(args.elkjs_module).resolve()
    moon_target_root = Path(args.moon_target_root)
    case_input_path = repo_root / "src/diff/elkjs_compare_runner/case_input.mbt"

    if not elkjs_module_path.exists():
        print(f"elkjs module not found: {elkjs_module_path}")
        print("Install with: npm --prefix /tmp/moon_elk_elkjs_runner install elkjs@0.11.0")
        return 5

    rows: List[Dict[str, Any]] = []
    original_case_input: Optional[str] = None
    try:
        original_case_input = case_input_path.read_text(encoding="utf-8")
        for name, input_graph in CASES:
            write_moon_case_input(case_input_path, input_graph)
            elkjs_output = run_elkjs_case(input_graph, elkjs_module_path)
            moon_output = run_moon_case(repo_root, moon_target_root / name)

            elkjs_normalized = normalize_json(elkjs_output)
            moon_normalized = normalize_json(moon_output)
            diff_path = first_diff_path(elkjs_normalized, moon_normalized)
            matched = diff_path is None
            rows.append(
                {
                    "case": name,
                    "matched": matched,
                    "first_diff_path": diff_path,
                    "input": input_graph,
                    "elkjs_output": elkjs_output,
                    "moon_output": moon_output,
                }
            )
    finally:
        if original_case_input is not None:
            case_input_path.write_text(original_case_input, encoding="utf-8")

    report_json, report_md, mismatches = write_report(out_dir, rows)
    print(f"Cases: {len(rows)}")
    print(f"Mismatches: {mismatches}")
    print(f"Report (json): {report_json}")
    print(f"Report (md): {report_md}")
    return 0 if mismatches == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
