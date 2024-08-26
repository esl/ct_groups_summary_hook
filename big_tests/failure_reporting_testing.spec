{suites, "tests", test_SUITE}.

{config, ["test.config"]}.
{logdir, "ct_report"}.

%%% ct_test_hook is just a demo CT hook with tracing.
%%% ct_test_hook should be executed just once, see
%%% implementation of ct_test_hook:id/1 and ct_hooks
%%% documentation:
%%%    https://erlang.org/doc/man/ct_hooks.html
{ct_hooks, [ct_test_hook, ct_test_hook]}.

<<<<<<< HEAD
% {ct_hooks, [ct_groups_summary_hook, ct_markdown_errors_hook]}.
=======
%%% this hook generates junit_report.xml file
{ct_hooks, [cth_surefire]}.

%%% this hook generates groups.summary files per suite
%%% and an overall resulting all_groups.summary file.
{ct_hooks, [ct_groups_summary_hook]}.

{ct_hooks, [ct_markdown_errors_hook]}.

%%% this hook prints execution summary in the end of
%%% big_tests run. however, silent_exec.sh script redirects
%%% output into a file. set VERBOSE env variable to 1, to
%%% tail output file.
% {ct_hooks, [ct_tty_hook]}.

%%% this hook appeands /tmp/progress file, that file
%%% is printed asynchronously by test.sh script using
%%% 'tail -f /tmp/progress &' command.
% {ct_hooks, [ct_progress_hook]}.
>>>>>>> b6c35a488 (improving ct_groups_summary_hook)
