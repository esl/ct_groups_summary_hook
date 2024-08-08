-module(hook_SUITE).

-compile([export_all, nowarn_export_all]).

-include_lib("common_test/include/ct.hrl").


all() ->
    [{group, test_group}].

groups() ->
    [{test_group, [], test_cases()}].

test_cases() ->
    [run_ct].

init_per_suite(Config) ->
    Config.

end_per_suite(Config) -> Config.

init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, Config) ->
    Config.

init_per_testcase(_CaseName, Config) ->
    Config.

end_per_testcase(_CaseName, Config) ->
    Config.


run_ct(_Config) ->
    Res = os:cmd(repo_dir("ct_app/run_test.sh")),
    ct:pal("Res ~ts", [Res]),
    {ok, Sum} = file:consult(repo_dir("ct_app/_build/test/logs/last/all_groups.summary")),
    [{total_ok, 2},
     {total_eventually_ok_tests, 4},
     {total_failed, 1}] = Sum,
    [GrDir] = filelib:wildcard(repo_dir("ct_app/_build/test/logs/last/extras.tests.test_SUITE.logs/*/groups.summary")),
    {ok, GrSum} = file:consult(GrDir),
    [{groups_summary, {2, 1}},
     {eventually_ok_tests, 4}] = GrSum,
    ok.

% ct_app/_build/test/logs/last/all_groups.summary
% {total_ok,2}.
% {total_eventually_ok_tests,4}.
% {total_failed,1}

% ct_app/_build/test/logs/last/extras.tests.test_SUITE.logs/run.2024-08-06_19.57.32/groups.summary
%{groups_summary,{2,1}}.
%{eventually_ok_tests,4}.

repo_dir(Dir) ->
    "../../../../" ++ Dir.
