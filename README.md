# flask-template

This is an example [Flask](https://flask.palletsprojects.com/) project
template.

## Features

 * Uses a Makefile to wrap all setup, installation, and maintainance tasks.
 
 * Uses [d.rymcg.tech](https://github.com/EnigmaCurry/d.rymcg.tech) to
   deploy to Docker with `docker compose`.
   
 * Includes PostgreSQL database, running as an optional sidecar
   container.

 * Provides a local development environment using Python's
   [virtualenv](https://docs.python.org/3/library/venv.html) (native;
   not in Docker). The local dev service can access the same remote
   database, running on your server. Local access is [provisioned via
   SSH
   tunnel](https://github.com/EnigmaCurry/d.rymcg.tech/blob/master/_scripts/postgresql-tunnel).

 * Uses [Flask
   Blueprints](https://flask.palletsprojects.com/en/3.0.x/blueprints/)
   for a modular project design.

 * All database SQL queries are stored in separate `.sql` files. These
   queries are loaded as Python functions using
   [aiosql](https://nackjicholson.github.io/aiosql/).

## How to use this template

This example project integrates with
[d.rymcg.tech](https://github.com/EnigmaCurry/d.rymcg.tech#readme).
Before proceeding, you must first clone and setup `d.rymcg.tech` on
your workstation. Then you can use the following command to
instantiate a new project from a template:

```
d.rymcg.tech create myapp
```

This will create a new project in a new directory called `myapp`.

This project is an example of a so-called
["external"](https://github.com/enigmacurry/d.rymcg.tech#integrating-external-projects)
project to `d.rymcg.tech`, as it does not live in the same source tree
as `d.rymcg.tech`, but makes a link to inherit its Makefiles and to
gain its superpowers.

## Example blueprints

This example template comes with the following Flask blueprints:

 * hello - a simple greeting and visitor log application
 
   * [hello route](api/app/routes/hello)
   * [hello model](api/app/models/hello)
   * [hello templates](api/app/templates/hello) 

 * upload - a simple file upload form
 
   * [upload route](api/app/routes/upload)
   * [upload model](api/app/models/upload)
   * [upload templates](api/app/templates/upload)

## Configure

Once
[d.rymcg.tech](https://github.com/EnigmaCurry/d.rymcg.tech#readme) has
been installed, you can come back to this directory.

Run:

```
make config
```

This will create the `.env_{DOCKER_CONTEXT}` configuration file for
your service.

## Install

Run:

```
make install
```

## Open in your web browser

Run:

```
make open
```

## Local Database

To access the database directly from your workstation, run:

```
make local-db
```

This starts an SSH tunnel to the postgres port inside the container,
enters you into a BASH subshell, and sets all of the environment
variables to accessing the database using local postgres tools and
clients.

On Arch linux, you want to install the postgres client package: `sudo pacman -S postgresql-libs`

On Ubuntu: `sudo apt-get install -y postgresql-client libpq-dev python3-dev`

Inside the `make local-db` shell, you can run any of the standard
postgresql client tools: `psql`, `createdb`, `createuser`, `pg_dump`,
etc. The user credentials are pre-set in your environment for easy
access.

Notice the PGPORT setting. When using the tunnel, this port is on
`localhost`. You can use any other postgresql client connecting to
`localhost` on the given port. By default the port is randomly chosen
upon entering the subshell. To get the same port everytime, add it as
an argument:

```
## Specify a static TCP port:
make local-db PGPORT=55542
```

Keep this shell open, and you can use graphical client like
[DBeaver](https://dbeaver.io/) (when creating the connection in
DBeaver make sure to copy all the settings for host, port, database,
user, and password, as shown in the subshell session.)

## Local development mode

You can install a Python virtual environment (`virtualenv`) for local
development mode. This virtualenv does not run in a container, but it
require you to install the remote database service.

Ensure that you have installed the remote database:

```
make install service=database
```

Install the local virtualenv:

```
make local-install
```

To start the local development server, you must first start the
`local-db` connection. Enter the `local-db` shell:

```
make local-db
```

Once inside the `local-db` shell, you can start the local server:

```
## This only works inside the local-db shell:
make dev
```

## Instantiation

If you wish to run more than one instance of the app on the same
docker host, you can use `make instance`. Follow the the main
[d.rymcg.tech instantiation
docs](https://github.com/EnigmaCurry/d.rymcg.tech#creating-multiple-instances-of-a-service)
for details.

Each instance is a separate stack. Each separate instance has:

 * Its own `.env_{DOCKER_CONTEXT}_{INSTANCE_NAME}` config file.
 * Its own frontend, API, database, etc. services.
 * It's own domain name.

In the `.env_{DOCKER_CONTEXT}_{INSTANCE_NAME}` config file, each
instance has set a unique `{PROJECT}_INSTANCE` variable. This variable
is used to make discrete Traefik services, routes, and middlewares,
separate for each instance.

This could be useful for having a "production" and "development"
instance on the same box (at the risk of the integrity of the
"production" instance, if you choose to do this).
