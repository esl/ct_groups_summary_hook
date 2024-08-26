%% @doc Count successful and failed groups in the test suite.
%%
%% Use by adding the following line to `test.spec':
%% `{ct_hooks, [ct_results_summary_hook]}.'
%%
%% @author Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>
%% Created: Fri Jun 1 12:59:12 2018 +0200
-module(ct_groups_summary_hook).

%% Callbacks
-export([id/1,
         init/2,
         pre_init_per_suite/3,
         post_end_per_suite/4,
         post_end_per_group/4,
         post_end_per_testcase/5,
         on_tc_skip/3,
         terminate/1]).


-include_lib("common_test/include/ct.hrl").

-record(group_status, {status = ok :: ok | failed,
                       n_failed = 0 :: pos_integer(),
                       failed = [] :: list()}).

%% @doc Return a unique id for this CTH.
id(_Opts) ->
    "ct_results_summary_hook_001".

%% @doc Always called before any other callback function. Use this to initiate
%% any common state.
init(_Id, Opts) ->
    {ok, #{logs => proplists:get_value(logs, Opts, false),
           total_ok => 0,
           total_failed => 0,
           total_eventually_ok_tests => 0,
           %% end_per_testcase_failures contains failed end_per_testcase for all suites
           end_per_testcase_failures => []}}.

pre_init_per_suite(Suite, Config, State) ->
    log(State, "pre_init_per_suite config: ~p", [Config]),
    log(State, "pre_init_per_suite state: ~p", [State]),
    %% Start with an empty CT hook state for each suite.
    {Config, State#{current_suite => Suite, Suite => #{}}}.

post_end_per_suite(_SuiteName, Config, Return, State) ->
    log(State, "post_end_per_suite config: ~p", [Config]),
    log(State, "post_end_per_suite state: ~p", [State]),
    log(State, "post_end_per_suite return: ~p", [Return]),
    NewState = write_groups_summary(Config, State),
    {Return, NewState}.

post_end_per_group(GroupName, Config, Return, State) ->
    log(State, "post_end_per_group config: ~p", [Config]),
    log(State, "post_end_per_group state: ~p", [State]),
    log(State, "post_end_per_group return: ~p", [Return]),
    State1 = update_group_status(GroupName, Config, State),
    log(State, "NewState: ~p", [State1]),
    {Return, State1}.

post_end_per_testcase(SuiteName, TestcaseName, Config, Return, State) ->
    log(State, "post_end_per_testcase testcase: ~p ~p", [SuiteName, TestcaseName]),
    log(State, "post_end_per_testcase config: ~p", [Config]),
    log(State, "post_end_per_testcase state: ~p", [State]),
    log(State, "post_end_per_testcase return: ~p", [Return]),
    case Return of
        {failed, _} ->
            #{end_per_testcase_failures := EPT} = State,
            %% There is no way to fail the testcase from end_per_testcase.
            {Return, State#{end_per_testcase_failures => [{SuiteName, TestcaseName} | EPT]}};
        _ ->
            {Return, State}
    end.

%% @doc Called when a test case is skipped by either user action
%% or due to an init function failing.
on_tc_skip(_TC, Reason, State) ->
    case Reason of
        %% Just quit if files were not build correctly
        {tc_user_skip, "Make failed"} -> erlang:halt(1);
        _                             -> State
    end.

terminate(#{total_ok := OK, total_eventually_ok_tests := TotalEventuallyOK,
            total_failed := TotalFailed, end_per_testcase_failures := EPT} = State) ->
    Content = io_lib:format("~p.~n~p.~n~p.~n~p.~n~p.~n",
                            [{total_ok, OK},
                             {total_eventually_ok_tests, TotalEventuallyOK},
                             {total_failed, TotalFailed},
                             {total_end_per_testcase_failures, length(lists:usort(EPT))},
                             {end_per_testcase_failures, EPT}]),
    ok = file:write_file("all_groups.summary", Content),
    State.

%% @doc If the group property repeat_until_all_ok is enabled,
%% then update the outcome of this group in State.
%% In other words, if a previous run of this group failed,
%% and this one succeeded, State will be updated to reflect success.
update_group_status(GroupName, Config, State) ->
    case lists:keyfind(tc_group_properties, 1, Config) of
        false -> State;
        {tc_group_properties, Properties} ->
            GroupNameWPath = group_name_with_path(GroupName, Config),
            GroupResult = ?config(tc_group_result, Config),
            Failed = proplists:get_value(failed, GroupResult, []),
            Status = case Failed of
                         [] ->
                             %% If there are no failed cases, then the only skipped cases present
                             %% in the group result are user-skipped cases.
                             %% In this case we do not want to fail the whole group.
                             ok;
                         _ ->
                             %% If there are failed cases, it doesn't matter if the skipped cases
                             %% are user-skipped or auto-skipped (which might depend on `sequence`
                             %% group property being enabled or not) - we fail in either case.
                             failed
                     end,
            RepeatFlag = proplists:is_defined(repeat_until_all_ok, Properties),
            do_update_group_status(RepeatFlag, Status, GroupNameWPath, Failed, State)
    end.


do_update_group_status(RepeatFlag, Status, GroupNameWPath, Failed,
                       #{current_suite := CurrentSuite} = State) ->
    SuiteState = maps:get(CurrentSuite, State),
    NewGroupStatus = #group_status{status = Status, n_failed = length(Failed),
                                   failed = Failed},
    NewSuiteState = case maps:get(GroupNameWPath, SuiteState, undefined) of
                        undefined when RepeatFlag =:= true ->
                            %% repeat_until_all_ok flag works like a counter.
                            %% it decreases with every subsequent run, and it
                            %% is not set at all on the last attempt. so we
                            %% want add a new group status info only if flag
                            %% is set. otherwise, we want to update the status
                            %% only if group is already stored.
                            SuiteState#{GroupNameWPath => NewGroupStatus};
                        undefined ->
                            SuiteState;
                        PrevGroupStatus ->
                            SuiteState#{GroupNameWPath := merge_group_status(PrevGroupStatus,
                                                                             NewGroupStatus)}
                    end,
    State#{CurrentSuite := NewSuiteState}.

merge_group_status(#group_status{failed = PrevFailed,
                                 n_failed = PrevNFailed} = _PrevGroupStatus,
                   #group_status{status = NewStatus, failed = NewFailed,
                                 n_failed = NewNFailed} = _NewGroupStatus) ->
    MergedFailed = lists:umerge(lists:usort(PrevFailed),lists:usort(NewFailed)),
    %% we need to count the number of fails, not the number of failed test cases
    %% (i.e. length(MergedFailed)). that's because we compare it with the number
    %% of failed test cases reported in suite.summary files, for more details see
    %% summarise-ct-results script.
    MergedNFailed = PrevNFailed + NewNFailed,
    #group_status{status = NewStatus, n_failed = MergedNFailed, failed = MergedFailed}.


group_name_with_path(GroupName, Config) ->
    case lists:keyfind(tc_group_path, 1, Config) of
        false -> GroupName;
        {tc_group_path, PathProperties} ->
            [ proplists:get_value(name, ParentGroup)
              || ParentGroup <- PathProperties ] ++ [GroupName]
    end.

%% @doc Write down the number successful and failing groups in a per-suite groups.summary file.
write_groups_summary(Config, #{total_ok := TOK, total_failed := TFailed,
                               total_eventually_ok_tests := TEvOK,
                               current_suite := CurrentSuite,
                               end_per_testcase_failures := EPT} = State) ->
    GroupState = maps:get(CurrentSuite, State),
    {Ok, Failed, FailedTests} = maps:fold(fun acc_groups_summary/3, {0, 0, 0}, GroupState),
    PrivDir = ?config(priv_dir, Config),
    SuiteEPT = [Case || {Suite, Case} <- EPT, Suite =:= CurrentSuite],
    case PrivDir of
        undefined ->
            error(priv_dir_undefined);
        _ ->
            SuiteDir = filename:dirname(string:strip(PrivDir, right, $/)),
            ok = file:write_file(filename:join([SuiteDir, "groups.summary"]),
                                 io_lib:format("~p.\n"
                                               "~p.\n"
                                               "~p.\n",
                                               [{groups_summary, {Ok, Failed}},
                                                {eventually_ok_tests, FailedTests},
                                                {end_per_testcase_failures, length(lists:usort(SuiteEPT))}]))
    end,
    State#{total_ok := TOK + Ok,
           total_failed := TFailed + Failed,
           total_eventually_ok_tests := TEvOK + FailedTests}.

acc_groups_summary(_GroupName, #group_status{status = ok, n_failed = NFailedTests},
                   {OkGroupsAcc, FailedGroupsAcc, EventuallyOkAcc}) ->
    %% Either the group has passed succesfully on the first run,
    %% or it was repeated, and eventually passed, so the tests must finally be ok.
    {OkGroupsAcc + 1, FailedGroupsAcc, EventuallyOkAcc + NFailedTests};
acc_groups_summary(_GroupName, #group_status{status = failed, n_failed = _NFailedTests},
                   {OkGroupsAcc, FailedGroupsAcc, EventuallyOkAcc}) ->
    %% The group never succeeded, the failed tests are NOT eventually ok.
    {OkGroupsAcc, FailedGroupsAcc + 1, EventuallyOkAcc}.


log(#{logs := true}, Pattern, Args) ->
    ct:pal("Logs " ++ Pattern, Args);
log(_State, _Pattern, _Args) ->
    ok.
