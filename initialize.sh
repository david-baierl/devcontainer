#!/bin/bash

readonly wanted_line_key="LOCAL_WORKSPACE_FOLDER"
readonly wanted_line="${wanted_line_key}='$(basename $PWD)'"
readonly file=".devcontainer/.env"

echo "Writing ${wanted_line} to ${file}" >&2
if [[ -f "${file}" ]] && grep --quiet "^${wanted_line_key}=" "${file}"; then
    sed --in-place "s,^${wanted_line_key}=.*,${wanted_line}," "${file}"
else
    echo "${wanted_line}" >>"${file}"
fi