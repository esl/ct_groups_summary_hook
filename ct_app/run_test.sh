#!/usr/bin/env bash
set -e
cd "$( dirname "${BASH_SOURCE[0]}" )"

SPEC=$1

# Rebar3 is broken, so it fails with:
# {function_clause,
#     [{ct_run,run_all_specs,
#          [{error,
#               {"/Users/me/erlang/esl/ct_groups_summary_hook/test/ct_app/_build/test/extras/my.spec",
#                "no such file or directory"}}

# So we copy the spec manually :(
mkdir -p _build/test/extras/
cat $SPEC.spec hook.spec > spec.spec
cp spec.spec _build/test/extras/spec.spec

# Copy hook, so rebar could compile and load it.
cp ../src/ct_groups_summary_hook.erl tests/ct_groups_summary_hook.erl

rebar3 ct --spec=spec.spec
