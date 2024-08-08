-module(hook_SUITE).

-compile([export_all, nowarn_export_all]).

-include_lib("common_test/include/ct.hrl").


all() ->
    [{group, test_group}].

groups() ->
    [{test_group, [], test_cases()}].

test_cases() ->
    [run_test,
     run_test2_repeat3,
     run_test2_repeat4].

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

run_test(_Config) ->
    Res = os:cmd(repo_dir("ct_app/run_test.sh test")),
    ct:pal("Res ~ts", [Res]),
    #{sum := Sum, gr_sum := GrSum} = read_summary("test"),
    [{total_ok, 2},
     {total_eventually_ok_tests, 4},
     {total_failed, 1}] = Sum,
    [{groups_summary, {2, 1}},
     {eventually_ok_tests, 4}] = GrSum,
    ok.

run_test2_repeat3(_Config) ->
    Res = os:cmd(repo_dir("ct_app/run_test.sh test2")),
    ct:pal("Res ~ts", [Res]),
    #{sum := Sum, gr_sum := GrSum} = read_summary("test2"),
    [{total_ok, 0},
     {total_eventually_ok_tests, 0},
     {total_failed, 1}] = Sum,
    [{groups_summary, {0, 1}},
     {eventually_ok_tests, 0}] = GrSum,
    ok.

run_test2_repeat4(_Config) ->
    Res = os:cmd("REPEAT=4 " ++ repo_dir("ct_app/run_test.sh test2")),
    ct:pal("Res ~ts", [Res]),
    #{sum := Sum, gr_sum := GrSum} = read_summary("test2"),
    [{total_ok, 1},
     {total_eventually_ok_tests, 3},
     {total_failed, 0}] = Sum,
    [{groups_summary, {1, 0}},
     {eventually_ok_tests, 3}] = GrSum,
    ok.


read_summary(Spec) ->
    {ok, Sum} = file:consult(repo_dir("ct_app/_build/test/logs/last/all_groups.summary")),
    [GrDir] = filelib:wildcard(repo_dir("ct_app/_build/test/logs/last/extras.tests." ++ Spec ++ "_SUITE.logs/*/groups.summary")),
    {ok, GrSum} = file:consult(GrDir),
    #{sum => Sum, gr_sum => GrSum}.

% ct_app/_build/test/logs/last/all_groups.summary
% {total_ok,2}.
% {total_eventually_ok_tests,4}.
% {total_failed,1}

% ct_app/_build/test/logs/last/extras.tests.test_SUITE.logs/run.2024-08-06_19.57.32/groups.summary
%{groups_summary,{2,1}}.
%{eventually_ok_tests,4}.

repo_dir(Dir) ->
    "../../../../" ++ Dir.
