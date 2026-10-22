"""Reserve a shared build number before the signing matrix, without store uploads.

Run only on main in the manually approved mobile-release environment. The floor
must be checked against BOTH store consoles before enabling the workflow.
Reserved numbers are burned even when packaging fails, including reruns.
"""

import json
import os
import re
import subprocess
from pathlib import Path

from mobile_artifacts import check_version, require


def main():
    require(os.environ.get("GITHUB_REF") == "refs/heads/main" and
            os.environ.get("GITHUB_EVENT_NAME") == "workflow_dispatch" and
            os.environ.get("GITHUB_RUN_ATTEMPT") == "1", "Start a new manual release run on main.")
    number = os.environ["BUILD_NUMBER"]
    check_version(number, os.environ["VERSION_NAME"])
    floor = os.environ.get("MOBILE_STORE_BUILD_FLOOR", "")
    require(re.fullmatch(r"[0-9]{1,4}", floor), "Set the verified store build-number floor first (0 for new listings).")
    repo = os.environ["GITHUB_REPOSITORY"]
    result = subprocess.run(["gh", "api", f"repos/{repo}/git/matching-refs/tags/mobile-build-"],
                            check=True, capture_output=True)
    refs = json.loads(result.stdout)
    used = [int(floor)]
    for ref in refs:
        match = re.fullmatch(r"refs/tags/mobile-build-([1-9][0-9]{0,3})", ref["ref"])
        require(match, "Unexpected build reservation tag; inspect before releasing.")
        used.append(int(match[1]))
    require(int(number) > max(used), "Build number must exceed every reserved or store-used number.")
    payload = json.dumps({"ref": f"refs/tags/mobile-build-{number}", "sha": os.environ["GITHUB_SHA"]}).encode()
    subprocess.run(["gh", "api", "--method", "POST", f"repos/{repo}/git/refs", "--input", "-"],
                   input=payload, check=True, capture_output=True)
    with Path(os.environ["GITHUB_OUTPUT"]).open("a") as output:
        output.write(f"number={number}\n")
    print(f"Reserved mobile build {number}. Never reuse this number, even if packaging fails.")


if __name__ == "__main__":
    try:
        main()
    except ValueError as error:
        raise SystemExit(str(error))
    except Exception:
        raise SystemExit("Build reservation failed. No signed build may proceed.")
