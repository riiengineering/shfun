#!/usr/bin/env bats

BATS_TEST_NAME_PREFIX='url/urlencode: '

BASE_DIR=$(cd "${BATS_TEST_DIRNAME}/../../.." && pwd -P)

setup() {
	load "${BASE_DIR:?}/test/test_helper/bats-support/load"
	load "${BASE_DIR:?}/test/test_helper/bats-assert/load"
	load "${BASE_DIR:?}/test/test_helper/functions.bash"
	load "${BASE_DIR:?}/test/test_helper/test_path.bash"

	prepare_test_path
	install_test_script urlencode "${BASE_DIR}/lib/url/urlencode.sh"
}

@test "empty string" {
	run urlencode ''
	assert_output ''
}

@test "'word'" {
	run urlencode 'word'
	assert_output 'word'
}

@test "'hello world'" {
	run urlencode 'hello world'
	assert_output 'hello%20world'
}

@test "percent-encoding is capitalised" {
	run urlencode '/'
	assert_output '%2F'
}

@test "uses only built-ins and awk" {
	ipath=$(isolated_path awk)

	input='this is a test.'

	PATH=${ipath} run "$(command -v urlencode)" "${input}"
	assert_output 'this%20is%20a%20test.'
}

@test "RFC 3986 reserved characters" {
	input='!#$&'\''()*+,/:;=?@[]'
	expected='%21%23%24%26%27%28%29%2A%2B%2C%2F%3A%3B%3D%3F%40%5B%5D'

	run urlencode "${input}"
	assert_output "${expected}"
}

@test "RFC 3986 unreserved characters" {
	input='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~'
	expected='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~'

	run urlencode "${input}"
	assert_output "${expected}"
}

@test "multi-line string (LF)" {
	input=$'this string consists of\nmultiple lines.'
	expected="this%20string%20consists%20of%0Amultiple%20lines."

	run urlencode "${input}"
	assert_output "${expected}"
}

@test "multi-line string (CRLF)" {
	input=$'this string consists of\r\nmultiple lines.'
	expected="this%20string%20consists%20of%0D%0Amultiple%20lines."

	run urlencode "${input}"
	assert_output "${expected}"
}

@test "multi-byte UTF-8 character (€)" {
	run urlencode '€'
	assert_output '%E2%82%AC'
}

@test "japanese UTF-8 characters (円)" {
	# source: https://en.wikipedia.org/wiki/URL_encoding#Character_data
	run urlencode '円'
	assert_output '%E5%86%86'
}