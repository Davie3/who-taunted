#!/usr/bin/env python3
"""Detect TOC Interface bumps and prepare the release PR for the TOC updater workflow.

Usage (from the repository root):
  toc_updater.py before   Snapshot tracked Interface values.
  toc_updater.py after    Compare with the snapshot; on change, write the changelogs and PR body.

Tracked expansions live in supported_expansions.json; changes to any other TOC are discarded.
p3lim/toc-interface-updater picks each TOC's game version from its filename suffix
(_Mists, _Wrath, ...), so the keys are only labels. Outputs go to $GITHUB_OUTPUT, or
stdout when run locally. Standard library only.

Retail/Mainline is excluded: WoW 12.0+ combat log API changes make the addon incompatible.
To re-enable it, add a "retail" entry (toc WhoTaunted_Mainline.toc, blizztrack "wow") to
supported_expansions.json and add the "mainline" label in toc-updater.yml.
"""

import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import uuid
from pathlib import Path
from string import Template
from urllib.error import HTTPError
from urllib.parse import quote
from urllib.request import Request, urlopen

HERE = Path(__file__).resolve().parent
EXPANSIONS = json.loads(
    (HERE / "supported_expansions.json").read_text(encoding="utf-8")
)
PR_TEMPLATE = HERE / "pr-body.md"

CHANGELOG = Path("CHANGELOG.md")
CHANGELOG_HISTORY = Path("CHANGELOG-HISTORY.md")
BLIZZTRACK_BASE = "https://blizztrack.com/view"
REPOSITORY = os.environ.get("GITHUB_REPOSITORY", "Davie3/who-taunted")
TEMP_DIR = Path(os.environ.get("RUNNER_TEMP", tempfile.gettempdir()))
SNAPSHOT = TEMP_DIR / "toc-before.json"

INTERFACE_RE = re.compile(r"^## Interface:[ \t]*(.*?)[ \t]*$", re.MULTILINE)
STABLE_TAG_RE = re.compile(r"^v(\d+)\.(\d+)(?:\.(\d+))?$")


def git(*args, check=True):
    return subprocess.run(["git", *args], check=check, capture_output=True, text=True)


def set_output(name, value):
    path = os.environ.get("GITHUB_OUTPUT")
    if not path:
        print(f"{name}={value}")
        return
    with open(path, "a", encoding="utf-8") as f:
        if "\n" in value:
            delimiter = f"EOF_{uuid.uuid4().hex}"
            f.write(f"{name}<<{delimiter}\n{value}\n{delimiter}\n")
        else:
            f.write(f"{name}={value}\n")


def read_interface(toc):
    match = INTERFACE_RE.search(Path(toc).read_text(encoding="utf-8"))
    return match.group(1) if match else ""


def snapshot():
    return {key: read_interface(exp["toc"]) for key, exp in EXPANSIONS.items()}


def restore_untracked_tocs():
    tracked = {exp["toc"] for exp in EXPANSIONS.values()}
    for toc in sorted(Path(".").glob("*.toc")):
        if toc.name not in tracked:
            git("checkout", "HEAD", "--", toc.name, check=False)


def apply_static_interfaces():
    for exp in EXPANSIONS.values():
        static = exp.get("static_interfaces", [])
        if not static:
            continue
        toc = Path(exp["toc"])
        current = [v.strip() for v in read_interface(toc).split(",") if v.strip()]
        missing = [v for v in static if v not in current]
        if missing:
            line = "## Interface: " + ", ".join(missing + current)
            text = INTERFACE_RE.sub(
                lambda _: line, toc.read_text(encoding="utf-8"), count=1
            )
            toc.write_text(text, encoding="utf-8")


def interface_to_version(value):
    versions = []
    for interface in (v.strip() for v in value.split(",")):
        if not interface:
            continue
        major_len = 2 if len(interface) == 6 else 1
        major = int(interface[:major_len])
        minor = int(interface[major_len : major_len + 2])
        patch = int(interface[major_len + 2 : major_len + 4])
        versions.append(f"{major}.{minor}.{patch}")
    return ", ".join(versions)


def next_version():
    stable = []
    for tag in git("tag", "--list", "v*").stdout.split():
        match = STABLE_TAG_RE.match(tag)
        if match:
            stable.append(tuple(int(part or 0) for part in match.groups()))
    if not stable:
        sys.exit("No stable vX.Y[.Z] tags found.")
    major, minor, patch = max(stable)
    return f"v{major}.{minor}.{patch + 1}"


def branch_exists(branch):
    request = Request(
        f"https://api.github.com/repos/{REPOSITORY}/branches/{quote(branch)}"
    )
    request.add_header("Accept", "application/vnd.github+json")
    token = os.environ.get("GH_TOKEN")
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    try:
        with urlopen(request, timeout=30):
            return True
    except HTTPError as error:
        if error.code == 404:
            return False
        raise


def write_changelogs(version, before, after):
    lines = [f"## [{version}](https://github.com/{REPOSITORY}/releases/tag/{version})"]
    for key, exp in EXPANSIONS.items():
        if before[key] != after[key]:
            lines.append(
                f"- {interface_to_version(after[key])} {exp['name']} compatibility."
            )
    entry = "\n".join(lines) + "\n"
    CHANGELOG.write_text(entry, encoding="utf-8")
    CHANGELOG_HISTORY.write_text(
        entry + "\n" + CHANGELOG_HISTORY.read_text(encoding="utf-8"), encoding="utf-8"
    )
    return "\n".join(lines[1:])


def write_pr_body(version, branch, changelog, before, after):
    table = "\n".join(
        f"| {exp['toc']} | `{before[key]}` | `{after[key]}` |"
        for key, exp in EXPANSIONS.items()
    )
    blizztrack = "\n".join(
        f"- [ ] Review [{exp['name']} BlizzTrack]({BLIZZTRACK_BASE}/{exp['blizztrack']}?type=versions)"
        for exp in EXPANSIONS.values()
    )
    body = Template(PR_TEMPLATE.read_text(encoding="utf-8")).substitute(
        table=table,
        changelog=changelog,
        blizztrack=blizztrack,
        version=version,
        branch=branch,
        repository=REPOSITORY,
    )
    path = TEMP_DIR / "toc-pr-body.md"
    path.write_text(body, encoding="utf-8")
    return path


def cmd_before():
    SNAPSHOT.write_text(json.dumps(snapshot()), encoding="utf-8")


def cmd_after():
    before = json.loads(SNAPSHOT.read_text(encoding="utf-8"))
    restore_untracked_tocs()
    apply_static_interfaces()
    after = snapshot()

    if before == after:
        print("No Interface changes.")
        set_output("create", "false")
        return

    digest = hashlib.md5(json.dumps(after, sort_keys=True).encode()).hexdigest()
    branch = f"toc-update-{digest}"
    if branch_exists(branch):
        print(f"Branch {branch} already exists.")
        set_output("create", "false")
        return

    version = next_version()
    changelog = write_changelogs(version, before, after)
    body_path = write_pr_body(version, branch, changelog, before, after)
    print(f"New version: {version}")
    set_output("create", "true")
    set_output("branch", branch)
    set_output("version", version)
    set_output("body_path", str(body_path))


if __name__ == "__main__":
    commands = {"before": cmd_before, "after": cmd_after}
    if len(sys.argv) != 2 or sys.argv[1] not in commands:
        sys.exit(f"Usage: {sys.argv[0]} {{{'|'.join(commands)}}}")
    commands[sys.argv[1]]()
