-module(hook_SUITE).

-compile([export_all, nowarn_export_all]).

-include_lib("common_test/include/ct.hrl").


all() ->
    [{group, test_group}].

groups() ->
    [{test_group, [], test_cases()}].

test_cases() ->
    [run_original_test,
     run_testcases_fail_based_on_counter_repeat3,
     run_testcases_fail_based_on_counter_repeat4,
     run_testcases_fail_based_on_counter_and_always_ok_repeat4,
     run_test_end_per_testcase_fails].

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

run_original_test(_Config) ->
    %% Original tests from big_suite, tests everything.
    Suite = "original_test",
    Res = os:cmd(repo_dir("ct_app/run_test.sh " ++ Suite)),
    ct:pal("Res ~ts", [Res]),
    #{sum := Sum, gr_sum := GrSum} = read_summary(Suite),
    Failed = lists:duplicate(13, {original_test_SUITE, failing_tc_3}),
    %% total_ok and total_failed is a group count
    [{total_ok, 2},
     {total_eventually_ok_tests, 4},
     {total_failed, 1},
     {total_end_per_testcase_failures, 1},
     {end_per_testcase_failures, Failed}] = Sum,
    [{groups_summary, {2, 1}},
     {eventually_ok_tests, 4},
     {end_per_testcase_failures, 1}] = GrSum,
    ["CT results:",
     "    2 groups passed",
     "    1 groups failed",
     "    4 tests eventually passed",
     "    1 tests with end_per_testcase failed",
     "    32 tests passed",
     "    17 tests failed",
     "    33 tests skipped by user",
     "    40 tests skipped automatically",
     "Failing the test due to auto skipped cases",
     "Failing the test due to failed rerun groups",
     "Failing the test due to failed test cases",
     "Failing the test due to failed end_per_testcase",
     "CODE=55"] = summarise_results(),
    ok.

run_testcases_fail_based_on_counter_repeat3(_Config) ->
    %% Just 3 tests, each failing when its name matches
    %% how many times we execute (repeat) the group.
    Suite = "testcases_fail_based_on_counter",
    Res = os:cmd(repo_dir("ct_app/run_test.sh " ++ Suite)),
    ct:pal("Res ~ts", [Res]),
    #{sum := Sum, gr_sum := GrSum} = read_summary(Suite),
    [{total_ok, 0},
     {total_eventually_ok_tests, 0},
     {total_failed, 1},
     {total_end_per_testcase_failures, 0},
     {end_per_testcase_failures, []}] = Sum,
    [{groups_summary, {0, 1}},
     {eventually_ok_tests, 0},
     {end_per_testcase_failures, 0}] = GrSum,
    ["CT results:",
     "    0 groups passed",
     "    1 groups failed",
     "    0 tests eventually passed",
     "    0 tests with end_per_testcase failed",
     "    6 tests passed",
     "    3 tests failed","    0 tests skipped by user",
     "    0 tests skipped automatically",
     "No test groups were executed successfully",
     "Failing the test due to failed rerun groups",
     "Failing the test due to failed test cases",
     "CODE=53"] = summarise_results(),
    ok.

run_testcases_fail_based_on_counter_repeat4(_Config) ->
    %% 3 times we fail, the last time we are ok.
    Suite = "testcases_fail_based_on_counter",
    Res = os:cmd("REPEAT=4 " ++ repo_dir("ct_app/run_test.sh " ++ Suite)),
    ct:pal("Res ~ts", [Res]),
    #{sum := Sum, gr_sum := GrSum} = read_summary(Suite),
    [{total_ok, 1},
     {total_eventually_ok_tests, 3},
     {total_failed, 0},
     {total_end_per_testcase_failures, 0},
     {end_per_testcase_failures, []}] = Sum,
    [{groups_summary, {1, 0}},
     {eventually_ok_tests, 3},
     {end_per_testcase_failures, 0}] = GrSum,
    ["CT results:",
     "    1 groups passed",
     "    0 groups failed",
     "    3 tests eventually passed",
     "    0 tests with end_per_testcase failed",
     "    9 tests passed",
     "    3 tests failed","    0 tests skipped by user",
     "    0 tests skipped automatically"]
     = summarise_results(),
    ok.

run_testcases_fail_based_on_counter_and_always_ok_repeat4(_Config) ->
    %% We do not count always passing tests at all.
    Suite = "testcases_fail_based_on_counter_and_always_ok",
    Res = os:cmd("REPEAT=4 " ++ repo_dir("ct_app/run_test.sh " ++ Suite)),
    ct:pal("Res ~ts", [Res]),
    #{sum := Sum, gr_sum := GrSum} = read_summary(Suite),
    [{total_ok, 1},
     {total_eventually_ok_tests, 3},
     {total_failed, 0},
     {total_end_per_testcase_failures, 0},
     {end_per_testcase_failures, []}] = Sum,
    [{groups_summary, {1, 0}},
     {eventually_ok_tests, 3},
     {end_per_testcase_failures, 0}] = GrSum,
    ["CT results:",
     "    1 groups passed",
     "    0 groups failed",
     "    3 tests eventually passed",
     "    0 tests with end_per_testcase failed",
     "    13 tests passed",
     "    3 tests failed",
     "    0 tests skipped by user",
     "    0 tests skipped automatically"] = summarise_results(),
    ok.

run_test_end_per_testcase_fails(_Config) ->
    Res = os:cmd(repo_dir("ct_app/run_test.sh test_end_per_testcase")),
    ct:pal("Res ~ts", [Res]),
    #{sum := Sum, gr_sum := GrSum} = read_summary("test_end_per_testcase"),
    [{total_ok, 1},
     {total_eventually_ok_tests, 0},
     {total_failed, 0},
     {total_end_per_testcase_failures, 1},
     {end_per_testcase_failures, [{test_end_per_testcase_SUITE, test1}]}] = Sum,
    [{groups_summary, {1, 0}},
     {eventually_ok_tests, 0},
     {end_per_testcase_failures, 1}] = GrSum,
    ["CT results:",
     "    1 groups passed",
     "    0 groups failed",
     "    0 tests eventually passed",
     "    1 tests with end_per_testcase failed",
     "    1 tests passed",
     "    0 tests failed",
     "    0 tests skipped by user",
     "    0 tests skipped automatically",
     "Failing the test due to failed end_per_testcase",
     "CODE=1"] = summarise_results(),
    ok.

read_summary(Spec) ->
    {ok, Sum} = file:consult(repo_dir("ct_app/_build/test/logs/last/all_groups.summary")),
    [GrDir] = filelib:wildcard(repo_dir("ct_app/_build/test/logs/last/extras.tests." ++ Spec ++ "_SUITE.logs/*/groups.summary")),
    {ok, GrSum} = file:consult(GrDir),
    #{sum => Sum, gr_sum => GrSum}.

repo_dir(Dir) ->
    "../../../../" ++ Dir.

summarise_results() ->
    Res = os:cmd(summarise_results_cmd()),
    string:tokens(Res, "\n").

summarise_results_cmd() ->
    "cd " ++ repo_dir("") ++ " && tools/summarise-ct-results ct_app/_build/test/logs/last/ || echo CODE=$?".
