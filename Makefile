SHELL := /usr/bin/env bash

.PHONY: test syntax shellcheck behavioral install-local pack clean worker-dev worker-deploy worker-migrate

test: syntax shellcheck behavioral

behavioral:
	python3 -m unittest discover -s tests -p 'test_*.py' -v

syntax:
	bash -n install.sh
	bash -n bin/dasterm
	find lib -type f -name "*.sh" -print0 | xargs -0 -I{} bash -n {}
	find scripts tests -type f -name "*.sh" -print0 | xargs -0 -I{} bash -n {}

shellcheck:
	shellcheck -x install.sh bin/dasterm lib/*.sh scripts/*.sh tests/*.sh

install-local:
	bash scripts/install-local.sh

pack:
	bash scripts/pack.sh

clean:
	rm -rf dist
	rm -rf .cache
	rm -rf tmp
	rm -f *.tar.gz

worker-dev:
	cd worker && npm run dev

worker-deploy:
	cd worker && npm run deploy

worker-migrate:
	cd worker && npm run db:migrate
