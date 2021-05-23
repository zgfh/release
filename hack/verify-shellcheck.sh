#!/usr/bin/env bash

# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# CI script to run shellcheck
set -o errexit
set -o nounset
set -o pipefail

# cd to the repo root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "${REPO_ROOT}"

# upstream shellcheck latest stable image as of June 16th, 2020
SHELLCHECK_IMAGE="koalaman/shellcheck-alpine:v0.7.1"

# Find all shell scripts excluding:
# - Anything git-ignored - No need to lint untracked files.
# - ./_* - No need to lint output directories.
# - ./.git/* - Ignore anything in the git object store.
# - ./vendor* - Vendored code should be fixed upstream instead.
all_shell_scripts=()
while IFS=$'\n' read -r script;
  do git check-ignore -q "$script" || all_shell_scripts+=("$script");
done < <(grep -irl '#!.*sh' . --exclude-dir={_\*,.git\*,vendor\*})

# common arguments we'll pass to shellcheck
SHELLCHECK_OPTIONS=(
  # allow following sourced files that are not specified in the command,
  # we need this because we specify one file at at time in order to trivially
  # detect which files are failing
  "--external-sources"
  # disabled lint codes
  # 2330 - disabled due to https://github.com/koalaman/shellcheck/issues/1162
  "--exclude=2230"
  # set colorized output
  "--color=auto"
)

CONTAINER_RUNTIME=${CONTAINER_RUNTIME:-docker}

# actually shellcheck
"${CONTAINER_RUNTIME}" run \
  --rm -it -v "${REPO_ROOT}:${REPO_ROOT}" -w "${REPO_ROOT}" \
  "${SHELLCHECK_IMAGE}" \
  shellcheck "${SHELLCHECK_OPTIONS[@]}" "${all_shell_scripts[@]}"
