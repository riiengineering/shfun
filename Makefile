.POSIX:

all:
# TODO

test/bats \
test/test_helper/bats-assert \
test/test_helper/bats-support:
	test -d .git && git submodule update --init $@
	@touch $@

test/test_helper/bats-assert: test/test_helper/bats-support

test/bats/bin/bats: test/bats test/test_helper/bats-assert
	@touch $@

test: test/bats/bin/bats .FORCE
	test/bats/bin/bats -F tap -r test/lib

.FORCE:
