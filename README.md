# Demo DynamoBD concepts for learning

[![test-status-image]][test-status]

## Getting started

This project is designed to use local DynamoDB. Using the docker image is easy
and strongly recommended. Just run the following command to start up a local
DynamoDB service daemon:

```
docker run -dp 8000:8000 amazon/dynamodb-local
```

Other requriments include `bash` (tested with bash 5, but older versions might
work fine), `jq`, and the `aws` cli v2. Tests also assume a gnu userspace,
though use of gnu-specific features is currently minimal (read: you might be
able to get away with a BSD userspace on Mac, but this is untested).

Running the tests is easy:

```
❯ ./run-tests
```

That script will find all tests in the `tests/` directory and execute them.

Individual tests can be executed via the `run` script, for example:

```
❯ ./tests/duplicate-sort-keys/run
```


## Project Intent

The intent of this project is to provide a helper lib for users writing bash
scripts to create, populate, and query DynamoDB tables for learning purposes.
The lib functions and variable definitions are all within the `lib/` directory;
review those files for specific information, and use the implemented test cases
as examples.

One major callout is the `aws` lib function, which wraps the `aws`
cli command and will automatically inject the endpoint and region configured in
`lib/vars` (by default `localhost:8000` and `us-west-2`, respectively).


## Developing new tests

To create a new test simply create a directory named for the test in the
`tests/` directory, and ensure it has an executable `run` file within.

While using bash for all scripting is intended, it is not a requirement. Any
executable can serve as a test runner. Evaluating complex test cases can also
be difficult within bash, but it is not unexpected to use a bash script as the
`run` to coordinate the database setup and run queries while calling out to
something like python for test case evaluation.

Note that the bash lib includes a function `setup_table` which will, by
default, add an `EXIT` trap to delete the table. This is to enable automatic
clean up of the table at the end of the test. It is strongly recommended to
retain this behaivor, but during development it can be useful to retain a test
database. To do so, add a file `vars` in the test directoy and ensure it has
`CLEANUP=false` (or any other value other than `true`), and the cleanup trap
will not be set.

Be aware `setup_table` will also attempt to delete the table before creating
it, to ensure the test runs with no previous state.

Further instructions are left intentionally sparse as this is a brand new
project with no userbase.


## Contributing

### Questions

Please open an issue in the [GitHub repo issue
tracker](https://github.com/jkeifer/dynamodb-learning-tests/issues) for any
questions. If I know users are finding this project useful I am more likely to
invest in better documentation.

### Bugs and improvements

Please open an issue for an bugs. PRs are also welcome.

Additional test cases can be proposed via issues or PRs, however please
recognize this is inherently a personal project and not all ideas and/or test
implementations will fit the project's objectives or code style.


[test-status-image]: https://github.com/jkeifer/dynamodb-learning-tests/actions/workflows/run-tests.yml/badge.svg
[test-status]: https://github.com/jkeifer/dynamodb-learning-tests/actions/workflows/run-tests.yml
