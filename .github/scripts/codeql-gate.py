#!/usr/bin/env python3
"""Fail the build on high-severity CodeQL findings, without GitHub Advanced Security.

Uploading SARIF to the code-scanning API needs Advanced Security, which is a paid
add-on on a private repository. The analysis itself is free and already runs, so
this reads the SARIF the analyze step leaves on disk and applies the gate here.

The bar is `security-severity >= 7.0` (CVSS high and critical), matching what
`pnpm audit --prod --audit-level=high` already enforces for dependencies. Lower
findings are printed and the artifact keeps them, but they do not block a merge.

Restore the upload and delete this once Advanced Security is on: the hosted
version tracks findings over time and dismisses false positives, which a text
gate cannot do.
"""

from __future__ import annotations

import json
import os
import pathlib
import sys

# CVSS floor for a blocking finding. 7.0 is the bottom of "high".
BLOCKING_SEVERITY = 7.0


def rules_by_id(run: dict) -> dict[str, dict]:
    """Index a run's rule metadata by rule id.

    Severity lives on the rule, not the result, so every result has to be
    resolved back to the rule that produced it.
    """
    driver = run.get("tool", {}).get("driver", {})
    extensions = run.get("tool", {}).get("extensions", [])
    rules: dict[str, dict] = {}
    for source in [driver, *extensions]:
        for rule in source.get("rules", []) or []:
            if rule.get("id"):
                rules[rule["id"]] = rule
    return rules


def severity_of(rule: dict) -> float:
    """The rule's CVSS score, or 0.0 when it does not carry one."""
    raw = (rule.get("properties") or {}).get("security-severity")
    try:
        return float(raw)
    except (TypeError, ValueError):
        return 0.0


def location_of(result: dict) -> str:
    """A `path:line` for the result's first physical location."""
    locations = result.get("locations") or []
    if not locations:
        return "unknown"
    physical = locations[0].get("physicalLocation", {})
    path = physical.get("artifactLocation", {}).get("uri", "unknown")
    line = physical.get("region", {}).get("startLine")
    return f"{path}:{line}" if line else path


def main(argv: list[str]) -> int:
    directory = pathlib.Path(argv[1] if len(argv) > 1 else "sarif-results")
    files = sorted(directory.glob("*.sarif"))
    if not files:
        print(f"No SARIF produced in {directory}/ — the analysis did not run.", file=sys.stderr)
        return 1

    blocking: list[str] = []
    other = 0

    for path in files:
        report = json.loads(path.read_text(encoding="utf-8"))
        for run in report.get("runs", []):
            rules = rules_by_id(run)
            for result in run.get("results", []) or []:
                rule = rules.get(result.get("ruleId", ""), {})
                severity = severity_of(rule)
                message = (result.get("message") or {}).get("text", "").strip()
                line = f"{severity:>4.1f}  {result.get('ruleId')}  {location_of(result)}  {message}"
                if severity >= BLOCKING_SEVERITY:
                    blocking.append(line)
                else:
                    other += 1

    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    lines = [f"### CodeQL: {len(blocking)} blocking, {other} below the bar", ""]
    if blocking:
        lines += ["```", *blocking, "```"]
    else:
        lines.append(f"No finding at or above CVSS {BLOCKING_SEVERITY}.")
    if summary:
        pathlib.Path(summary).write_text("\n".join(lines) + "\n", encoding="utf-8")

    for line in blocking:
        print(line, file=sys.stderr)
    print(f"CodeQL: {len(blocking)} at or above CVSS {BLOCKING_SEVERITY}, {other} below it.")
    return 1 if blocking else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
