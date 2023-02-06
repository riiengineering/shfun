#!/usr/bin/env bats
bats_require_minimum_version 1.8.0

BATS_TEST_NAME_PREFIX='regex/breify: '

BASE_DIR=$(cd "${BATS_TEST_DIRNAME}/../../.." && pwd -P)

setup() {
	load "${BASE_DIR:?}/test/test_helper/bats-support/load"
	load "${BASE_DIR:?}/test/test_helper/bats-assert/load"
	load "${BASE_DIR:?}/test/test_helper/functions.bash"
	load "${BASE_DIR:?}/test/test_helper/test_path.bash"

	prepare_test_path
	install_test_script breify "${BASE_DIR}/lib/regex/breify.sh"
}

@test "'hello world'" {
	run breify 'hello world'
	assert_output 'hello world'
}

@test "grep the breifyed input" {
	input='The result of [1.41^(2*3)] is 7.85...'

	_bre=$(breify "${input}")

	refute grep -x -e "${_bre}" <<-'EOF'
	The result of [1a41^(2*3)] is 7.85...
	The result of [1.41^(2*3)] is 7.85abc
	The result of [1.41^(2*3)] is 7x85...
	The result of [1.41^(222223)] is 7.85...
	The result of * is 7x85abc
	The result of 4 is 7.85...
	EOF
}

@test "uses only built-ins and sed" {
	ipath=$(isolated_path sed)

	PATH=${ipath} run "$(command -v breify)" 'hello-app/1.0.2'
	assert_output 'hello-app\/1\.0\.2'
	assert_success
}
