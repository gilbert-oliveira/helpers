.PHONY: tests
all: help
SHELL=bash

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-24s\033[0m %s\n", $$1, $$2}'

.git/hooks/pre-commit:
	cp cli/pre-commit .git/hooks/pre-commit

composer-dump-autoload: ## run composer dump-autoload
	cli/composer dump-autoload

composer-install: ## run composer install
	cli/composer install -n

docker-build-images:
	docker compose build

setup: .git/hooks/pre-commit fix-permissions docker-build-images up ## initialize the project if something is missing

images=
docker-up:
	docker compose up -d --remove-orphans $(images)

fix-permissions: ## fix directories and file permissions
	cli/run-local --as-root cli/fix-permissions

up: docker-up fix-permissions composer-install composer-dump-autoload ## start the dev server and sync database and vendor

check-lint: GET_GIT=-s
check-lint: check ## run lints over stagged changes

check-pre-commit: GET_GIT=-s
check-pre-commit: php-syntax phpstan phpcs php-cs-fixer-check

GET_GIT=-d
check: check-pre-commit tests ## run check-lint for changed files and tests

check-all: GET_GIT=-a
check-all: check ## run check-lint for all files and tests

tests: ## run unit tests (phpunit)
	cli/run-local ./cli/unit-tests

php-syntax: ## check syntax
	cli/run-local ./cli/php-syntax $(GET_GIT)

phpstan: composer-dump-autoload ## runs phpstan
	cli/run-local ./cli/phpstan $(GET_GIT)

phpstan-all: GET_GIT=--all
phpstan-all: phpstan ## roda phpstan checando se exceptions estão sendo tratadas

phpcs: fix-permissions ## runs phpcs
	cli/run-local ./cli/phpcs $(GET_GIT)

phpcbf: ## runs phpcbf for auto-fixes
	cli/run-local --as-myself ./cli/phpcbf $(GET_GIT) || true

php-cs-fixer: fix-permissions ## runs php-cs-fixer for auto-fixes
	cli/run-local --as-myself ./cli/php-cs-fixer $(GET_GIT) || true

php-cs-fixer-check: ## runs php-cs-fixer for checks
	cli/run-local ./cli/php-cs-fixer $(GET_GIT) --dry-run

auto-fix: phpcbf php-cs-fixer

auto-fix-diff: ## run all auto-fixers for changed files
	make auto-fix GET_GIT=--diff

auto-fix-all: ## run all auto-fixers for all files
	make auto-fix GET_GIT=--all

auto-fix-file: ## run all auto-fixers for a file/path (use make auto-fix file=path/to/file.php)
ifndef file
	$(error No file was informed throught the "file" parameter)
endif
	make auto-fix GET_GIT=$(file)
