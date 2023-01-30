#!/usr/bin/env bats

BATS_TEST_NAME_PREFIX='quote/shquot: '

BASE_DIR=$(cd "${BATS_TEST_DIRNAME}/../../.." && pwd -P)

ARG_MAX=$(getconf ARG_MAX 2>/dev/null)
test $((ARG_MAX)) -gt 0 || ARG_MAX=$((64 * 1024))

# some space for the environment
STRING_MAX_LEN=$((ARG_MAX - 8192))

shquot() {
	"${SHELL:-sh}" "${BASE_DIR}/lib/quote/shquot.sh" "$@"
}
setup() {
	load "${BASE_DIR:?}/test/test_helper/bats-support/load"
	load "${BASE_DIR:?}/test/test_helper/bats-assert/load"
}

random_string() {
	# usage: random_string [length] [character classes]
	LC_ALL=C tr -dc "${2-'[:print:]'}" </dev/urandom \
	| dd bs=1 count=${1-128} 2>/dev/null
}

@test "empty string" {
	run shquot ''
	assert_output "''"
}

@test "'word'" {
	run shquot 'word'
	assert_output "'word'"
}

@test "'hello world'" {
	run shquot 'hello world'
	assert_output "'hello world'"
}

@test "string containing double quotes (property test)" {
	iterations=20

	while test $((iterations-=1)) -ge 0
	do
		format='a string which contains a double quote "%s" in the middle.'
		quote=$(random_string 32 '[:alnum:][:blank:]')

		input=$(printf "${format}" "${quote}")
		expected=$(printf "'${format}'" "${quote}")

		run shquot "${input}"
		assert_output "${expected}"
	done
}


@test "string containing single quotes (property test)" {
	iterations=20

	while test $((iterations-=1)) -ge 0
	do
		format="a string which contains a single quote '%s' in the middle."
		quote=$(random_string 32 '[:alnum:][:blank:]')

		input=$(printf "${format}" "${quote}")
		expected=$(printf "'$(sed "s/'/'\\\\\\\\''/g" <<<"${format}")'" "${quote}")

		run shquot "${input}"
		assert_output "${expected}"
	done
}

@test "eval of quoted string in shell produces input (property test)" {
	iterations=20

	while test $((iterations-=1)) -ge 0
	do
		input=$(random_string)
		quoted=$(shquot "${input}")

		run eval "printf %s ${quoted}"
		assert_output "${input}"
	done
}

# @test "very long string ($((STRING_MAX_LEN)) bytes)" {
# 	input=$(random_string $((STRING_MAX_LEN)) '[:alnum:][:space:]')
# 	run "${SHQUOT}" "${input}"
# 	assert_output "'${input}'"
# }
