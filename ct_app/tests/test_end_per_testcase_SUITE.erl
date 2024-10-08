-module(test_end_per_testcase_SUITE).

-compile([export_all, nowarn_export_all]).

all() ->
    [{group, test_group}].

groups() ->
    [{test_group, [{repeat_until_all_ok, repeat_until_all_ok()}], test_cases()}].

test_cases() ->
    [test1].

init_per_suite(Config) ->
    Config.

end_per_suite(Config) -> Config.

init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, Config) ->
    Config.

init_per_testcase(_CaseName, Config) ->
    Config.

end_per_testcase(test1, Config) ->
     case test_number(test1) < 2 of
         true -> error(oops);
         _ -> ok
     end,
    Config;
end_per_testcase(_CaseName, Config) ->
    Config.

test1(_Config) ->
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
