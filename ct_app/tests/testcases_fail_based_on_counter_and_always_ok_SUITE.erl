-module(testcases_fail_based_on_counter_and_always_ok_SUITE).

-compile([export_all, nowarn_export_all]).

all() ->
    [{group, test_group}].

groups() ->
    [{test_group, [{repeat_until_all_ok, repeat_until_all_ok()}], test_cases()}].

test_cases() ->
    [test1, test2, test3, always_ok].

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

always_ok(_Config) ->
    ok.

test1(_Config) ->
     case test_number(test1) of
         1 -> error(oops);
         _ -> ok
     end,
     ok.

test2(_Config) ->
     case test_number(test2) of
         2 -> error(oops);
         _ -> ok
     end,
     ok.

test3(_Config) ->
     case test_number(test3) of
         3 -> error(oops);
         _ -> ok
     end,
     ok.

%% Returns 1 for the first time, 2 for the second, and so on
test_number(Test) ->
    Key = {test_number, Test},
    N = persistent_term:get(Key, 0),
    persistent_term:put(Key, N + 1),
    N + 1.

repeat_until_all_ok() ->
    case os:getenv("REPEAT") of
        false -> 3;
        Str -> list_to_integer(Str)
    end.
