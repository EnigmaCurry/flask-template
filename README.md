# hello

Notes by ryan: this is a fork of your original branch, I put all your
old code into the [stuff](stuff) directory, which I am not using. Your
job to continue this fork would be to re-integrate your code into this
new framework following this example.

## Makefile

You can install and run the app via the [Makefile](Makefile):

```
$ make
make help           - Shows this help screen
make install        - Creates a virtual environment and install all dependencies
make dev            - Starts localhost development server
make dev-public     - Starts public development server on all network interfaces (0.0.0.0)
make prod           - Starts production server
make clean          - Deletes the virtual environment
make activate       - Enters a sub-shell with the virtualenv activated
make test           - Runs tests
make upgrade        - Upgrades Python package versions in requirements files
```

`make install` will create a virtualenv python environment in the same
directory named `env`.

`make dev` will start the dev server. `make prod` to start the
production (non-debug) server (see [Flask notes about production
servers](https://flask.palletsprojects.com/en/2.2.x/deploying/).

## Architecture

There is a new sub-module called [routes/hello](routes/hello) which is
an example that hosts an MVC pattern for splitting model (data), view
(template), and controller (logic). This uses the [Flask
Blueprint](https://flask.palletsprojects.com/en/2.2.x/blueprints/)
feature to load hello as a self-contained module.

The hello module is comprised of the following:
 * [routes/hello/hello_controller.py](routes/hello/hello_controller.py) this is the
   Flask controller, whose only job is to load data from/to the
   database model, and render the template.
 * [routes/hello/hello_model.py](routes/hello/hello_model.py) this is the database
   access layer, which handles the sqlite database driver and all
   database interaction.
 * [routes/hello/hello.sql](routes/hello/hello.sql) which uses
[aiosql](https://github.com/nackjicholson/aiosql) to load SQL queries
from an external .sql file, which is loaded by `hello_model.py`
 * [templates/hello](templates/hello) contains two templates
   `hello.html` and `users.html` used in `hello_controller.py`

You can create additional self-contained modules following the hello
pattern. If you can't think of a logical separation between modules,
you may just want to create one big module that contains everything
(eg. a `dnotes` module), but separation into parts is recommended.

The root project directory contains only enough code to load the
configuration and the blueprints. All application code should go into
routes blueprints in the [routes](routes) directory or in the
[lib](lib) directory (which shares common code available to all
sub-modules).

I have put all configuration into [lib/config.py](lib/config.py) which
loads everything from the environment, or a default value if not
specified. Notable variables include:

 * `DNOTES_DB` (default: `:memory:`) - set this to the path to the
   SQLite database, it will use an ephemeral in-memory database if not
   specified.
 * `DNOTES_LOG_LEVEL` (default: `warning`) - set this to debug, info,
   warning, error, or critical, to change python logger level.

[app.py](app.py) is simplified to only the bare essentials for
starting the app, and loading blueprints. The app will learn the
correct ip address and port to listen on, from the environment
variables: `DNOTES_HTTP_HOST` (default `127.0.0.1`) and
`DNOTES_HTTP_PORT` (default `5001`) (See
[lib/config.py](lib/config.py)).

If you create another route blueprint module, you must import it into
the main [routes/__init__.py](routes/__init__.py), and adding the
blueprint to [app.py](app.py), following the example of hello.

## example routes

Hello has two routes which accept some parameters:

 * Greet the user and increment # of times greeted:
   * http://localhost:5001/hello/ (default user is bob)
   * http://localhost:5001/hello/?name=ryan (change the user to ryan)
   * http://localhost:5001/hello/gutentag?name=ryan (change the salutation)
   * http://localhost:5001/hello/holy%20toledo?name=ryan (change the salutation)

 * List all users who've been greeted:
   * http://localhost:5001/hello/users

## Database connection pool

Its probably not so important to run a connection pool for sqlite as
it would be for postgresql, but nonetheless it seems like the right
thing to do. This app [uses](lib/db.py) the [connection pool from
SQLAlchemy](https://docs.sqlalchemy.org/en/20/core/pooling.html#module-sqlalchemy.pool),
but does not use any other SQLAlchemy features. A group of connections
are maintained and the sqlite driver uses them directly, with queries
loaded from
[aiosql](https://nackjicholson.github.io/aiosql/index.html). Each
model function can acquire a pooled connection automatically through
the `db` context manager:

```
# Example automatically accesses a pooled database connection 
# through `db` context manager:

from lib import db
import aiosql

queries = aiosql.from_path(
    "/path/to/your/sql/test.sql"),
    driver_adapter="sqlite3",
)

def create_tables():
    with db() as conn:
        queries.create_test_table(conn)
```

## Tests

Tests are easily written using
[doctest](https://docs.python.org/3/library/doctest.html), just test
your code manually in the REPL once, and copy the REPL log into your
docstring. Documentation == Tests.

Use `make test` to run the tests, which will find all the doctests and
run them:

```
$ make test

env/bin/python -m pytest --doctest-modules --ignore=stuff
====================================== test session starts ======================================platform linux -- Python 3.11.3, pytest-7.2.0, pluggy-1.2.0
rootdir: /home/ryan/git/vendor/duanemcguire/dnotes
collected 1 item                                                                                

routes/hello/magic_model.py .                                                             [100%]

======================================= 1 passed in 0.33s =======================================```
