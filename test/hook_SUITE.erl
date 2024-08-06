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
    Res = os:cmd("../../../../ct_app/run_test.sh"),
    ct:pal("Res ~ts", [Res]),
    ok.
