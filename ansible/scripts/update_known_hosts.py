#!/usr/bin/env python3
import json
import subprocess
from pathlib import Path

TF_DIR = Path(__file__).resolve().parents[2] / "devops-vm-terraform-libvirt"
KNOWN_HOSTS = Path.home() / ".ssh" / "known_hosts"

def tf_public_ips() -> list[str]:
    # expects terraform output: public_ips = { back = [ip], db = [ip] }
    p = subprocess.run(
        ["terraform", "output", "-json", "public_ips"],
        cwd=str(TF_DIR),
        check=True,
        capture_output=True,
        text=True,
    )
    data = json.loads(p.stdout)
    ips = []
    for name in ("back", "db"):
        lst = data.get(name) or []
        if lst:
            ips.append(lst[0])
    return ips

def run(cmd: list[str]) -> None:
    subprocess.run(cmd, check=False)

def main():
    KNOWN_HOSTS.parent.mkdir(parents=True, exist_ok=True)
    KNOWN_HOSTS.touch(exist_ok=True)

    ips = tf_public_ips()
    if not ips:
        raise SystemExit("No IPs found in terraform output 'public_ips'")

    for ip in ips:
        run(["ssh-keygen", "-R", ip, "-f", str(KNOWN_HOSTS)])
        # append new key
        p = subprocess.run(["ssh-keyscan", "-H", ip], capture_output=True, text=True)
        if p.stdout:
            with KNOWN_HOSTS.open("a") as f:
                f.write(p.stdout)

    print("Updated known_hosts for:", ", ".join(ips))

if __name__ == "__main__":
    main()
