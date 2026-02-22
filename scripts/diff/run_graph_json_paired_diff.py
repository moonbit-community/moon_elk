#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import textwrap
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple


@dataclass
class MoonResult:
    file: str
    ok: bool
    total: int
    passed: int
    failed: int
    output: str


@dataclass
class RefClassResult:
    class_name: str
    ok: Optional[bool]
    tests: int
    failures: int
    errors: int
    skipped: int


PAIR_MAP: List[Tuple[str, str]] = [
    ("src/graph/json/graph_test.mbt", "GraphTest"),
    ("src/graph/json/id_test.mbt", "IdTest"),
    ("src/graph/json/edges_test.mbt", "EdgesTest"),
    ("src/graph/json/export_test.mbt", "ExportTest"),
    ("src/graph/json/layout_options_test.mbt", "LayoutOptionsTest"),
    ("src/graph/json/sections_test.mbt", "SectionsTest"),
    ("src/graph/json/transfer_layout_test.mbt", "TransferLayoutTest"),
    ("src/graph/json/edge_coords_test.mbt", "EdgeCoordsTest"),
    ("src/graph/json/individual_spacings_test.mbt", "IndividualSpacingsTest"),
]

MOON_ONLY: List[str] = [
    "src/graph/json/json_adapter_test.mbt",
    "src/graph/json/json_import_exception_test.mbt",
    "src/graph/json/json_meta_data_converter_test.mbt",
    "src/graph/json/test_support_test.mbt",
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


def parse_moon_summary(output: str) -> Tuple[int, int, int]:
    m = re.search(
        r"Total tests:\s*(\d+),\s*passed:\s*(\d+),\s*failed:\s*(\d+)\.",
        output,
    )
    if not m:
        return (0, 0, 0)
    return (int(m.group(1)), int(m.group(2)), int(m.group(3)))


def run_moon_tests(repo_root: Path, moon_target_root: Path) -> Dict[str, MoonResult]:
    results: Dict[str, MoonResult] = {}
    all_files = [p for p, _ in PAIR_MAP] + MOON_ONLY
    for moon_file in all_files:
        case_name = Path(moon_file).stem
        target_dir = moon_target_root / case_name
        cmd = [
            "moon",
            "test",
            moon_file,
            "--no-render",
            "--target-dir",
            str(target_dir),
        ]
        code, out = run_cmd(cmd, repo_root)
        total, passed, failed = parse_moon_summary(out)
        results[moon_file] = MoonResult(
            file=moon_file,
            ok=(code == 0 and failed == 0),
            total=total,
            passed=passed,
            failed=failed,
            output=out,
        )
    return results


def run_reference_batch(ref_root: Path, ref_mvn_cmd: str) -> Tuple[int, str]:
    cmd = shlex.split(ref_mvn_cmd)
    return run_cmd(cmd, ref_root)


def reset_reference_reports(report_dir: Path) -> None:
    if report_dir.exists():
        shutil.rmtree(report_dir)


def parse_reference_reports(report_dir: Path) -> Dict[str, RefClassResult]:
    out: Dict[str, RefClassResult] = {}
    if not report_dir.exists():
        return out

    xml_files = sorted(report_dir.glob("*.xml"))
    for xml_file in xml_files:
        try:
            root = ET.parse(xml_file).getroot()
        except ET.ParseError:
            continue

        if root.tag != "testsuite":
            continue

        suite_name = root.attrib.get("name", "")
        if "." in suite_name:
            class_name = suite_name.rsplit(".", 1)[-1]
        else:
            class_name = suite_name

        tests = int(root.attrib.get("tests", "0"))
        failures = int(root.attrib.get("failures", "0"))
        errors = int(root.attrib.get("errors", "0"))
        skipped = int(root.attrib.get("skipped", "0"))
        ok = (failures == 0 and errors == 0)

        out[class_name] = RefClassResult(
            class_name=class_name,
            ok=ok,
            tests=tests,
            failures=failures,
            errors=errors,
            skipped=skipped,
        )
    return out


def write_report(
    out_dir: Path,
    moon_results: Dict[str, MoonResult],
    ref_results: Dict[str, RefClassResult],
    ref_run_code: Optional[int],
    ref_run_output: Optional[str],
    skip_ref_run: bool,
) -> Tuple[Path, Path, int]:
    out_dir.mkdir(parents=True, exist_ok=True)
    report_json = out_dir / "graph_json_paired_diff_report.json"
    report_md = out_dir / "graph_json_paired_diff_report.md"

    rows = []
    mismatches = 0
    for moon_file, ref_class in PAIR_MAP:
        moon = moon_results.get(moon_file)
        ref = ref_results.get(ref_class)
        moon_ok = moon.ok if moon is not None else False
        ref_ok = ref.ok if ref is not None else None
        if ref_ok is None and skip_ref_run:
            matched = True
        else:
            matched = (ref_ok is not None and moon_ok == ref_ok)
        if not matched:
            mismatches += 1
        rows.append(
            {
                "moon_file": moon_file,
                "ref_class": ref_class,
                "moon_ok": moon_ok,
                "moon_total": moon.total if moon else 0,
                "moon_passed": moon.passed if moon else 0,
                "moon_failed": moon.failed if moon else 0,
                "ref_ok": ref_ok,
                "ref_tests": ref.tests if ref else 0,
                "ref_failures": ref.failures if ref else 0,
                "ref_errors": ref.errors if ref else 0,
                "matched": matched,
            }
        )

    payload = {
        "paired_rows": rows,
        "moon_only_files": MOON_ONLY,
        "reference_run": {
            "skipped": skip_ref_run,
            "exit_code": ref_run_code,
            "output_head": (ref_run_output or "")[:6000],
        },
        "mismatch_count": mismatches,
    }
    report_json.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    lines = []
    lines.append("# Graph JSON Paired Diff Report")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- Paired cases: `{len(PAIR_MAP)}`")
    lines.append(f"- Mismatches: `{mismatches}`")
    lines.append(f"- Moon-only cases: `{len(MOON_ONLY)}`")
    if skip_ref_run:
        lines.append("- Reference run: `skipped`")
    else:
        lines.append(f"- Reference run exit code: `{ref_run_code}`")
    lines.append("")
    lines.append("## Paired Matrix")
    lines.append("")
    lines.append("| Moon test file | Reference class | Moon | Reference | Matched |")
    lines.append("|---|---|---:|---:|---:|")
    for row in rows:
        moon_state = "PASS" if row["moon_ok"] else "FAIL"
        ref_state = "N/A" if row["ref_ok"] is None else ("PASS" if row["ref_ok"] else "FAIL")
        matched = "YES" if row["matched"] else "NO"
        lines.append(
            f"| `{row['moon_file']}` | `{row['ref_class']}` | `{moon_state}` | `{ref_state}` | `{matched}` |"
        )
    lines.append("")
    lines.append("## Moon-Only Cases")
    lines.append("")
    for moon_only in MOON_ONLY:
        lines.append(f"- `{moon_only}`")
    lines.append("")
    report_md.write_text("\n".join(lines), encoding="utf-8")

    return report_json, report_md, mismatches


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run local paired diff checks for graph/json tests.",
    )
    parser.add_argument(
        "--repo-root",
        default=".",
        help="moon_elk repository root (default: current directory).",
    )
    parser.add_argument(
        "--out-dir",
        default="artifacts/diff/graph_json",
        help="Output report directory.",
    )
    parser.add_argument(
        "--moon-target-root",
        default="/tmp/moon_elk_graph_json_pairdiff",
        help="Base target dir for moon test runs.",
    )
    parser.add_argument(
        "--skip-ref-run",
        action="store_true",
        help="Skip running ELK-reference tests; parse existing reports only.",
    )
    parser.add_argument(
        "--ref-report-dir",
        default="elk-reference/test/org.eclipse.elk.graph.json.test/target/surefire-reports",
        help="JUnit XML report directory for ELK-reference graph.json tests.",
    )
    parser.add_argument(
        "--ref-root",
        default="elk-reference/build",
        help="Working directory to run reference maven command.",
    )
    parser.add_argument(
        "--ref-mvn-cmd",
        default=(
            "mvn -f pom.xml "
            "-pl ../plugins/org.eclipse.elk.alg.common,../plugins/org.eclipse.elk.alg.disco,"
            "../plugins/org.eclipse.elk.alg.force,../plugins/org.eclipse.elk.alg.layered,"
            "../plugins/org.eclipse.elk.alg.mrtree,../plugins/org.eclipse.elk.alg.radial,"
            "../plugins/org.eclipse.elk.alg.rectpacking,../plugins/org.eclipse.elk.alg.spore,"
            "../plugins/org.eclipse.elk.alg.vertiflex,../plugins/org.eclipse.elk.core.meta,"
            "../plugins/org.eclipse.elk.core,../plugins/org.eclipse.elk.core.debug.grandom,"
            "../plugins/org.eclipse.elk.graph,../plugins/org.eclipse.elk.graph.json,"
            "../plugins/org.eclipse.elk.graph.text,../test/org.eclipse.elk.alg.test,"
            "../test/org.eclipse.elk.graph.json.test "
            "-DskipTests=false -DfailIfNoTests=false "
            "-Dtest=org.eclipse.elk.graph.json.test.* integration-test"
        ),
        help="Maven command to run ELK-reference graph/json tests.",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    out_dir = Path(args.out_dir).resolve()
    moon_target_root = Path(args.moon_target_root)
    ref_report_dir = (repo_root / args.ref_report_dir).resolve()
    ref_root = (repo_root / args.ref_root).resolve()

    moon_results = run_moon_tests(repo_root, moon_target_root)

    ref_code: Optional[int] = None
    ref_output: Optional[str] = None
    if not args.skip_ref_run:
        reset_reference_reports(ref_report_dir)
        ref_code, ref_output = run_reference_batch(ref_root, args.ref_mvn_cmd)

    ref_results = parse_reference_reports(ref_report_dir)
    report_json, report_md, mismatches = write_report(
        out_dir=out_dir,
        moon_results=moon_results,
        ref_results=ref_results,
        ref_run_code=ref_code,
        ref_run_output=ref_output,
        skip_ref_run=args.skip_ref_run,
    )

    print(f"Moon cases executed: {len(moon_results)}")
    print(f"Reference classes parsed: {len(ref_results)}")
    print(f"Mismatches: {mismatches}")
    print(f"Report (json): {report_json}")
    print(f"Report (md): {report_md}")

    if not args.skip_ref_run and ref_code != 0:
        print("Reference run failed; see report json output_head for details.", file=sys.stderr)
        return 3
    if not args.skip_ref_run and len(ref_results) == 0:
        print("Reference run produced no JUnit XML reports.", file=sys.stderr)
        return 4
    if mismatches > 0:
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
