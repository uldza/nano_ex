DIR = ${PWD}

.PHONY: setup run complie docs release test format lint clean tag ci dialyzer
.DEFAULT_GOAL := help

help:
	@echo "--------------------------------------------------------------------"
	@echo "Please use 'make <target>' where <target> is one of:"
	@echo "--------------------------------------------------------------------"
	@echo "  setup          : setup application"
	@echo "  run            : run application as dev locally"
	@echo "  ci             : run local ci checks"
	@echo "  complie        : compile a release code"
	@echo "  docs           : create ex docs from the code"
	@echo "  release        : build a release candidate"
	@echo "  test           : run all tests"
	@echo "  format         : format project code to best practices"
	@echo "  clean          : cleanup (build artifacts, cache etc.)"
	@echo "  tag            : get application tag version"

run: shell

setup:
	mix local.hex --force
	mix local.rebar --force
	mix setup

compile:
	mix compile --warnings-as-errors --force

shell:
	@if [ -f .env.local ]; then \
		export $$(cat .env.local | grep -v '^#' | xargs); \
	fi; \
	iex -S mix phx.server

test:
	MIX_ENV=test mix test --formatter ExUnit.CLIFormatter --cover

format:
	mix format

ci: dialyzer lint

lint:
	mix lint

dialyzer:
	mix dialyzer

docs:
	mix docs

clean:
	mix deps.clean --all
	rm -rf ${DIR}/_build

release:
	MIX_ENV=prod mix release --overwrite

tag:
	@grep 'version:' mix.exs | sed -e 's/.*version: "\(.*\)",/\1/'

