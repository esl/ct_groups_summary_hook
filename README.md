# Common Tests Group Summary Hook

This hook counts successful and failed groups in the test suite.
It writes a `groups.summary` file into the suite log directory.

Used in [MongooseIM big tests](https://github.com/esl/MongooseIM/tree/master/big_tests).

This repo contains the hook and tests for it.

[Hex package](https://hex.pm/packages/ct_groups_summary_hook)

## Credits

`ct_groups_summary_hook` was originally created within [the MongooseIM repository as part of its test framework](https://github.com/esl/MongooseIM).

# Test Execution Summary

See [summarise-ct-results script](tools/summarise-ct-results), which
reads the `groups.summary` file.

Usage example (takes a list of directories as arguments):

```
tools/summarise-ct-results _build/test/logs/last/
CT results:
    1 groups passed
    0 groups failed
    0 tests eventually passed
    0 tests with end_per_testcase failed
    1 tests passed
    0 tests failed
    0 tests skipped by user
    0 tests skipped automatically
```

Returns with the exit code 0 on the test execution success.
