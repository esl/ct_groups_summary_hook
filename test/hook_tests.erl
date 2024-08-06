-module(hook_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("common_test/include/ct.hrl").

hook_test_() ->
    {timeout, 20,
     {setup, fun setup/0, fun teardown/1,
      {with, [fun run_ct_/1
             ]}}}.

setup() ->
    {ok, Peer, Node} = peer:start(#{
        name => ct_runner,
        connection => standard_io,
        shutdown => 3000
    }),
    #{peer => Peer, node => Node}.

teardown(#{peer := Peer}) ->
    peer:stop(Peer).

run_ct_(#{peer := Peer}) ->
    ok.
