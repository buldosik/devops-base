#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

TF_DIR = Path(__file__).resolve().parents[1] / "devops-vm-terraform-libvirt"

def get_tf_output():
    cmd = ["terraform", "output", "-json"]
    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        cwd=str(TF_DIR),          # ВАЖНО: запускаем terraform из TF-директории
    )

    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)
        return {}

    return json.loads(result.stdout)


def build_inventory(tf_output):
    # берём public_ips из Terraform
    public = tf_output.get("public_ips", {}).get("value", {})

    def first_ip(name):
        ips = public.get(name) or []
        return ips[0] if ips else None

    back_ip = first_ip("back")
    db_ip   = first_ip("db")
    dev_ip  = first_ip("dev")

    inventory = {
        "back": {
            "hosts": [back_ip],
            "vars": {"ansible_user": "devops"},
        },
        "db": {
            "hosts": [db_ip],
            "vars": {"ansible_user": "devops"},
        },
        "dev": {
            "hosts": [dev_ip],
            "vars": {"ansible_user": "devops"},
        },
        "_meta": {
            "hostvars": {}
        }
    }

    return inventory



def main():
    # If Ansible asks for --list
    if "--list" in sys.argv:
        tf = get_tf_output()
        inv = build_inventory(tf)
        print(json.dumps(inv, indent=2))
        return

    # If Ansible asks for --host <hostname>
    if "--host" in sys.argv:
        print(json.dumps({}))  # Optional, not used
        return


if __name__ == "__main__":
    main()
