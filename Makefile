.POSIX:

all:
# TODO

test/bats/.git \
test/test_helper/bats-assert/.git \
test/test_helper/bats-support/.git:
	test -d .git && git submodule update --init $(@D)
	@touch $@

test/bats/bin/bats: test/bats/.git
test/test_helper/bats-support/load: test/test_helper/bats-support/.git
test/test_helper/bats-assert/load: test/test_helper/bats-assert/.git test/test_helper/bats-support/load

test: test/bats/bin/bats test/test_helper/bats-assert/load .FORCE
	test/bats/bin/bats -F tap -r test/lib

.FORCE:
