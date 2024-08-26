# Common Tests Group Summary Hook

This hook counts successful and failed groups in the test suite.
It writes a `groups.summary` file into the suite log directory.

Used in [MongooseIM big tests](https://github.com/esl/MongooseIM/tree/master/big_tests).

See [summarise-ct-results script](https://github.com/esl/MongooseIM/blob/master/tools/summarise-ct-results), which
reads the `groups.summary` file.

This repo contains the hook and tests for it.

[Hex package](https://hex.pm/packages/ct_groups_summary_hook)

Original development was done in MongooseIM repository.
