.POSIX:

all:
# TODO

spec/.shellspec/.git:
	test -d .git && git submodule update --init $(@D)
	@printf 'Checked out ShellSpec version %s\n' "$$(spec/.shellspec/bin/shellspec -v)"
	@touch $@

spec/.shellspec/bin/shellspec: spec/.shellspec/.git

SPEC_SHELL = /bin/sh
spec: spec/.shellspec/bin/shellspec .FORCE
	spec/.shellspec/bin/shellspec -O ./spec/.shellspec-options -s $(SPEC_SHELL) -f tap

.FORCE:
