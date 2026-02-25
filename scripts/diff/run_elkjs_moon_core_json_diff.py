#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import random
import subprocess
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Set, Tuple

SUPPORTED_ALGORITHMS: List[str] = [
    "layered",
    "force",
    "stress",
    "radial",
    "mrtree",
    "rectpacking",
    "sporeOverlap",
    "sporeCompaction",
    "fixed",
    "box",
    "random",
    "vertiflex",
]

UNSUPPORTED_ALGORITHMS: List[str] = [
    "disco",
    "topdownpacking",
    "libavoid",
    "dot",
    "neato",
    "fdp",
    "sfdp",
    "twopi",
    "circo",
]

DEFAULT_REALWORLD_ROOTS: List[str] = [
    "elk-models/realworld/ptolemy",
    "elk-models/tests",
]

ALGORITHM_ALIASES: Dict[str, str] = {
    "org.eclipse.elk.layered": "layered",
    "org.eclipse.elk.force": "force",
    "org.eclipse.elk.stress": "stress",
    "org.eclipse.elk.radial": "radial",
    "org.eclipse.elk.mrtree": "mrtree",
    "org.eclipse.elk.rectpacking": "rectpacking",
    "org.eclipse.elk.sporeoverlap": "sporeOverlap",
    "org.eclipse.elk.sporecompaction": "sporeCompaction",
    "org.eclipse.elk.fixed": "fixed",
    "org.eclipse.elk.box": "box",
    "org.eclipse.elk.random": "random",
    "org.eclipse.elk.vertiflex": "vertiflex",
    "org.eclipse.elk.disco": "disco",
    "org.eclipse.elk.topdownpacking": "topdownpacking",
    "org.eclipse.elk.libavoid": "libavoid",
    "org.eclipse.elk.graphviz.dot": "dot",
    "org.eclipse.elk.graphviz.neato": "neato",
    "org.eclipse.elk.graphviz.fdp": "fdp",
    "org.eclipse.elk.graphviz.sfdp": "sfdp",
    "org.eclipse.elk.graphviz.twopi": "twopi",
    "org.eclipse.elk.graphviz.circo": "circo",
    "sporeoverlap": "sporeOverlap",
    "sporecompaction": "sporeCompaction",
}


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


def normalize_algorithm(raw: Any) -> Optional[str]:
    if raw is None:
        return None
    value = str(raw).strip()
    if not value:
        return None
    if value in SUPPORTED_ALGORITHMS or value in UNSUPPORTED_ALGORITHMS:
        return value
    lowered = value.lower()
    if lowered in ALGORITHM_ALIASES:
        return ALGORITHM_ALIASES[lowered]
    if lowered.startswith("org.eclipse.elk.graphviz."):
        return lowered.split(".")[-1]
    tail = lowered.split(".")[-1]
    if tail in ALGORITHM_ALIASES:
        return ALGORITHM_ALIASES[tail]
    if tail in SUPPORTED_ALGORITHMS or tail in UNSUPPORTED_ALGORITHMS:
        return tail
    return value


def parse_include_algorithms(raw: str) -> List[str]:
    value = raw.strip()
    if not value or value == "supported":
        return list(SUPPORTED_ALGORITHMS)
    if value == "all":
        return list(SUPPORTED_ALGORITHMS + UNSUPPORTED_ALGORITHMS)

    out: List[str] = []
    for part in value.split(","):
        normalized = normalize_algorithm(part)
        if normalized is not None and normalized not in out:
            out.append(normalized)
    return out


def extract_algorithm_from_graph(graph: Dict[str, Any]) -> Optional[str]:
    options = graph.get("layoutOptions")
    if isinstance(options, dict):
        direct = normalize_algorithm(options.get("algorithm"))
        if direct is not None:
            return direct
        elk = normalize_algorithm(options.get("elk.algorithm"))
        if elk is not None:
            return elk
    return None


def ensure_algorithm_layout_option(graph: Dict[str, Any], algorithm: str) -> None:
    options = graph.get("layoutOptions")
    if not isinstance(options, dict):
        options = {}
        graph["layoutOptions"] = options
    options["algorithm"] = algorithm


def write_moon_json_case_input(case_input_path: Path, input_graph: Dict[str, Any]) -> None:
    input_json = json.dumps(input_graph, ensure_ascii=False, separators=(",", ":"))
    moon_string_literal = json.dumps(input_json, ensure_ascii=False)
    content = f"""///|
fn case_input_graph_json() -> String {{
  {moon_string_literal}
}}
"""
    case_input_path.write_text(content, encoding="utf-8")


def write_moon_text_case_input(case_input_path: Path, input_text: str) -> None:
    moon_string_literal = json.dumps(input_text, ensure_ascii=False)
    content = f"""///|
fn case_input_graph_text() -> String {{
  {moon_string_literal}
}}
"""
    case_input_path.write_text(content, encoding="utf-8")


def run_moon_case(
    repo_root: Path,
    moon_target_root: Path,
    package_path: str,
) -> Tuple[bool, Dict[str, Any], Optional[str]]:
    cmd = [
        "moon",
        "run",
        package_path,
        "--target-dir",
        str(moon_target_root),
    ]
    code, out = run_cmd(cmd, cwd=repo_root)
    if code != 0:
        return False, {}, out.strip()
    try:
        parsed = extract_json_from_output(out)
    except Exception as err:
        return False, {}, f"moon output parse failed: {err}"
    moon_error = parsed.get("_moon_error")
    if isinstance(moon_error, str):
        return False, {}, moon_error
    return True, parsed, None


def run_elkjs_case(
    input_graph: Dict[str, Any],
    elkjs_module_path: Path,
) -> Tuple[bool, Dict[str, Any], Optional[str]]:
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
        return False, {}, out.strip()
    try:
        return True, extract_json_from_output(out), None
    except Exception as err:
        return False, {}, f"elkjs output parse failed: {err}"


def classify_error(err: Optional[str]) -> str:
    if err is None:
        return "none"
    lowered = err.lower()
    if "algorithm" in lowered and (
        "not found" in lowered
        or "unsupported" in lowered
        or "unsupportedconfigurationexception" in lowered
        or "no layout provider" in lowered
    ):
        return "algorithm_not_found"
    if "json" in lowered and "parse" in lowered:
        return "json_parse_error"
    return "other_error"


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


def edge_routing_stats(moon_graph: Dict[str, Any], elkjs_graph: Dict[str, Any]) -> Dict[str, int]:
    moon_edges = geometry_signature(moon_graph)["edges"]
    elk_edges = geometry_signature(elkjs_graph)["edges"]
    stats = {
        "missing_edge_mismatch": 0,
        "section_count_mismatch": 0,
        "start_anchor_mismatch": 0,
        "end_anchor_mismatch": 0,
        "bendpoint_count_mismatch": 0,
        "bendpoint_coord_mismatch": 0,
    }

    all_edge_ids = sorted(set(moon_edges.keys()) | set(elk_edges.keys()))
    for edge_id in all_edge_ids:
        moon_edge = moon_edges.get(edge_id)
        elk_edge = elk_edges.get(edge_id)
        if moon_edge is None or elk_edge is None:
            stats["missing_edge_mismatch"] += 1
            continue

        moon_sections = moon_edge.get("sections", [])
        elk_sections = elk_edge.get("sections", [])
        if len(moon_sections) != len(elk_sections):
            stats["section_count_mismatch"] += 1

        for moon_section, elk_section in zip(moon_sections, elk_sections):
            if moon_section.get("start") != elk_section.get("start"):
                stats["start_anchor_mismatch"] += 1
            if moon_section.get("end") != elk_section.get("end"):
                stats["end_anchor_mismatch"] += 1

            moon_bends = moon_section.get("bends", [])
            elk_bends = elk_section.get("bends", [])
            if len(moon_bends) != len(elk_bends):
                stats["bendpoint_count_mismatch"] += 1
            else:
                for moon_bp, elk_bp in zip(moon_bends, elk_bends):
                    if moon_bp != elk_bp:
                        stats["bendpoint_coord_mismatch"] += 1

    return stats


def edge_routing_matched(stats: Dict[str, int]) -> bool:
    return all(value == 0 for value in stats.values())


def sanitize_case_name(case_name: str) -> str:
    return "".join(ch if (ch.isalnum() or ch in "-_.") else "_" for ch in case_name)


def deep_copy_json(data: Dict[str, Any]) -> Dict[str, Any]:
    return json.loads(json.dumps(data, ensure_ascii=False))


def static_case_for_algorithm(algorithm: str) -> Dict[str, Any]:
    if algorithm == "mrtree":
        return {
            "id": "root",
            "children": [
                {"id": "n1", "width": 40, "height": 30},
                {"id": "n2", "width": 40, "height": 30},
                {"id": "n3", "width": 40, "height": 30},
            ],
            "edges": [
                {"id": "e1", "sources": ["n1"], "targets": ["n2"]},
                {"id": "e2", "sources": ["n1"], "targets": ["n3"]},
            ],
        }
    if algorithm in {"rectpacking", "sporeOverlap", "sporeCompaction", "box", "random", "fixed", "vertiflex"}:
        graph: Dict[str, Any] = {
            "id": "root",
            "children": [
                {"id": "n1", "width": 70, "height": 30},
                {"id": "n2", "width": 60, "height": 50},
                {"id": "n3", "width": 45, "height": 25},
            ],
        }
        if algorithm == "random":
            graph["layoutOptions"] = {"org.eclipse.elk.randomSeed": 1}
        return graph
    return {
        "id": "root",
        "children": [
            {"id": "n1", "width": 60, "height": 30},
            {"id": "n2", "width": 60, "height": 30},
            {"id": "n3", "width": 60, "height": 30},
        ],
        "edges": [
            {"id": "e1", "sources": ["n1"], "targets": ["n2"]},
            {"id": "e2", "sources": ["n2"], "targets": ["n3"]},
        ],
    }


def random_case_for_algorithm(case_name: str, algorithm: str, rng: random.Random) -> Dict[str, Any]:
    node_count = rng.randint(2, 8)
    children = [
        {
            "id": f"n{i}",
            "width": rng.randint(20, 120),
            "height": rng.randint(20, 90),
        }
        for i in range(node_count)
    ]

    if algorithm in {"rectpacking", "sporeOverlap", "sporeCompaction", "box", "random", "fixed", "vertiflex"}:
        graph: Dict[str, Any] = {"id": case_name, "children": children}
        if algorithm == "random":
            graph["layoutOptions"] = {"org.eclipse.elk.randomSeed": 1}
        return graph

    edges: List[Dict[str, Any]] = []
    edge_index = 0
    for i in range(node_count):
        for j in range(i + 1, node_count):
            if rng.random() < 0.3:
                edges.append(
                    {
                        "id": f"e{edge_index}",
                        "sources": [f"n{i}"],
                        "targets": [f"n{j}"],
                    }
                )
                edge_index += 1

    if not edges and node_count >= 2:
        edges.append({"id": "e0", "sources": ["n0"], "targets": [f"n{node_count - 1}"]})

    graph: Dict[str, Any] = {
        "id": case_name,
        "children": children,
        "edges": edges,
    }

    if algorithm == "layered":
        graph["layoutOptions"] = {
            "elk.direction": rng.choice(["RIGHT", "DOWN", "LEFT", "UP"]),
            "elk.layered.spacing.nodeNodeBetweenLayers": str(rng.choice([20, 30, 40, 50])),
        }

    return graph


def build_static_cases(include_algorithms: Iterable[str]) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for algorithm in include_algorithms:
        out.append(
            {
                "name": f"static_{algorithm}",
                "category": "static",
                "algorithm": algorithm,
                "source": "static",
                "input_graph": static_case_for_algorithm(algorithm),
            }
        )
    return out


def build_random_cases(
    include_algorithms: Iterable[str],
    random_case_count: int,
    seed: int,
) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    rng = random.Random(seed)
    if random_case_count <= 0:
        return out
    for algorithm in include_algorithms:
        for i in range(random_case_count):
            case_name = f"random_{algorithm}_{i:03d}"
            out.append(
                {
                    "name": case_name,
                    "category": "random",
                    "algorithm": algorithm,
                    "source": "random",
                    "input_graph": random_case_for_algorithm(case_name, algorithm, rng),
                }
            )
    return out


def load_json_graph(path: Path) -> Dict[str, Any]:
    parsed = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(parsed, dict):
        raise ValueError("Top-level JSON graph must be object.")
    return parsed


def run_elkt_to_json(
    repo_root: Path,
    moon_target_root: Path,
    elkt_case_input_path: Path,
    input_text: str,
) -> Tuple[bool, Dict[str, Any], Optional[str]]:
    write_moon_text_case_input(elkt_case_input_path, input_text)
    return run_moon_case(repo_root, moon_target_root, "src/diff/elkt_to_json_runner")


def case_from_file(
    repo_root: Path,
    file_path: Path,
    algorithm_hint: Optional[str],
    category: str,
    source: str,
    moon_target_root: Path,
    elkt_case_input_path: Path,
    elkt_cache: Dict[str, Tuple[bool, Dict[str, Any], Optional[str]]],
) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
    try:
        if file_path.suffix.lower() == ".json":
            graph = load_json_graph(file_path)
        elif file_path.suffix.lower() == ".elkt":
            cache_key = str(file_path.resolve())
            cached = elkt_cache.get(cache_key)
            if cached is None:
                content = file_path.read_text(encoding="utf-8")
                cached = run_elkt_to_json(
                    repo_root,
                    moon_target_root / "elkt_convert",
                    elkt_case_input_path,
                    content,
                )
                elkt_cache[cache_key] = cached
            ok, graph, err = cached
            if not ok:
                return None, f".elkt conversion failed: {err}"
        else:
            return None, "unsupported extension"
    except Exception as err:
        return None, str(err)

    algorithm = normalize_algorithm(algorithm_hint)
    if algorithm is None:
        algorithm = extract_algorithm_from_graph(graph)
    if algorithm is None:
        algorithm = "layered"

    case_name = source
    return (
        {
            "name": case_name,
            "category": category,
            "algorithm": algorithm,
            "source": source,
            "input_graph": graph,
        },
        None,
    )


def load_manifest_cases(
    manifest_path: Path,
    repo_root: Path,
    moon_target_root: Path,
    elkt_case_input_path: Path,
    elkt_cache: Dict[str, Tuple[bool, Dict[str, Any], Optional[str]]],
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    cases: List[Dict[str, Any]] = []
    invalid: List[Dict[str, Any]] = []
    try:
        parsed = json.loads(manifest_path.read_text(encoding="utf-8"))
    except Exception as err:
        return [], [{"source": str(manifest_path), "error": f"manifest parse failed: {err}"}]

    rows: List[Any]
    if isinstance(parsed, list):
        rows = parsed
    elif isinstance(parsed, dict) and isinstance(parsed.get("cases"), list):
        rows = parsed["cases"]
    else:
        return [], [{"source": str(manifest_path), "error": "manifest must be array or {\"cases\": [...]}."}]

    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            invalid.append({"source": f"{manifest_path}#{index}", "error": "manifest row is not object"})
            continue

        name = str(row.get("name", f"manifest_{index:04d}"))
        category = str(row.get("category", "manifest"))
        algorithm_hint = normalize_algorithm(row.get("algorithm"))

        input_graph = row.get("input_graph")
        if isinstance(input_graph, dict):
            algorithm = algorithm_hint or extract_algorithm_from_graph(input_graph) or "layered"
            cases.append(
                {
                    "name": name,
                    "category": category,
                    "algorithm": algorithm,
                    "source": f"manifest:{name}",
                    "input_graph": input_graph,
                }
            )
            continue

        graph_field = row.get("graph")
        if isinstance(graph_field, dict):
            algorithm = algorithm_hint or extract_algorithm_from_graph(graph_field) or "layered"
            cases.append(
                {
                    "name": name,
                    "category": category,
                    "algorithm": algorithm,
                    "source": f"manifest:{name}",
                    "input_graph": graph_field,
                }
            )
            continue

        path_value = row.get("path")
        if isinstance(path_value, str):
            path = (manifest_path.parent / path_value).resolve()
            case, err = case_from_file(
                repo_root,
                path,
                algorithm_hint,
                category,
                f"manifest:{path.relative_to(repo_root) if path.exists() else path}",
                moon_target_root,
                elkt_case_input_path,
                elkt_cache,
            )
            if err is not None:
                invalid.append({"source": str(path), "error": err})
            elif case is not None:
                case["name"] = name
                cases.append(case)
            continue

        invalid.append({"source": f"{manifest_path}#{index}", "error": "missing input_graph/graph/path"})

    return cases, invalid


def iter_case_files(roots: List[Path]) -> Iterable[Path]:
    for root in roots:
        if not root.exists() or not root.is_dir():
            continue
        for file in sorted(root.rglob("*")):
            if file.is_file() and file.suffix.lower() in {".json", ".elkt"}:
                yield file


def load_realworld_cases(
    repo_root: Path,
    roots: List[Path],
    moon_target_root: Path,
    elkt_case_input_path: Path,
    elkt_cache: Dict[str, Tuple[bool, Dict[str, Any], Optional[str]]],
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    cases: List[Dict[str, Any]] = []
    invalid: List[Dict[str, Any]] = []
    for file in iter_case_files(roots):
        relative = file.relative_to(repo_root) if file.is_relative_to(repo_root) else file
        case, err = case_from_file(
            repo_root,
            file,
            None,
            "realworld",
            f"realworld:{relative}",
            moon_target_root,
            elkt_case_input_path,
            elkt_cache,
        )
        if err is not None:
            invalid.append({"source": str(relative), "error": err})
            continue
        if case is None:
            continue
        case["name"] = f"realworld_{sanitize_case_name(str(relative))}"
        cases.append(case)
    return cases, invalid


def ensure_unique_case_names(cases: List[Dict[str, Any]]) -> None:
    used: Set[str] = set()
    for case in cases:
        base = sanitize_case_name(str(case["name"]))
        candidate = base
        index = 1
        while candidate in used:
            candidate = f"{base}_{index}"
            index += 1
        case["name"] = candidate
        used.add(candidate)


def filter_cases(
    cases: List[Dict[str, Any]],
    include_algorithms: Set[str],
    max_cases_per_algorithm: int,
) -> List[Dict[str, Any]]:
    filtered = [case for case in cases if case["algorithm"] in include_algorithms]
    if max_cases_per_algorithm <= 0:
        return filtered

    limited: List[Dict[str, Any]] = []
    counts: Dict[str, int] = {}
    for case in filtered:
        algorithm = case["algorithm"]
        used = counts.get(algorithm, 0)
        if used >= max_cases_per_algorithm:
            continue
        limited.append(case)
        counts[algorithm] = used + 1
    return limited


def summarize_algorithms(rows: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    by_algorithm: Dict[str, Dict[str, Any]] = {}
    for row in rows:
        algorithm = str(row["algorithm"])
        bucket = by_algorithm.get(algorithm)
        if bucket is None:
            bucket = {
                "algorithm": algorithm,
                "case_count": 0,
                "strict_mismatch_count": 0,
                "geometry_mismatch_count": 0,
                "edge_routing_mismatch_count": 0,
                "first_diff_path": None,
            }
            by_algorithm[algorithm] = bucket
        bucket["case_count"] += 1
        if not row["strict_matched"]:
            bucket["strict_mismatch_count"] += 1
        if not row["geometry_matched"]:
            bucket["geometry_mismatch_count"] += 1
        if not row["edge_routing_matched"]:
            bucket["edge_routing_mismatch_count"] += 1
        if bucket["first_diff_path"] is None and row.get("first_diff_path"):
            bucket["first_diff_path"] = row["first_diff_path"]

    return [by_algorithm[key] for key in sorted(by_algorithm.keys())]


def summarize_edge_routing(rows: List[Dict[str, Any]]) -> Dict[str, int]:
    total = {
        "missing_edge_mismatch": 0,
        "section_count_mismatch": 0,
        "start_anchor_mismatch": 0,
        "end_anchor_mismatch": 0,
        "bendpoint_count_mismatch": 0,
        "bendpoint_coord_mismatch": 0,
    }
    for row in rows:
        stats = row.get("edge_routing_stats")
        if not isinstance(stats, dict):
            continue
        for key in total.keys():
            value = stats.get(key)
            if isinstance(value, int):
                total[key] += value
    return total


def write_report(
    out_dir: Path,
    rows: List[Dict[str, Any]],
    invalid_cases: List[Dict[str, Any]],
) -> Tuple[Path, Path, int]:
    out_dir.mkdir(parents=True, exist_ok=True)
    strict_mismatches = sum(1 for row in rows if not row["strict_matched"])
    geometry_mismatches = sum(1 for row in rows if not row["geometry_matched"])
    edge_mismatches = sum(1 for row in rows if not row["edge_routing_matched"])
    report_json = out_dir / "elkjs_moon_core_json_diff_report.json"
    report_md = out_dir / "elkjs_moon_core_json_diff_report.md"

    payload = {
        "case_count": len(rows),
        "invalid_case_count": len(invalid_cases),
        "strict_mismatch_count": strict_mismatches,
        "geometry_mismatch_count": geometry_mismatches,
        "edge_routing_mismatch_count": edge_mismatches,
        "algorithm_summary": summarize_algorithms(rows),
        "edge_routing_summary": summarize_edge_routing(rows),
        "invalid_cases": invalid_cases,
        "rows": rows,
    }
    report_json.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    lines = []
    lines.append("# elkjs vs moon_elk/core JSON Diff Report")
    lines.append("")
    lines.append(f"- Cases: `{len(rows)}`")
    lines.append(f"- Invalid cases: `{len(invalid_cases)}`")
    lines.append(f"- Strict mismatches: `{strict_mismatches}`")
    lines.append(f"- Geometry mismatches: `{geometry_mismatches}`")
    lines.append(f"- Edge routing mismatches: `{edge_mismatches}`")
    lines.append("")

    lines.append("## Algorithm Buckets")
    lines.append("")
    lines.append("| Algorithm | Cases | Strict Mismatch | Geometry Mismatch | Edge Mismatch | First Diff |")
    lines.append("|---|---:|---:|---:|---:|---|")
    for bucket in summarize_algorithms(rows):
        lines.append(
            f"| `{bucket['algorithm']}` | `{bucket['case_count']}` | `{bucket['strict_mismatch_count']}` | "
            f"`{bucket['geometry_mismatch_count']}` | `{bucket['edge_routing_mismatch_count']}` | "
            f"`{bucket.get('first_diff_path') or '-'}` |"
        )

    lines.append("")
    lines.append("## Cases")
    lines.append("")
    lines.append("| Case | Category | Algorithm | Strict | Geometry | EdgeRouting | Diff Path | Moon OK | elkjs OK |")
    lines.append("|---|---|---|---:|---:|---:|---|---:|---:|")
    for row in rows:
        lines.append(
            f"| `{row['case']}` | `{row['category']}` | `{row['algorithm']}` | "
            f"`{'YES' if row['strict_matched'] else 'NO'}` | `{'YES' if row['geometry_matched'] else 'NO'}` | "
            f"`{'YES' if row['edge_routing_matched'] else 'NO'}` | `{row.get('first_diff_path') or '-'}` | "
            f"`{'YES' if row['moon_ok'] else 'NO'}` | `{'YES' if row['elkjs_ok'] else 'NO'}` |"
        )

    if invalid_cases:
        lines.append("")
        lines.append("## Invalid Cases")
        lines.append("")
        lines.append("| Source | Error |")
        lines.append("|---|---|")
        for row in invalid_cases:
            lines.append(f"| `{row.get('source')}` | `{row.get('error')}` |")

    report_md.write_text("\n".join(lines), encoding="utf-8")
    return report_json, report_md, geometry_mismatches


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run JSON case diffs between elkjs and moon_elk/core with algorithm buckets.",
    )
    parser.add_argument("--repo-root", default=".", help="Repository root of moon_elk.")
    parser.add_argument("--out-dir", default="artifacts/diff/elkjs_moon_core_json", help="Output report directory.")
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
        default=5,
        help="Random cases per algorithm.",
    )
    parser.add_argument("--seed", type=int, default=20260224, help="Deterministic random seed.")
    parser.add_argument("--case-manifest", default=None, help="JSON manifest path for extra cases.")
    parser.add_argument(
        "--realworld-root",
        action="append",
        default=[],
        help="Realworld case root; repeatable. Defaults to elk-models/realworld/ptolemy and elk-models/tests.",
    )
    parser.add_argument(
        "--include-algorithms",
        default="supported",
        help="Comma-separated algorithms, or 'supported', or 'all'.",
    )
    parser.add_argument(
        "--max-cases-per-algorithm",
        type=int,
        default=0,
        help="Limit total case count per algorithm after merge (0 means unlimited).",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    out_dir = Path(args.out_dir).resolve()
    elkjs_module_path = Path(args.elkjs_module).resolve()
    moon_target_root = Path(args.moon_target_root)

    core_case_input_path = repo_root / "src/diff/elkjs_core_compare_runner/case_input.mbt"
    elkt_case_input_path = repo_root / "src/diff/elkt_to_json_runner/case_input.mbt"

    if not elkjs_module_path.exists():
        print(f"elkjs module not found: {elkjs_module_path}")
        print("Install with: npm --prefix /tmp/moon_elk_elkjs_runner install elkjs@0.11.0")
        return 5

    include_algorithms = parse_include_algorithms(args.include_algorithms)
    if not include_algorithms:
        print("No algorithms selected.")
        return 6

    roots = args.realworld_root
    if not roots:
        roots = DEFAULT_REALWORLD_ROOTS
    realworld_roots = [(repo_root / root).resolve() for root in roots]

    cases: List[Dict[str, Any]] = []
    invalid_cases: List[Dict[str, Any]] = []
    elkt_cache: Dict[str, Tuple[bool, Dict[str, Any], Optional[str]]] = {}

    original_core_case_input: Optional[str] = None
    original_elkt_case_input: Optional[str] = None

    try:
        original_core_case_input = core_case_input_path.read_text(encoding="utf-8")
        original_elkt_case_input = elkt_case_input_path.read_text(encoding="utf-8")

        cases.extend(build_static_cases(include_algorithms))
        cases.extend(build_random_cases(include_algorithms, args.random_case_count, args.seed))

        if args.case_manifest is not None:
            manifest_path = Path(args.case_manifest)
            if not manifest_path.is_absolute():
                manifest_path = (repo_root / manifest_path).resolve()
            manifest_cases, manifest_invalid = load_manifest_cases(
                manifest_path,
                repo_root,
                moon_target_root,
                elkt_case_input_path,
                elkt_cache,
            )
            cases.extend(manifest_cases)
            invalid_cases.extend(manifest_invalid)

        realworld_cases, realworld_invalid = load_realworld_cases(
            repo_root,
            realworld_roots,
            moon_target_root,
            elkt_case_input_path,
            elkt_cache,
        )
        cases.extend(realworld_cases)
        invalid_cases.extend(realworld_invalid)

        cases = filter_cases(cases, set(include_algorithms), args.max_cases_per_algorithm)
        ensure_unique_case_names(cases)

        rows: List[Dict[str, Any]] = []

        for case in cases:
            case_name = str(case["name"])
            algorithm = str(case["algorithm"])
            category = str(case["category"])
            source = str(case["source"])

            input_graph = deep_copy_json(case["input_graph"])
            ensure_algorithm_layout_option(input_graph, algorithm)

            elkjs_ok, elkjs_graph, elkjs_error = run_elkjs_case(input_graph, elkjs_module_path)
            write_moon_json_case_input(core_case_input_path, input_graph)
            moon_ok, moon_graph, moon_error = run_moon_case(
                repo_root,
                moon_target_root,
                "src/diff/elkjs_core_compare_runner",
            )

            first_diff: Optional[str] = None
            strict_matched: bool
            geometry_matched: bool
            edge_stats = {
                "missing_edge_mismatch": 0,
                "section_count_mismatch": 0,
                "start_anchor_mismatch": 0,
                "end_anchor_mismatch": 0,
                "bendpoint_count_mismatch": 0,
                "bendpoint_coord_mismatch": 0,
            }
            edge_matched: bool

            if moon_ok and elkjs_ok:
                moon_norm = normalize_json(moon_graph)
                elkjs_norm = normalize_json(elkjs_graph)
                first_diff = first_diff_path(moon_norm, elkjs_norm)
                strict_matched = first_diff is None
                geometry_matched = geometry_signature(moon_graph) == geometry_signature(elkjs_graph)
                edge_stats = edge_routing_stats(moon_graph, elkjs_graph)
                edge_matched = edge_routing_matched(edge_stats)
            elif (not moon_ok) and (not elkjs_ok):
                moon_error_kind = classify_error(moon_error)
                elkjs_error_kind = classify_error(elkjs_error)
                strict_matched = moon_error_kind == elkjs_error_kind
                geometry_matched = strict_matched
                edge_matched = strict_matched
                if not strict_matched:
                    first_diff = "$._error_kind"
            else:
                strict_matched = False
                geometry_matched = False
                edge_matched = False

            rows.append(
                {
                    "case": case_name,
                    "category": category,
                    "algorithm": algorithm,
                    "source": source,
                    "strict_matched": strict_matched,
                    "geometry_matched": geometry_matched,
                    "edge_routing_matched": edge_matched,
                    "edge_routing_stats": edge_stats,
                    "moon_ok": moon_ok,
                    "elkjs_ok": elkjs_ok,
                    "moon_error": moon_error,
                    "elkjs_error": elkjs_error,
                    "moon_error_kind": classify_error(moon_error),
                    "elkjs_error_kind": classify_error(elkjs_error),
                    "first_diff_path": first_diff,
                }
            )

            print(
                f"[{case_name}] algo={algorithm} strict={strict_matched} "
                f"geometry={geometry_matched} edge={edge_matched} "
                f"moon_ok={moon_ok} elkjs_ok={elkjs_ok} diff={first_diff or '-'}"
            )

    finally:
        if original_core_case_input is not None:
            core_case_input_path.write_text(original_core_case_input, encoding="utf-8")
        if original_elkt_case_input is not None:
            elkt_case_input_path.write_text(original_elkt_case_input, encoding="utf-8")

    report_json, report_md, geometry_mismatches = write_report(out_dir, rows, invalid_cases)
    print(f"Report JSON: {report_json}")
    print(f"Report MD:   {report_md}")
    print(f"Geometry mismatches: {geometry_mismatches} / {len(rows)}")

    strict_mismatches = sum(1 for row in rows if not row["strict_matched"])
    edge_mismatches = sum(1 for row in rows if not row["edge_routing_matched"])
    return 1 if (strict_mismatches > 0 or geometry_mismatches > 0 or edge_mismatches > 0) else 0


if __name__ == "__main__":
    raise SystemExit(main())
