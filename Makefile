.PHONY: setup check test-hooks

setup:
	chmod +x ai/*.sh .githooks/*
	git config core.hooksPath .githooks
	ai/sync.sh

check:
	ai/check.sh

test-hooks:
	ai/test-hooks.sh
