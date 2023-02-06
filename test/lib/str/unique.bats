#!/usr/bin/env bats
bats_require_minimum_version 1.8.0

BATS_TEST_NAME_PREFIX='str/unique: '

BASE_DIR=$(cd "${BATS_TEST_DIRNAME}/../../.." && pwd -P)

setup() {
	load "${BASE_DIR:?}/test/test_helper/bats-support/load"
	load "${BASE_DIR:?}/test/test_helper/bats-assert/load"
	load "${BASE_DIR:?}/test/test_helper/functions.bash"
	load "${BASE_DIR:?}/test/test_helper/test_path.bash"

	prepare_test_path
	install_test_script unique "${BASE_DIR}/lib/str/unique.sh"
}

@test "no input" {
	run unique <<<''
	assert_output ''
	assert_success
}

@test "unique lines" {
	lines=$'foo\nbar\nbaz'

	run unique <<<"${lines}"
	assert_line -n 0 foo
	assert_line -n 1 bar
	assert_line -n 2 baz
}

@test "removes repeated lines" {
	input=
	expected=

	for _l in pledari glossari parola floscla lieu persuna famiglia programmar
	do
		input=${input}$'\n'${_l}
		while test $((RANDOM)) -ge 20000
		do
			input=${input}$'\n'${_l}
		done

		expected=${expected}$'\n'${_l}
	done

	run unique <<<"${input}"
	assert_output "${expected}"
}

@test "collapses empty lines" {
	input=
	expected=
	for _l in linguatg quint unic incumparabel navigaziun memorisar
	do
		input=${input}$'\n'${_l}
		while test $((RANDOM)) -ge 20000
		do
			input=${input}$'\n'
		done

		expected=${expected}$'\n'${_l}
	done

	run unique <<<"${input}"
	assert_output "${expected}"
}

@test "uses only built-ins and awk" {
	ipath=$(isolated_path awk)

	input=$'foo\nfoo\nbar\nbaz\nbar'
	expected=$'foo\nbar\nbaz'

	PATH=${ipath} run "$(command -v unique)" <<<"${input}"
	assert_output "${expected}"
	assert_success
}
