#!/usr/bin/env bats
bats_require_minimum_version 1.8.0

BATS_TEST_NAME_PREFIX='format/strfc: '

BASE_DIR=$(cd "${BATS_TEST_DIRNAME}/../../.." && pwd -P)

setup() {
	load "${BASE_DIR:?}/test/test_helper/bats-support/load.bash"
	load "${BASE_DIR:?}/test/test_helper/bats-assert/load.bash"
	load "${BASE_DIR:?}/test/test_helper/functions.bash"
	load "${BASE_DIR:?}/test/test_helper/test_path.bash"

	prepare_test_path
	install_test_script strfc "${BASE_DIR}/lib/format/strfc.sh"
}

@test "empty string" {
	run strfc <<<''
	assert_output ''
}

@test "single replacement" {
	run strfc -t=test <<<'%t'
	assert_output 'test'
}

@test "invalid format specifier" {
	format='this is an invalid format specifier: %x'
	run strfc <<<"${format}"
	assert_output "$(sed 's/%.//g' <<<"${format}")"
}

@test "special characters (backslash)" {
	x_value='abc\def'
	run strfc -x="${x_value}" <<<"%x"
	assert_output "${x_value}"
}

@test "uses only built-ins and sed" {
	ipath=$(isolated_path sed)

	format='this is a %t which prints %f and %b.'

	PATH=${ipath} run "$(command -v strfc)" -t=test -f=foo -b=bar <<<"${format}"
	assert_output 'this is a test which prints foo and bar.'
}

@test "special characters (property test)" {
	iterations=20

	while test $((iterations-=1)) -ge 0
	do
		c_value='multiple'
		s_value='hello world'
		x_value=$(random_string 32)

		format='a string with %c format specifiers: a simple one (%s) and a complex one (%x).'
		expected="a string with ${c_value} format specifiers: a simple one (${s_value}) and a complex one (${x_value})."

		run strfc -c="${c_value}" -s="${s_value}" -x="${x_value}" <<<"${format}"
		assert_output "${expected}"
	done
}
