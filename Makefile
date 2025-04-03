ROOT_DIR = ~/git/vendor/enigmacurry/d.rymcg.tech
VIRTUALENV_DIR=$(shell realpath virtualenv)

include ${ROOT_DIR}/_scripts/Makefile.projects
include ${ROOT_DIR}/_scripts/Makefile.instance

.PHONY: config-hook
config-hook:
#### This interactive configuration wizard creates the .env_{DOCKER_CONTEXT}_{INSTANCE} config file using .env-dist as the template:
#### reconfigure_ask asks the user a question to set the variable into the .env file, and with a provided default value.
#### reconfigure sets the value of a variable in the .env file without asking.
#### reconfigure_htpasswd will configure the HTTP Basic Authentication setting the var name and with a provided default value.
	@${BIN}/reconfigure_ask ${ENV_FILE} FLASK_TEMPLATE_TRAEFIK_HOST "Enter the flask-template domain name" flask-template${INSTANCE_URL_SUFFIX}.${ROOT_DOMAIN}
	@${BIN}/reconfigure ${ENV_FILE} FLASK_TEMPLATE_INSTANCE=$${instance:-default}
	@${BIN}/reconfigure_auth ${ENV_FILE} FLASK_TEMPLATE
	@[[ -z "$$(${BIN}/dotenv -f ${ENV_FILE} get FLASK_TEMPLATE_POSTGRES_PASSWORD)" ]] && ${BIN}/reconfigure ${ENV_FILE} FLASK_TEMPLATE_POSTGRES_PASSWORD=$$(openssl rand -base64 45) || true
	@echo ""

.PHONY: override-hook
override-hook:
#### This sets the override template variables for docker-compose.instance.yaml:
#### The template dynamically renders to docker-compose.override_{DOCKER_CONTEXT}_{INSTANCE}.yaml
#### These settings are used to automatically generate the service container labels, and traefik config, inside the template.
#### The variable arguments have three forms: `=` `=:` `=@`
####   name=VARIABLE_NAME    # sets the template 'name' field to the value of VARIABLE_NAME found in the .env file
####                         # (this hardcodes the value into docker-compose.override.yaml)
####   name=:VARIABLE_NAME   # sets the template 'name' field to the literal string 'VARIABLE_NAME'
####                         # (this hardcodes the string into docker-compose.override.yaml)
####   name=@VARIABLE_NAME   # sets the template 'name' field to the literal string '${VARIABLE_NAME}'
####                         # (used for regular docker-compose expansion of env vars by name.)
	@${BIN}/docker_compose_override ${ENV_FILE} project=:flask-template instance=@FLASK_TEMPLATE_INSTANCE traefik_host=@FLASK_TEMPLATE_TRAEFIK_HOST http_auth=FLASK_TEMPLATE_HTTP_AUTH http_auth_var=@FLASK_TEMPLATE_HTTP_AUTH ip_sourcerange=@FLASK_TEMPLATE_IP_SOURCERANGE oauth2=FLASK_TEMPLATE_OAUTH2 authorized_group=FLASK_TEMPLATE_OAUTH2_AUTHORIZED_GROUP development_mode=FLASK_TEMPLATE_DEVELOPMENT_MODE enable_mtls_auth=FLASK_TEMPLATE_MTLS_AUTH mtls_authorized_certs=FLASK_TEMPLATE_MTLS_AUTHORIZED_CERTS

.PHONY: shell # Enter shell of api container (or set service=name to enter a different one)
shell:
	@make --no-print-directory docker-compose-shell SERVICE=api

# .PHONY: dev-sync
# dev-sync:
# 	@${BIN}/dev-sync flask-template_development flask

.PHONY: localdb
localdb:
	@${BIN}/postgresql-tunnel ${ENV_FILE} database ${INSTANCE}

.PHONY: local-db # Open BASH shell with remote DB connection through SSH
local-db: localdb

.PHONY: psql # Start psql shell directly inside the database container
psql:
	@make --no-print-directory docker-compose-shell SERVICE=database COMMAND="psql -U $$(${BIN}/dotenv -f ${ENV_FILE} get FLASK_TEMPLATE_POSTGRES_DATABASE)"

.PHONY: drop-db # Drop and reinitialize entire database (only allowed if DEV_MODE=true and if all clients are disconnected)
drop-db:
	@test "$$(${BIN}/dotenv -f ${ENV_FILE} get FLASK_TEMPLATE_DEV_MODE)" != "true" && echo "Refusing to drop tables because the deployment is not in DEV mode." && exit 1 || true
	@${BIN}/confirm no "Are you sure you want to DESTROY the entire database" "?"
	@POSTGRES_DATABASE="$$(${BIN}/dotenv -f ${ENV_FILE} get FLASK_TEMPLATE_POSTGRES_DATABASE)" && ${MAKE} shell service=database COMMAND="dropdb -U $$POSTGRES_DATABASE $$POSTGRES_DATABASE && createdb -U $$POSTGRES_DATABASE $$POSTGRES_DATABASE"
	@echo
	@echo "Database dropped and reinitialized to a blank state."
	@echo

.PHONY: dropdb
dropdb: drop-db

.PHONY: migrate-db # Run alembic migration scripts
migrate-db:
	${MAKE} shell service=api

###
### Local non-docker python development inside virtualenv:
###

.PHONY: local-check-deps
local-check-deps:
	${BIN}/check_deps python3

.PHONY: local-install # Creates a virtual environment and install all dependencies
local-install: local-check-deps
	python3.11 -m venv ${VIRTUALENV_DIR}
	${VIRTUALENV_DIR}/bin/python -m pip install --upgrade pip
	${VIRTUALENV_DIR}/bin/pip install -r api/requirements/requirements.txt -r api/requirements/dev.requirements.txt

.PHONY: local-dev
local-dev:
	mkdir -p uploads
	PYTHONPATH=$(shell realpath api) API_UPLOAD_FOLDER="$(shell realpath uploads)" API_LOG_LEVEL=debug API_DB=development.sqlite3 ${VIRTUALENV_DIR}/bin/python -m app

.PHONY: dev # Starts localhost development server
dev: local-install local-dev

.PHONY: local-dev-public # Starts public development server on all network interfaces (0.0.0.0)
local-dev-public:
	API_HTTP_HOST=0.0.0.0 ${MAKE} local-dev

.PHONY: local-prod # Starts production server
local-prod:
	API_DEPLOYMENT=prod API_DB=prod.sqlite3 ${VIRTUALENV_DIR}/bin/python app.py

.PHONY: local-clean # Deletes the virtual environment
local-clean:
	rm -rf ${VIRTUALENV_DIR}

.PHONY: local-activate # Enters a sub-shell with the virtualenv activated
local-activate:
	$${SHELL} --rcfile <(echo "source ${VIRTUALENV_DIR}/bin/activate")

.PHONY: local-test # Runs tests
local-test:
	${VIRTUALENV_DIR}/bin/python -m pytest --doctest-modules --ignore=_stuff

.PHONY: local-upgrade # Upgrades Python package versions in requirements files
local-upgrade:
	${VIRTUALENV_DIR}/bin/python -m pur -r api/requirements/requirements.txt
	${VIRTUALENV_DIR}/bin/python -m pur -r api/requirements/dev.requirements.txt

.PHONY: local-migrate-db # Run alembic migration scripts
local-migrate-db:
	export PGDATABASE="postgres" PGUSER="postgres" PGPASSWORD="postgres" PGHOST="localhost" PGPORT=5433 && $${SHELL} --rcfile <(echo "source ${VIRTUALENV_DIR}/bin/activate && cd api && alembic upgrade head && exec $$SHELL")
