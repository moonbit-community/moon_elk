#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shlex
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple


@dataclass
class MoonPackageResult:
    package_path: str
    ok: bool
    total: int
    passed: int
    failed: int
    output: str


@dataclass
class RefPluginResult:
    plugin: str
    ok: Optional[bool]
    tests: int
    failures: int
    errors: int
    skipped: int
    classes: int


PLUGIN_TO_MOON: List[Tuple[str, str]] = [
    ("org.eclipse.elk.alg.common.test", "src/alg/common"),
    ("org.eclipse.elk.alg.disco.test", "src/alg/disco"),
    ("org.eclipse.elk.alg.force.test", "src/alg/force"),
    ("org.eclipse.elk.alg.layered.test", "src/alg/layered"),
    ("org.eclipse.elk.alg.mrtree.test", "src/alg/mrtree"),
    ("org.eclipse.elk.alg.radial.test", "src/alg/radial"),
    ("org.eclipse.elk.alg.rectpacking.test", "src/alg/rectpacking"),
    ("org.eclipse.elk.alg.spore.test", "src/alg/spore"),
    ("org.eclipse.elk.alg.test", "src/alg/test"),
    ("org.eclipse.elk.alg.topdown.test", "src/alg/topdownpacking"),
    ("org.eclipse.elk.core.test", "src/core"),
    ("org.eclipse.elk.graph.json.test", "src/graph/json"),
    ("org.eclipse.elk.graph.test", "src/graph"),
    ("org.eclipse.elk.shared.test", "src/shared"),
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
    marker = "Total tests:"
    idx = output.rfind(marker)
    if idx < 0:
        return (0, 0, 0)
    tail = output[idx:]
    # Example: Total tests: 44, passed: 44, failed: 0.
    parts = tail.replace(".", "").replace(",", "").split()
    try:
        total = int(parts[2])
        passed = int(parts[4])
        failed = int(parts[6])
        return (total, passed, failed)
    except (ValueError, IndexError):
        return (0, 0, 0)


def safe_target_name(package_path: str) -> str:
    return package_path.replace("/", "_")


def run_moon_tests(repo_root: Path, moon_target_root: Path) -> Dict[str, MoonPackageResult]:
    results: Dict[str, MoonPackageResult] = {}
    for _, package_path in PLUGIN_TO_MOON:
        target_dir = moon_target_root / safe_target_name(package_path)
        cmd = [
            "moon",
            "test",
            package_path,
            "--no-render",
            "--target-dir",
            str(target_dir),
        ]
        code, out = run_cmd(cmd, repo_root)
        total, passed, failed = parse_moon_summary(out)
        results[package_path] = MoonPackageResult(
            package_path=package_path,
            ok=(code == 0 and failed == 0),
            total=total,
            passed=passed,
            failed=failed,
            output=out,
        )
    return results


def reset_reference_reports(repo_root: Path) -> None:
    for plugin, _ in PLUGIN_TO_MOON:
        report_dir = repo_root / "elk-reference" / "test" / plugin / "target" / "surefire-reports"
        if report_dir.exists():
            shutil.rmtree(report_dir)


def discover_reference_plugin_modules(repo_root: Path) -> List[str]:
    plugins_root = repo_root / "elk-reference" / "plugins"
    modules = sorted(
        f"../plugins/{path.name}"
        for path in plugins_root.glob("org.eclipse.elk.*")
        if path.is_dir()
    )
    return modules


def default_reference_command(repo_root: Path, elk_repo: Path, models_repo: Path) -> List[str]:
    plugin_modules = discover_reference_plugin_modules(repo_root)
    test_modules = [f"../test/{plugin}" for plugin, _ in PLUGIN_TO_MOON]
    all_modules = plugin_modules + test_modules
    return [
        "mvn",
        "-f",
        "pom.xml",
        "-fae",
        "-pl",
        ",".join(all_modules),
        f"-Dtests.paths.elk-repo={elk_repo}",
        f"-Dtests.paths.models-repo={models_repo}",
        "-DskipTests=false",
        "-DfailIfNoTests=false",
        "integration-test",
    ]


def run_reference_batch(
    ref_root: Path,
    ref_mvn_cmd: Optional[str],
    repo_root: Path,
    elk_repo: Path,
    models_repo: Path,
) -> Tuple[int, str]:
    if ref_mvn_cmd is None:
        cmd = default_reference_command(repo_root, elk_repo, models_repo)
    else:
        cmd = shlex.split(ref_mvn_cmd)
    return run_cmd(cmd, ref_root)


def parse_reference_reports(repo_root: Path) -> Dict[str, RefPluginResult]:
    results: Dict[str, RefPluginResult] = {}

    for plugin, _ in PLUGIN_TO_MOON:
        report_dir = repo_root / "elk-reference" / "test" / plugin / "target" / "surefire-reports"
        if not report_dir.exists():
            results[plugin] = RefPluginResult(
                plugin=plugin,
                ok=None,
                tests=0,
                failures=0,
                errors=0,
                skipped=0,
                classes=0,
            )
            continue

        tests = 0
        failures = 0
        errors = 0
        skipped = 0
        classes = 0
        for xml_file in sorted(report_dir.glob("*.xml")):
            try:
                root = ET.parse(xml_file).getroot()
            except ET.ParseError:
                continue
            if root.tag != "testsuite":
                continue
            classes += 1
            tests += int(root.attrib.get("tests", "0"))
            failures += int(root.attrib.get("failures", "0"))
            errors += int(root.attrib.get("errors", "0"))
            skipped += int(root.attrib.get("skipped", "0"))

        ok: Optional[bool]
        if classes == 0:
            ok = None
        else:
            ok = (failures == 0 and errors == 0)

        results[plugin] = RefPluginResult(
            plugin=plugin,
            ok=ok,
            tests=tests,
            failures=failures,
            errors=errors,
            skipped=skipped,
            classes=classes,
        )

    return results


def write_report(
    out_dir: Path,
    moon_results: Dict[str, MoonPackageResult],
    ref_results: Dict[str, RefPluginResult],
    ref_run_code: Optional[int],
    ref_run_output: Optional[str],
    skip_ref_run: bool,
) -> Tuple[Path, Path, int]:
    out_dir.mkdir(parents=True, exist_ok=True)
    report_json = out_dir / "full_plugin_diff_report.json"
    report_md = out_dir / "full_plugin_diff_report.md"

    rows = []
    mismatches = 0
    for plugin, moon_pkg in PLUGIN_TO_MOON:
        moon = moon_results.get(moon_pkg)
        ref = ref_results.get(plugin)
        moon_ok = moon.ok if moon else False
        ref_ok = ref.ok if ref else None
        matched = False
        if skip_ref_run and ref_ok is None:
            matched = True
        elif ref_ok is not None and moon_ok == ref_ok:
            matched = True
        if not matched:
            mismatches += 1
        rows.append(
            {
                "ref_plugin": plugin,
                "moon_package": moon_pkg,
                "moon_ok": moon_ok,
                "moon_total": moon.total if moon else 0,
                "moon_passed": moon.passed if moon else 0,
                "moon_failed": moon.failed if moon else 0,
                "ref_ok": ref_ok,
                "ref_classes": ref.classes if ref else 0,
                "ref_tests": ref.tests if ref else 0,
                "ref_failures": ref.failures if ref else 0,
                "ref_errors": ref.errors if ref else 0,
                "ref_skipped": ref.skipped if ref else 0,
                "matched": matched,
            }
        )

    payload = {
        "rows": rows,
        "mapping_count": len(PLUGIN_TO_MOON),
        "mismatch_count": mismatches,
        "reference_run": {
            "skipped": skip_ref_run,
            "exit_code": ref_run_code,
            "output_head": (ref_run_output or "")[:6000],
        },
    }
    report_json.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    lines: List[str] = []
    lines.append("# Full ELK Plugin Differential Report")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- Mapped plugin pairs: `{len(PLUGIN_TO_MOON)}`")
    lines.append(f"- Mismatches: `{mismatches}`")
    if skip_ref_run:
        lines.append("- Reference run: `skipped`")
    else:
        lines.append(f"- Reference run exit code: `{ref_run_code}`")
    lines.append("")
    lines.append("## Matrix")
    lines.append("")
    lines.append("| Reference test plugin | Moon package | Moon | Reference | Matched |")
    lines.append("|---|---|---:|---:|---:|")
    for row in rows:
        moon_state = "PASS" if row["moon_ok"] else "FAIL"
        ref_state = "N/A" if row["ref_ok"] is None else ("PASS" if row["ref_ok"] else "FAIL")
        matched = "YES" if row["matched"] else "NO"
        lines.append(
            f"| `{row['ref_plugin']}` | `{row['moon_package']}` | `{moon_state}` | `{ref_state}` | `{matched}` |"
        )

    report_md.write_text("\n".join(lines), encoding="utf-8")
    return report_json, report_md, mismatches


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run full plugin-level differential checks against elk-reference tests.",
    )
    parser.add_argument(
        "--repo-root",
        default=".",
        help="moon_elk repository root (default: current directory).",
    )
    parser.add_argument(
        "--out-dir",
        default="artifacts/diff/full",
        help="Output report directory.",
    )
    parser.add_argument(
        "--moon-target-root",
        default="/tmp/moon_elk_full_plugin_diff",
        help="Base target dir for moon test runs.",
    )
    parser.add_argument(
        "--skip-ref-run",
        action="store_true",
        help="Skip running ELK-reference tests and parse existing reports only.",
    )
    parser.add_argument(
        "--ref-root",
        default="elk-reference/build",
        help="Working directory for the reference Maven command.",
    )
    parser.add_argument(
        "--elk-repo",
        default="elk-reference",
        help="Path to ELK reference repository root for tests.paths.elk-repo.",
    )
    parser.add_argument(
        "--models-repo",
        default="elk-models",
        help="Path to ELK models repository root for tests.paths.models-repo.",
    )
    parser.add_argument(
        "--ref-mvn-cmd",
        default=None,
        help="Override reference Maven command. By default, command is generated from local modules.",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    out_dir = Path(args.out_dir).resolve()
    moon_target_root = Path(args.moon_target_root)
    ref_root = (repo_root / args.ref_root).resolve()
    elk_repo = (repo_root / args.elk_repo).resolve()
    models_repo = (repo_root / args.models_repo).resolve()

    moon_results = run_moon_tests(repo_root, moon_target_root)

    ref_code: Optional[int] = None
    ref_output: Optional[str] = None
    if not args.skip_ref_run:
        if not elk_repo.exists():
            print(f"ELK repository path does not exist: {elk_repo}", file=sys.stderr)
            return 5
        if not models_repo.exists():
            print(
                f"Models repository path does not exist: {models_repo}. "
                "Clone https://github.com/eclipse-elk/elk-models first.",
                file=sys.stderr,
            )
            return 6
        reset_reference_reports(repo_root)
        ref_code, ref_output = run_reference_batch(
            ref_root,
            args.ref_mvn_cmd,
            repo_root,
            elk_repo,
            models_repo,
        )

    ref_results = parse_reference_reports(repo_root)
    report_json, report_md, mismatches = write_report(
        out_dir=out_dir,
        moon_results=moon_results,
        ref_results=ref_results,
        ref_run_code=ref_code,
        ref_run_output=ref_output,
        skip_ref_run=args.skip_ref_run,
    )

    print(f"Plugin pairs checked: {len(PLUGIN_TO_MOON)}")
    print(f"Mismatches: {mismatches}")
    print(f"Report (json): {report_json}")
    print(f"Report (md): {report_md}")

    if not args.skip_ref_run and ref_code != 0:
        print("Reference run failed; see report json output_head for details.", file=sys.stderr)
        return 3
    if not args.skip_ref_run and any(r.ok is None for r in ref_results.values()):
        print("Reference reports are incomplete for one or more test plugins.", file=sys.stderr)
        return 4
    if mismatches > 0:
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
