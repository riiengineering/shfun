#!/usr/bin/env bats

setup() {
	BASE_DIR=$(cd "${BATS_TEST_FILENAME%/*}" && cd ../../.. && pwd -P)
	TEST_DIR=${BASE_DIR:?}/test

	load "${TEST_DIR:?}/test_helper/bats-support/load"
	load "${TEST_DIR:?}/test_helper/bats-assert/load"

	STRFC=${BASE_DIR}/lib/format/strfc.sh
}

random_string() {
	# usage: random_string [length] [character classes]
	LC_ALL=C tr -dc "${2-'[:print:]'}" </dev/urandom \
	| dd bs=1 count=${1-128} 2>/dev/null
}

@test "empty string" {
	run "${STRFC}" <<<''
	assert_output ''
}

@test "single replacement" {
	run "${STRFC}" -t=test <<<'%t'
	assert_output 'test'
}

@test "invalid format specifier" {
	format='this is an invalid format specifier: %x'
	run "${STRFC}" <<<"${format}"
	assert_output "$(sed 's/%.//g' <<<"${format}")"
}

@test "special characters (backslash)" {
	x_value='abc\def'
	run "${STRFC}" -x="${x_value}" <<<"%x"
	assert_output "${x_value}"
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

		run "${STRFC}" -c="${c_value}" -s="${s_value}" -x="${x_value}" <<<"${format}"
		assert_output "${expected}"
	done
}