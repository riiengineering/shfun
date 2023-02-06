#!/usr/bin/env bats
bats_require_minimum_version 1.8.0

BATS_TEST_NAME_PREFIX='interactive/confirm: '

BASE_DIR=$(cd "${BATS_TEST_DIRNAME}/../../.." && pwd -P)

setup() {
	load "${BASE_DIR:?}/test/test_helper/bats-support/load"
	load "${BASE_DIR:?}/test/test_helper/bats-assert/load"
	load "${BASE_DIR:?}/test/test_helper/functions.bash"
	load "${BASE_DIR:?}/test/test_helper/test_path.bash"

	prepare_test_path
	install_test_script confirm "${BASE_DIR}/lib/interactive/confirm.sh"
}

@test "prompt: no text, no default" {
	run confirm <<<'y'
	assert_output 'Confirm? [y/n] '
	assert_success
}

@test "prompt: empty text, no default" {
	run confirm '' <<<'y'
	assert_output ' [y/n] '
	assert_success
}

@test "prompt: custom text, no default" {
	run confirm 'Do you want to continue?' <<<'y'
	assert_output 'Do you want to continue? [y/n] '
	assert_success
}

@test "return: default y" {
	run confirm 'Do you want to continue?' y <<<''
	assert_output 'Do you want to continue? [Y/n] '
	assert_success
}

@test "return: default n" {
	run confirm 'Do you want to continue?' n <<<''
	assert_output 'Do you want to continue? [y/N] '
	assert_failure 1
}

@test "return: user choice (y)" {
	run confirm 'Confirm?' <<<'y'
	assert_success
}

@test "return: user choice (n)" {
	run confirm 'Confirm?' <<<'n'
	assert_failure 1
}

@test "return: user choice against default (y)" {
	run confirm 'Are you sure?' n <<<'y'
	assert_success
}

@test "return: user choice against default (n)" {
	run confirm 'Continue?' y <<<'n'
	assert_failure 1
}

@test "response: ignores capitalisation" {
	run confirm <<<'y'
	assert_success

	run confirm <<<'n'
	assert_failure 1

	run confirm <<<'Y'
	assert_success

	run confirm <<<'N'
	assert_failure 1
}

@test "response: accepts long responses (yes/no)" {
	for _resp in yes Yes YES YeS
	do
		run confirm <<<"${_resp}"
		assert_success
	done

	for _resp in no No NO nO
	do
		run confirm <<<"${_resp}"
		assert_failure 1
	done
}

@test "return: interrupt" {
	skip 'test does not work correctly'

	{ sleep 1; echo y; } | confirm '' >/dev/null &
	_c_pid=$!

	kill -INT ${_c_pid}
	_c_rc=0
	wait ${_c_pid} || _c_rc=$?

	assert [ $((_c_rc)) -eq 130 ]

	unset _c_pid _c_rc
}

@test "interactive: nag until user choice" {
	run confirm 'Do you want X?' <<-EOF
	
	
	n
	EOF

	assert_output 'Do you want X? [y/n] Please respond with "yes" or "no": Please respond with "yes" or "no": '
	assert_failure 1
}

@test "uses only built-ins" {
	ipath=$(isolated_path)

	PATH=${ipath} run "$(command -v confirm)" <<<'y'
	assert_output 'Confirm? [y/n] '
	assert_success
}
