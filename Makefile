VIRTUALENV_DIR=env

.PHONY: help # Shows this help screen
help:
	@grep -h '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/make \1 \t- \2/' | expand -t20

.PHONY: check-deps
check-deps:
	_scripts/check_deps python

.PHONY: install # Creates a virtual environment and install all dependencies
install: check-deps
	python -m venv ${VIRTUALENV_DIR}
	${VIRTUALENV_DIR}/bin/python -m pip install --upgrade pip
	${VIRTUALENV_DIR}/bin/pip install -r requirements/requirements.txt -r requirements/dev.requirements.txt

.PHONY: dev # Starts localhost development server
dev:
	DNOTES_LOG_LEVEL=debug DNOTES_DB=development.sqlite3 ${VIRTUALENV_DIR}/bin/python app.py

.PHONY: dev-public # Starts public development server on all network interfaces (0.0.0.0)
dev-public:
	DNOTES_HTTP_HOST=0.0.0.0 make dev

.PHONY: prod # Starts production server
prod:
	DNOTES_DEPLOYMENT=prod DNOTES_DB=prod.sqlite3 ${VIRTUALENV_DIR}/bin/python app.py

.PHONY: clean # Deletes the virtual environment
clean:
	rm -rf ${VIRTUALENV_DIR}

.PHONY: activate # Enters a sub-shell with the virtualenv activated
activate:
	$${SHELL} --rcfile <(echo "source ${VIRTUALENV_DIR}/bin/activate")

.PHONY: test # Runs tests
test:
	${VIRTUALENV_DIR}/bin/python -m pytest --doctest-modules --ignore=_stuff

.PHONY: upgrade # Upgrades Python package versions in requirements files
upgrade:
	${VIRTUALENV_DIR}/bin/python -m pur -r requirements/requirements.txt -r requirements/dev.requirements.txt
