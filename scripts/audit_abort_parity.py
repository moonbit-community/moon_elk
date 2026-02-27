#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple


RE_ABORT = re.compile(r"\babort\(")
RE_ABORT_STRING = re.compile(r'abort\("([^"]*)"\)')
RE_FN = re.compile(r"^\s*(?:pub\s+)?fn\s+([A-Za-z0-9_:.]+)")
REF_EXTS = {".java", ".xtend", ".xtext"}
ACRONYMS = {
    "bk": "BK",
    "dfs": "DFS",
    "gmf": "GMF",
    "json": "JSON",
    "ui": "UI",
    "ide": "IDE",
    "api": "API",
    "xml": "XML",
    "svg": "SVG",
    "id": "ID",
}


@dataclass
class AbortRow:
    file: str
    line: int
    function: Optional[str]
    is_test: bool
    line_text: str
    message_literal: Optional[str]
    candidate_ref_files: List[str]
    matched_ref_files: List[str]
    method_match_files: List[str]
    method_token: Optional[str]
    reference_evidence: List[str]
    status: str


def to_camel(name: str) -> str:
    parts = [p for p in name.split("_") if p]
    if not parts:
        return ""
    if parts[0] == "i" and len(parts) > 1:
        return "I" + "".join(ACRONYMS.get(p, p[:1].upper() + p[1:]) for p in parts[1:])
    return "".join(ACRONYMS.get(p, p[:1].upper() + p[1:]) for p in parts)


def to_lower_camel(name: str) -> str:
    parts = [p for p in name.split("_") if p]
    if not parts:
        return ""
    head = parts[0]
    tail = "".join(p[:1].upper() + p[1:] for p in parts[1:])
    return head + tail


def is_test_file(path: Path) -> bool:
    return path.name.endswith("_test.mbt") or path.name.endswith("_wbtest.mbt")


def class_name_candidates(stem: str, is_test: bool) -> List[str]:
    tokens = [p for p in stem.split("_") if p]
    candidates: List[str] = []

    def add(name: str) -> None:
        if name:
            candidates.append(name)

    if is_test:
        if stem.endswith("_test"):
            base_tokens = tokens[:-1]
        elif stem.endswith("_wbtest"):
            base_tokens = tokens[:-1]
        else:
            base_tokens = tokens
        for i in range(len(base_tokens)):
            add(to_camel("_".join(base_tokens[i:])) + "Test")
        add(to_camel(stem))
    else:
        for i in range(len(tokens)):
            add(to_camel("_".join(tokens[i:])))

    # remove duplicates while preserving order
    seen = set()
    out: List[str] = []
    for c in candidates:
        if c not in seen:
            seen.add(c)
            out.append(c)
    return out


def method_token_from_fn(fn_name: Optional[str]) -> Optional[str]:
    if fn_name is None:
        return None
    raw = fn_name.split("::")[-1]
    token = to_lower_camel(raw)
    return token or None


def receiver_type_from_fn(fn_name: Optional[str]) -> Optional[str]:
    if fn_name is None or "::" not in fn_name:
        return None
    receiver = fn_name.split("::")[0].strip()
    return receiver or None


def receiver_class_candidates(receiver: Optional[str]) -> List[str]:
    if receiver is None:
        return []
    candidates = [receiver]
    if receiver.endswith("Builder") and len(receiver) > len("Builder"):
        candidates.append(receiver[: -len("Builder")])
    if receiver.startswith("I") and len(receiver) > 1:
        base = receiver[1:]
        candidates.append(base)
        candidates.append("Basic" + base)
        if base.endswith("ElkProgressMonitor"):
            candidates.append("BasicProgressMonitor")

    seen = set()
    out: List[str] = []
    for name in candidates:
        if name and name not in seen:
            seen.add(name)
            out.append(name)
    return out


def index_reference_files(ref_root: Path) -> Dict[str, List[Path]]:
    by_name: Dict[str, List[Path]] = {}
    for path in ref_root.rglob("*"):
        if not path.is_file() or path.suffix not in REF_EXTS:
            continue
        by_name.setdefault(path.name, []).append(path)
    return by_name


def load_lines(path: Path) -> List[str]:
    return path.read_text(encoding="utf-8", errors="ignore").splitlines()


def collect_abort_rows(repo_root: Path, ref_root: Path) -> List[AbortRow]:
    src_root = repo_root / "src"
    ref_index = index_reference_files(ref_root)
    ref_cache: Dict[Path, List[str]] = {}
    method_global_cache: Dict[str, List[Path]] = {}
    ref_all_files: List[Path] = []
    seen_ref = set()
    for paths in ref_index.values():
        for path in paths:
            key = str(path)
            if key not in seen_ref:
                seen_ref.add(key)
                ref_all_files.append(path)

    rows: List[AbortRow] = []
    for mbt in sorted(src_root.rglob("*.mbt")):
        lines = load_lines(mbt)
        last_fn: Optional[str] = None
        test_file = is_test_file(mbt)
        stem = mbt.stem
        class_candidates = class_name_candidates(stem, test_file)
        candidate_ref_paths: List[Path] = []
        for cls in class_candidates:
            candidate_ref_paths.extend(ref_index.get(cls + ".java", []))
            candidate_ref_paths.extend(ref_index.get(cls + ".xtend", []))
            candidate_ref_paths.extend(ref_index.get(cls + ".xtext", []))

        # dedupe candidate paths
        seen_paths = set()
        dedup_candidates: List[Path] = []
        for p in candidate_ref_paths:
            key = str(p)
            if key not in seen_paths:
                seen_paths.add(key)
                dedup_candidates.append(p)
        candidate_ref_paths = dedup_candidates

        for idx, line in enumerate(lines, 1):
            fn_match = RE_FN.match(line)
            if fn_match is not None:
                last_fn = fn_match.group(1)

            if RE_ABORT.search(line) is None:
                continue

            msg_match = RE_ABORT_STRING.search(line)
            message = msg_match.group(1) if msg_match is not None else None
            method_token = method_token_from_fn(last_fn)
            receiver = receiver_type_from_fn(last_fn)
            line_candidates: List[Path] = list(candidate_ref_paths)
            for receiver_cls in receiver_class_candidates(receiver):
                line_candidates.extend(ref_index.get(receiver_cls + ".java", []))
                line_candidates.extend(ref_index.get(receiver_cls + ".xtend", []))
                line_candidates.extend(ref_index.get(receiver_cls + ".xtext", []))

            # dedupe line candidates
            seen_line_paths = set()
            dedup_line_candidates: List[Path] = []
            for p in line_candidates:
                key = str(p)
                if key not in seen_line_paths:
                    seen_line_paths.add(key)
                    dedup_line_candidates.append(p)
            line_candidates = dedup_line_candidates

            if not line_candidates and method_token is not None:
                if method_token not in method_global_cache:
                    token_pattern = re.compile(rf"\b{re.escape(method_token)}\s*\(")
                    method_candidates: List[Tuple[int, Path]] = []
                    moon_tokens = set(str(mbt.relative_to(repo_root)).split("/"))
                    for ref_path in ref_all_files:
                        if ref_path not in ref_cache:
                            ref_cache[ref_path] = load_lines(ref_path)
                        ref_lines = ref_cache[ref_path]
                        joined = "\n".join(ref_lines)
                        if token_pattern.search(joined) is None:
                            continue
                        ref_tokens = set(str(ref_path.relative_to(repo_root)).split("/"))
                        score = len(moon_tokens.intersection(ref_tokens))
                        method_candidates.append((score, ref_path))
                    method_candidates.sort(
                        key=lambda item: (-item[0], len(str(item[1]))),
                    )
                    method_global_cache[method_token] = [p for _, p in method_candidates[:3]]
                line_candidates = method_global_cache[method_token]

            matched_files: List[str] = []
            method_files: List[str] = []
            evidence: List[str] = []

            for ref_path in line_candidates:
                if ref_path not in ref_cache:
                    ref_cache[ref_path] = load_lines(ref_path)
                ref_lines = ref_cache[ref_path]
                joined = "\n".join(ref_lines)
                rel = str(ref_path.relative_to(repo_root))
                if message is not None and message in joined:
                    matched_files.append(rel)
                    for ln, txt in enumerate(ref_lines, 1):
                        if message in txt:
                            evidence.append(f"{rel}:{ln}:{txt.strip()}")
                            break

                if method_token is not None:
                    found_token = False
                    found_contract_for_file = False
                    for ln, txt in enumerate(ref_lines, 1):
                        if re.search(rf"\b{re.escape(method_token)}\s*\(", txt):
                            found_token = True
                            if rel not in method_files:
                                method_files.append(rel)
                            start = max(0, ln - 1)
                            end = min(len(ref_lines), ln + 60)
                            for cn in range(start, end):
                                contract_line = ref_lines[cn]
                                if "throw " in contract_line or "assert " in contract_line:
                                    evidence.append(
                                        f"{rel}:{cn + 1}:{contract_line.strip()}"
                                    )
                                    found_contract_for_file = True
                                    break
                            if found_contract_for_file:
                                break
                    if found_token and not found_contract_for_file:
                        # Keep a marker only if no matching method occurrence had
                        # visible throw/assert contracts nearby.
                        first_ln = 0
                        for ln, txt in enumerate(ref_lines, 1):
                            if re.search(rf"\b{re.escape(method_token)}\s*\(", txt):
                                first_ln = ln
                                break
                        evidence.append(f"{rel}:{first_ln}:method:{method_token}")

            if message is not None and matched_files:
                status = "message_matched_in_reference_file"
            elif method_files and any("throw " in e or "assert " in e for e in evidence):
                status = "method_mapped_with_contract_evidence"
            elif method_files:
                status = "method_mapped_check_contract"
            elif candidate_ref_paths:
                status = "file_mapped_but_no_direct_match"
            else:
                status = "reference_file_not_found"

            rows.append(
                AbortRow(
                    file=str(mbt.relative_to(repo_root)),
                    line=idx,
                    function=last_fn,
                    is_test=test_file,
                    line_text=line.strip(),
                    message_literal=message,
                    candidate_ref_files=[
                        str(p.relative_to(repo_root)) for p in line_candidates
                    ],
                    matched_ref_files=matched_files,
                    method_match_files=method_files,
                    method_token=method_token,
                    reference_evidence=evidence,
                    status=status,
                )
            )

    return rows


def summarize(rows: Sequence[AbortRow]) -> Dict[str, object]:
    status_count: Dict[str, int] = {}
    for row in rows:
        status_count[row.status] = status_count.get(row.status, 0) + 1

    return {
        "total": len(rows),
        "runtime": sum(1 for x in rows if not x.is_test),
        "test": sum(1 for x in rows if x.is_test),
        "with_message_literal": sum(1 for x in rows if x.message_literal is not None),
        "status_count": status_count,
    }


def to_markdown(rows: Sequence[AbortRow], summary: Dict[str, object]) -> str:
    lines: List[str] = []
    lines.append("# Abort Parity Audit")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- total: {summary['total']}")
    lines.append(f"- runtime: {summary['runtime']}")
    lines.append(f"- test: {summary['test']}")
    lines.append(f"- with_message_literal: {summary['with_message_literal']}")
    lines.append("- status_count:")
    for k, v in sorted(summary["status_count"].items()):  # type: ignore[index]
        lines.append(f"  - {k}: {v}")
    lines.append("")
    lines.append("## Rows")
    lines.append("")
    lines.append(
        "| file | line | fn | status | message | candidate_ref_files | matched_ref_files |"
    )
    lines.append("|---|---:|---|---|---|---|---|")
    for row in rows:
        msg = row.message_literal or ""
        fn = row.function or ""
        candidates = "<br>".join(row.candidate_ref_files)
        matched = "<br>".join(row.matched_ref_files or row.method_match_files)
        lines.append(
            f"| {row.file} | {row.line} | {fn} | {row.status} | {msg} | {candidates} | {matched} |"
        )
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    ref_root = repo_root / "elk-reference"
    out_dir = repo_root / "artifacts" / "abort_parity"
    out_dir.mkdir(parents=True, exist_ok=True)

    rows = collect_abort_rows(repo_root, ref_root)
    summary = summarize(rows)

    (out_dir / "abort_parity_report.json").write_text(
        json.dumps(
            {
                "summary": summary,
                "rows": [asdict(r) for r in rows],
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )
    (out_dir / "abort_parity_report.md").write_text(
        to_markdown(rows, summary),
        encoding="utf-8",
    )
    print(json.dumps(summary, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
