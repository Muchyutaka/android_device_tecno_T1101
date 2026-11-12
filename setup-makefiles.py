#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
"""Regenerate vendor makefiles without re-extracting blobs.

Run from a synced ROM tree:
    device/tecno/T1101/setup-makefiles.py
or from the device tree root:
    ./setup-makefiles.py
"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ANDROID_ROOT = os.path.abspath(os.path.join(HERE, os.pardir, os.pardir, os.pardir))
EXTRACT_UTILS = os.path.join(ANDROID_ROOT, "tools", "extract-utils")

env = os.environ.copy()
env["PYTHONPATH"] = EXTRACT_UTILS + (os.pathsep + env["PYTHONPATH"] if env.get("PYTHONPATH") else "")

script = os.path.join(HERE, "extract-files.py")
os.execve(sys.executable, [sys.executable, script, "--regenerate_makefiles"] + sys.argv[1:], env)
