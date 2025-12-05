#!/bin/bash

set -euo pipefail

gio open $(gh browse -n) > /dev/null 2>&1 &
