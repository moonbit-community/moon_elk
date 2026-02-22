#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import random
import subprocess
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


STATIC_CASES: List[Tuple[str, Dict[str, Any]]] = [
    (
        "line_two_nodes",
        {
            "id": "root",
            "layoutOptions": {
                "algorithm": "layered",
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
        "issue1_hierarchy_include_children",
        {
            "id": "root",
            "layoutOptions": {
                "algorithm": "layered",
                "elk.direction": "DOWN",
                "elk.hierarchyHandling": "INCLUDE_CHILDREN",
                "elk.padding": "[left=20, top=20, right=20, bottom=20]",
            },
            "children": [
                {
                    "id": "A",
                    "width": 180,
                    "height": 120,
                    "layoutOptions": {
                        "elk.hierarchyHandling": "INCLUDE_CHILDREN",
                        "elk.padding": "[left=15, top=15, right=15, bottom=15]",
                    },
                    "children": [
                        {"id": "a1", "width": 70, "height": 40},
                    ],
                },
                {
                    "id": "B",
                    "width": 180,
                    "height": 120,
                    "layoutOptions": {
                        "elk.hierarchyHandling": "INCLUDE_CHILDREN",
                        "elk.padding": "[left=15, top=15, right=15, bottom=15]",
                    },
                    "children": [
                        {"id": "b1", "width": 70, "height": 40},
                    ],
                },
            ],
            "edges": [
                {"id": "e", "sources": ["a1"], "targets": ["b1"]},
            ],
        },
    ),
    (
        "diamond_graph",
        {
            "id": "root",
            "layoutOptions": {
                "algorithm": "layered",
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
                "algorithm": "layered",
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
                {"id": "e1", "sources": ["left_out"], "targets": ["right_in"]},
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


def run_elkjs_case(input_graph: Dict[str, Any], elkjs_module_path: Path) -> Tuple[bool, Dict[str, Any], Optional[str]]:
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
        return (False, {}, out.strip())
    try:
        return (True, extract_json_from_output(out), None)
    except Exception as err:  # pragma: no cover
        return (False, {}, f"elkjs output parse failed: {err}")


def write_moon_case_input(case_input_path: Path, input_graph: Dict[str, Any]) -> None:
    input_json = json.dumps(input_graph, ensure_ascii=False, separators=(",", ":"))
    moon_string_literal = json.dumps(input_json, ensure_ascii=False)
    content = f"""///|
fn case_input_graph_json() -> String {{
  {moon_string_literal}
}}
"""
    case_input_path.write_text(content, encoding="utf-8")


def run_moon_case(repo_root: Path, moon_target_root: Path) -> Tuple[bool, Dict[str, Any], Optional[str]]:
    cmd = [
        "moon",
        "run",
        "src/diff/elkjs_core_compare_runner",
        "--target-dir",
        str(moon_target_root),
    ]
    code, out = run_cmd(cmd, cwd=repo_root)
    if code != 0:
        return (False, {}, out.strip())
    try:
        parsed = extract_json_from_output(out)
    except Exception as err:
        return (False, {}, f"moon output parse failed: {err}")
    moon_error = parsed.get("_moon_error")
    if isinstance(moon_error, str):
        return (False, {}, moon_error)
    return (True, parsed, None)


def normalize_json(value: Any, parent_key: Optional[str] = None) -> Any:
    if isinstance(value, float):
        return round(value, 6)
    if isinstance(value, list):
        normalized = [normalize_json(v, parent_key=parent_key) for v in value]
        if parent_key in {"children", "edges", "ports", "labels", "sections", "bendPoints"}:
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
            missing_left = sorted(list(right_keys - left_keys))
            missing_right = sorted(list(left_keys - right_keys))
            if missing_left:
                return f"{path}.missing_left:{','.join(missing_left)}"
            if missing_right:
                return f"{path}.missing_right:{','.join(missing_right)}"
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


def random_flat_case(case_name: str, rng: random.Random) -> Dict[str, Any]:
    node_count = rng.randint(2, 8)
    direction = rng.choice(["RIGHT", "DOWN", "LEFT", "UP"])
    spacing = rng.choice([20, 25, 30, 40, 50, 60])
    children = []
    for i in range(node_count):
        children.append(
            {
                "id": f"n{i}",
                "width": rng.randint(20, 120),
                "height": rng.randint(20, 90),
            }
        )

    edges: List[Dict[str, Any]] = []
    edge_index = 0
    for i in range(node_count):
        for j in range(i + 1, node_count):
            if rng.random() < 0.32:
                edges.append(
                    {
                        "id": f"e{edge_index}",
                        "sources": [f"n{i}"],
                        "targets": [f"n{j}"],
                    }
                )
                edge_index += 1
    if not edges:
        edges.append({"id": "e0", "sources": ["n0"], "targets": [f"n{node_count - 1}"]})

    return {
        "id": case_name,
        "layoutOptions": {
            "algorithm": "layered",
            "elk.direction": direction,
            "elk.layered.spacing.nodeNodeBetweenLayers": str(spacing),
            "elk.padding": "[left=20, top=20, right=20, bottom=20]",
        },
        "children": children,
        "edges": edges,
    }


def random_hierarchy_case(case_name: str, rng: random.Random) -> Dict[str, Any]:
    direction = rng.choice(["RIGHT", "DOWN"])
    cluster_count = rng.randint(2, 4)
    root_children: List[Dict[str, Any]] = []
    leaves: List[str] = []
    edge_index = 0
    for c in range(cluster_count):
        child_nodes = []
        local_count = rng.randint(1, 3)
        for i in range(local_count):
            node_id = f"c{c}_n{i}"
            child_nodes.append(
                {
                    "id": node_id,
                    "width": rng.randint(35, 110),
                    "height": rng.randint(25, 80),
                }
            )
            leaves.append(node_id)
        root_children.append(
            {
                "id": f"cluster_{c}",
                "width": rng.randint(120, 220),
                "height": rng.randint(90, 180),
                "layoutOptions": {
                    "elk.hierarchyHandling": "INCLUDE_CHILDREN",
                    "elk.padding": "[left=15, top=15, right=15, bottom=15]",
                },
                "children": child_nodes,
            }
        )

    edges: List[Dict[str, Any]] = []
    for i in range(len(leaves) - 1):
        if rng.random() < 0.6:
            edges.append(
                {
                    "id": f"e{edge_index}",
                    "sources": [leaves[i]],
                    "targets": [leaves[i + 1]],
                }
            )
            edge_index += 1
    if not edges and len(leaves) >= 2:
        edges.append({"id": "e0", "sources": [leaves[0]], "targets": [leaves[-1]]})

    return {
        "id": case_name,
        "layoutOptions": {
            "algorithm": "layered",
            "elk.direction": direction,
            "elk.hierarchyHandling": "INCLUDE_CHILDREN",
            "elk.padding": "[left=20, top=20, right=20, bottom=20]",
        },
        "children": root_children,
        "edges": edges,
    }


def random_ports_case(case_name: str, rng: random.Random) -> Dict[str, Any]:
    node_count = rng.randint(2, 5)
    children = []
    for i in range(node_count):
        children.append(
            {
                "id": f"n{i}",
                "width": rng.randint(50, 120),
                "height": rng.randint(35, 90),
                "ports": [
                    {"id": f"n{i}_in", "width": 8, "height": 8},
                    {"id": f"n{i}_out", "width": 8, "height": 8},
                ],
            }
        )
    edges: List[Dict[str, Any]] = []
    for i in range(node_count - 1):
        edges.append(
            {
                "id": f"e{i}",
                "sources": [f"n{i}_out"],
                "targets": [f"n{i + 1}_in"],
            }
        )
    return {
        "id": case_name,
        "layoutOptions": {
            "algorithm": "layered",
            "elk.direction": rng.choice(["RIGHT", "DOWN"]),
            "elk.padding": "[left=20, top=20, right=20, bottom=20]",
        },
        "children": children,
        "edges": edges,
    }


def build_case_set(random_case_count: int, seed: int) -> List[Tuple[str, Dict[str, Any], str]]:
    rows: List[Tuple[str, Dict[str, Any], str]] = []
    for name, case in STATIC_CASES:
        rows.append((name, case, "static"))

    rng = random.Random(seed)
    for i in range(random_case_count):
        bucket = rng.random()
        if bucket < 0.55:
            name = f"random_flat_{i:03d}"
            rows.append((name, random_flat_case(name, rng), "random_flat"))
        elif bucket < 0.85:
            name = f"random_hierarchy_{i:03d}"
            rows.append((name, random_hierarchy_case(name, rng), "random_hierarchy"))
        else:
            name = f"random_ports_{i:03d}"
            rows.append((name, random_ports_case(name, rng), "random_ports"))
    return rows


def as_float(value: Any, default: float = 0.0) -> float:
    if isinstance(value, (int, float)):
        return round(float(value), 6)
    return round(float(default), 6)


def as_string_list(value: Any) -> List[str]:
    if isinstance(value, list):
        result = []
        for item in value:
            if isinstance(item, str):
                result.append(item)
            elif isinstance(item, (int, float)):
                result.append(str(int(item)))
        return result
    return []


def edge_sections_signature(edge: Dict[str, Any]) -> List[Dict[str, Any]]:
    sections = edge.get("sections")
    if not isinstance(sections, list):
        return []
    out: List[Dict[str, Any]] = []
    for section in sections:
        if not isinstance(section, dict):
            continue
        start = section.get("startPoint", {})
        end = section.get("endPoint", {})
        bend_points: List[Tuple[float, float]] = []
        raw_bends = section.get("bendPoints")
        if isinstance(raw_bends, list):
            for bp in raw_bends:
                if isinstance(bp, dict):
                    bend_points.append((as_float(bp.get("x")), as_float(bp.get("y"))))
        out.append(
            {
                "start": (as_float(start.get("x")), as_float(start.get("y"))),
                "end": (as_float(end.get("x")), as_float(end.get("y"))),
                "bends": bend_points,
            }
        )
    return out


def geometry_signature(graph: Dict[str, Any]) -> Dict[str, Any]:
    nodes: Dict[str, Dict[str, Any]] = {}
    ports: Dict[str, Dict[str, Any]] = {}
    labels: Dict[str, Dict[str, Any]] = {}
    edges: Dict[str, Dict[str, Any]] = {}

    def walk_node(node: Dict[str, Any], parent_id: Optional[str]) -> None:
        node_id = str(node.get("id"))
        nodes[node_id] = {
            "parent": parent_id,
            "x": as_float(node.get("x")),
            "y": as_float(node.get("y")),
            "w": as_float(node.get("width")),
            "h": as_float(node.get("height")),
        }

        for label in node.get("labels", []) if isinstance(node.get("labels"), list) else []:
            if isinstance(label, dict):
                label_id = str(label.get("id", f"{node_id}#label@{len(labels)}"))
                labels[label_id] = {
                    "owner": node_id,
                    "x": as_float(label.get("x")),
                    "y": as_float(label.get("y")),
                    "w": as_float(label.get("width")),
                    "h": as_float(label.get("height")),
                }

        for port in node.get("ports", []) if isinstance(node.get("ports"), list) else []:
            if isinstance(port, dict):
                port_id = str(port.get("id"))
                ports[port_id] = {
                    "parent": node_id,
                    "x": as_float(port.get("x")),
                    "y": as_float(port.get("y")),
                    "w": as_float(port.get("width")),
                    "h": as_float(port.get("height")),
                }
                for label in port.get("labels", []) if isinstance(port.get("labels"), list) else []:
                    if isinstance(label, dict):
                        label_id = str(label.get("id", f"{port_id}#label@{len(labels)}"))
                        labels[label_id] = {
                            "owner": port_id,
                            "x": as_float(label.get("x")),
                            "y": as_float(label.get("y")),
                            "w": as_float(label.get("width")),
                            "h": as_float(label.get("height")),
                        }

        for edge in node.get("edges", []) if isinstance(node.get("edges"), list) else []:
            if isinstance(edge, dict):
                edge_id = str(edge.get("id", f"{node_id}#edge@{len(edges)}"))
                edges[edge_id] = {
                    "owner": node_id,
                    "sources": sorted(as_string_list(edge.get("sources"))),
                    "targets": sorted(as_string_list(edge.get("targets"))),
                    "sections": edge_sections_signature(edge),
                }
                for label in edge.get("labels", []) if isinstance(edge.get("labels"), list) else []:
                    if isinstance(label, dict):
                        label_id = str(label.get("id", f"{edge_id}#label@{len(labels)}"))
                        labels[label_id] = {
                            "owner": edge_id,
                            "x": as_float(label.get("x")),
                            "y": as_float(label.get("y")),
                            "w": as_float(label.get("width")),
                            "h": as_float(label.get("height")),
                        }

        for child in node.get("children", []) if isinstance(node.get("children"), list) else []:
            if isinstance(child, dict):
                walk_node(child, node_id)

    walk_node(graph, None)
    return {"nodes": nodes, "ports": ports, "labels": labels, "edges": edges}


def write_report(out_dir: Path, rows: List[Dict[str, Any]]) -> Tuple[Path, Path, int]:
    out_dir.mkdir(parents=True, exist_ok=True)
    strict_mismatches = sum(1 for row in rows if not row["strict_matched"])
    geometry_mismatches = sum(1 for row in rows if not row["geometry_matched"])
    report_json = out_dir / "elkjs_moon_core_json_diff_report.json"
    report_md = out_dir / "elkjs_moon_core_json_diff_report.md"

    payload = {
        "case_count": len(rows),
        "strict_mismatch_count": strict_mismatches,
        "geometry_mismatch_count": geometry_mismatches,
        "rows": rows,
    }
    report_json.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    lines = []
    lines.append("# elkjs vs moon_elk/core JSON Diff Report")
    lines.append("")
    lines.append(f"- Cases: `{len(rows)}`")
    lines.append(f"- Strict mismatches: `{strict_mismatches}`")
    lines.append(f"- Geometry mismatches: `{geometry_mismatches}`")
    lines.append("")
    lines.append("| Case | Category | Strict | Geometry | Diff Path | Moon OK | elkjs OK |")
    lines.append("|---|---|---:|---:|---|---:|---:|")
    for row in rows:
        lines.append(
            f"| `{row['case']}` | `{row['category']}` | `{'YES' if row['strict_matched'] else 'NO'}` | "
            f"`{'YES' if row['geometry_matched'] else 'NO'}` | "
            f"`{row.get('first_diff_path') or '-'}` | `{'YES' if row['moon_ok'] else 'NO'}` | "
            f"`{'YES' if row['elkjs_ok'] else 'NO'}` |"
        )
    report_md.write_text("\n".join(lines), encoding="utf-8")

    return report_json, report_md, geometry_mismatches


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run expanded JSON case diffs between elkjs and moon_elk/core.",
    )
    parser.add_argument(
        "--repo-root",
        default=".",
        help="Repository root of moon_elk.",
    )
    parser.add_argument(
        "--out-dir",
        default="artifacts/diff/elkjs_moon_core_json",
        help="Output report directory.",
    )
    parser.add_argument(
        "--elkjs-module",
        default="/tmp/moon_elk_elkjs_runner/node_modules/elkjs/lib/elk.bundled.js",
        help="Path to elkjs bundled module.",
    )
    parser.add_argument(
        "--moon-target-root",
        default="/tmp/moon_elk_elkjs_moon_core_diff",
        help="Moon target dir root.",
    )
    parser.add_argument(
        "--random-case-count",
        type=int,
        default=80,
        help="Number of random cases to add.",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=20260222,
        help="Deterministic random seed.",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    out_dir = Path(args.out_dir).resolve()
    elkjs_module_path = Path(args.elkjs_module).resolve()
    moon_target_root = Path(args.moon_target_root)
    case_input_path = repo_root / "src/diff/elkjs_core_compare_runner/case_input.mbt"

    if not elkjs_module_path.exists():
        print(f"elkjs module not found: {elkjs_module_path}")
        print("Install with: npm --prefix /tmp/moon_elk_elkjs_runner install elkjs@0.11.0")
        return 5

    cases = build_case_set(args.random_case_count, args.seed)
    rows: List[Dict[str, Any]] = []
    original_case_input: Optional[str] = None

    try:
        original_case_input = case_input_path.read_text(encoding="utf-8")

        for case_name, case_input, category in cases:
            elkjs_ok, elkjs_graph, elkjs_error = run_elkjs_case(case_input, elkjs_module_path)

            write_moon_case_input(case_input_path, case_input)
            moon_ok, moon_graph, moon_error = run_moon_case(repo_root, moon_target_root)

            first_diff: Optional[str] = None
            strict_matched: bool
            geometry_matched: bool
            if moon_ok and elkjs_ok:
                moon_norm = normalize_json(moon_graph)
                elkjs_norm = normalize_json(elkjs_graph)
                first_diff = first_diff_path(moon_norm, elkjs_norm)
                strict_matched = first_diff is None
                geometry_matched = geometry_signature(moon_graph) == geometry_signature(elkjs_graph)
            elif (not moon_ok) and (not elkjs_ok):
                strict_matched = True
                geometry_matched = True
            else:
                strict_matched = False
                geometry_matched = False

            rows.append(
                {
                    "case": case_name,
                    "category": category,
                    "strict_matched": strict_matched,
                    "geometry_matched": geometry_matched,
                    "moon_ok": moon_ok,
                    "elkjs_ok": elkjs_ok,
                    "moon_error": moon_error,
                    "elkjs_error": elkjs_error,
                    "first_diff_path": first_diff,
                }
            )
            print(
                f"[{case_name}] strict={strict_matched} geometry={geometry_matched} "
                f"moon_ok={moon_ok} elkjs_ok={elkjs_ok} diff={first_diff or '-'}"
            )

    finally:
        if original_case_input is not None:
            case_input_path.write_text(original_case_input, encoding="utf-8")

    report_json, report_md, mismatches = write_report(out_dir, rows)
    print(f"Report JSON: {report_json}")
    print(f"Report MD:   {report_md}")
    print(f"Geometry mismatches: {mismatches} / {len(rows)}")

    return 1 if mismatches > 0 else 0


if __name__ == "__main__":
    raise SystemExit(main())
