.POSIX:

all:
# TODO

test/bats/.git \
test/test_helper/bats-assert/.git \
test/test_helper/bats-support/.git:
	test -d .git && git submodule update --init $(@D)
	@touch $@

spec/.shellspec/.git:
	test -d .git && git submodule update --init $(@D)
	@printf 'Checked out ShellSpec version %s\n' "$$(spec/.shellspec/bin/shellspec -v)"
	@touch $@

test/bats/bin/bats: test/bats/.git
test/test_helper/bats-support/load: test/test_helper/bats-support/.git
test/test_helper/bats-assert/load: test/test_helper/bats-assert/.git test/test_helper/bats-support/load

test: test/bats/bin/bats test/test_helper/bats-assert/load .FORCE
	test/bats/bin/bats -F tap -r test/lib

spec/.shellspec/bin/shellspec: spec/.shellspec/.git

SPEC_SHELL = /bin/sh
spec: spec/.shellspec/bin/shellspec .FORCE
	spec/.shellspec/bin/shellspec -O ./spec/.shellspec-options -s $(SPEC_SHELL) -f tap

.FORCE:
