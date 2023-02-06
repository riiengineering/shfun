#!/usr/bin/env bats
bats_require_minimum_version 1.8.0

BATS_TEST_NAME_PREFIX='str/join: '

BASE_DIR=$(cd "${BATS_TEST_DIRNAME}/../../.." && pwd -P)

setup() {
	load "${BASE_DIR:?}/test/test_helper/bats-support/load"
	load "${BASE_DIR:?}/test/test_helper/bats-assert/load"
	load "${BASE_DIR:?}/test/test_helper/functions.bash"
	load "${BASE_DIR:?}/test/test_helper/test_path.bash"

	prepare_test_path
	install_test_script join "${BASE_DIR}/lib/str/join.sh"
}

@test "join without arguments" {
	run join
	assert_output ''
	assert_success
}

@test "join without fields" {
	run join ,
	assert_output ''
	assert_success
}

@test "join with empty separator" {
	run join '' a b c
	assert_output 'abc'
}

@test "join 'hello', 'world' with ' '" {
	run join ' ' hello world
	assert_output 'hello world'
}

@test "join 'foo', 'bar', 'baz' with ', '" {
	run join ', ' foo bar baz
	assert_output 'foo, bar, baz'
}

@test "uses only built-ins" {
	ipath=$(isolated_path)

	PATH=${ipath} run "$(command -v join)" ' != ' foo bar baz
	assert_output 'foo != bar != baz'
	assert_success
}
