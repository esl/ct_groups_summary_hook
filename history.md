Original history of the code.


To view the history, use:
```
git clone "https://github.com/esl/MongooseIM.git"
cd MongooseIM
git checkout 6.2.1
git log big_tests/src/ct_groups_summary_hook.erl big_tests/tests/test_SUITE.erl
```

This could help with understanding how it works and the motivation behind it.

```
commit adec35ae9d0465bcf02108c6efb5bf61336e25e4
Author: Denys Gonchar <denys.gonchar@erlang-solutions.com>
Date:   Thu Jul 6 17:44:20 2023 +0200

    moving halting logic from ct_tty_hook:on_tc_skip/3 to ct_groups_summary_hook:on_tc_skip/3

commit 6c0f28fb2f903291c51db846ce94735a9c04eda8
Author: Denys Gonchar <denys.gonchar@erlang-solutions.com>
Date:   Wed Jul 5 01:32:22 2023 +0200

    improving truncated_counter_file reporting at ct_markdown_errors_hook

commit b6c35a4886e1ab8e7760c40f00ad4fd11387ebc4
Author: Denys Gonchar <denys.gonchar@erlang-solutions.com>
Date:   Tue Jul 4 23:29:22 2023 +0200

    improving ct_groups_summary_hook

commit 04b6c72b4017f5ea24060267c0b0ca3cf2ccd72b
Author: Denys Gonchar <denys.gonchar@erlang-solutions.com>
Date:   Wed Jun 14 10:48:04 2023 +0200

    testing ct hook for GA reporting
    
    for testing use the following commands:
        . tools/test-runner-complete.sh
        test-runner.sh --skip-preset --skip-build-mim --skip-small-tests --skip-start-nodes --skip-stop-nodes --db --skip-cover --skip-preset --dev-nodes --spec failure_reporting_testing.spec

commit e0dcd7837f74f723137b2c96ddd214576adc941f
Author: vkatsuba <v.katsuba.dev@gmail.com>
Date:   Thu Sep 23 16:43:46 2021 +0300

    Fix compile warnings in big tests

commit ec90c2e548268ee80a9b81c0428d83e44c536e0f
Author: Michal Piotrowski <michal.piotrowski@erlang-solutions.com>
Date:   Wed Jun 20 10:54:42 2018 +0200

    exit run_common_tests with groups summary status (when available)

commit d189b330d6c881e1cb2a1e254b53c3d9a1a1f356
Author: Michal Piotrowski <michal.piotrowski@erlang-solutions.com>
Date:   Tue Jun 19 16:02:34 2018 +0200

    make group summary from all suites run

commit bb2ab4249dcb81f11a116a031d4f02f5638ff97f
Author: kanes115 <dominikstanaszek@icloud.com>
Date:   Fri Jun 8 09:29:31 2018 +0200

    Replace maps:update_with
    
    It does not work with OTP 18

commit c5bc15bd7250508eed0642ebdc01737568901b7a
Author: Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>
Date:   Fri Jun 1 12:59:12 2018 +0200

    Disable debugging printouts

commit f89b00eab11f5f40c8cb23f21885e242b44a4c23
Author: Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>
Date:   Wed May 30 17:56:43 2018 +0200

    Accumulate number of tests which passed due to retries
    
    We need this number as some suites might not use groups at all.
    In such a case, we can't simply decide if a build is green or red
    just based on group stats, since the groups stats won't tell us truth.
    We have to make sure we take into account the number of failed test cases
    and subtract from it the number of test cases which were retried
    and eventually passed.

commit c806e0d606fbc296ffc1bea1defa4063efd95134
Author: Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>
Date:   Wed May 30 13:05:36 2018 +0200

    Fine tune the logic of failing a group with regard to auto-/user-skipped test cases

commit 63fcfb406e6bd12a33722ba465857ee740157d1b
Author: Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>
Date:   Tue May 29 17:38:23 2018 +0200

    Be more verbose in ct_groups_summary_hook

commit f0937112f1f3812f5546826bdd0877083acc4a29
Author: Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>
Date:   Tue May 29 16:52:00 2018 +0200

    Don't flatten tree-like group hierarchies when counting
    
    For example in connect_SUITE we have top-level fast_tls and just_tls groups,
    both of which run the same child groups.
    In order not to confuse the child groups from the upper-level groups,
    we have to use group paths for storing group success/failure status.

commit c93e96bb71fd4d810464c795b5b55db6e01535db
Author: Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>
Date:   Tue May 29 12:25:32 2018 +0200

    Expect a successful write of groups.summary file

commit f4c387e754101aa769af7a13fb9986309f2af153
Author: Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>
Date:   Tue May 29 11:47:50 2018 +0200

    Properly count successful/failed groups per suite

commit 1a1e29ef214c39e0b4167de2bd24c251743b78e1
Author: Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>
Date:   Mon May 28 13:54:22 2018 +0200

    Fix incorrect matching in the failed case

commit e37309e770102895568e32684d5f0e89554a5a77
Author: Radek Szymczyszyn <radoslaw.szymczyszyn@erlang-solutions.com>
Date:   Fri May 25 17:48:54 2018 +0200

    Define and enable ct_groups_summary_hook
```
