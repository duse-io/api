#!/bin/bash
set -e

./script/wait_for_dependencies.sh
exec "$@"
