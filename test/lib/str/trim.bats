#!/usr/bin/env bats
bats_require_minimum_version 1.8.0

BATS_TEST_NAME_PREFIX='str/trim: '

BASE_DIR=$(cd "${BATS_TEST_DIRNAME}/../../.." && pwd -P)

setup() {
	load "${BASE_DIR:?}/test/test_helper/bats-support/load"
	load "${BASE_DIR:?}/test/test_helper/bats-assert/load"
	load "${BASE_DIR:?}/test/test_helper/functions.bash"
	load "${BASE_DIR:?}/test/test_helper/test_path.bash"

	prepare_test_path
	install_test_script trim "${BASE_DIR}/lib/str/trim.sh"
}

@test "reads from stdin if no arguments are passed" {
	run trim <<<'hello world'
	assert_output 'hello world'
	assert_success
}

@test "empty string" {
	run trim ''
	assert_output ''
	assert_success
}

@test "'hello world'" {
	run trim 'hello world'
	assert_output 'hello world'
}

@test "trim prefixes" {
	for _p in ' ' '  ' '	'
	do
		run trim "${_p}hello world"
		assert_output 'hello world'
	done
}

@test "trim suffixes" {
	for _s in ' ' '  ' '	'
	do
		run trim "hello world${_p}"
		assert_output 'hello world'
	done
}

@test "trim prefixes and suffixes" {
	for _s in ' ' '  ' '	'
	do
		run trim "${_p-}hello world${_s}"
		_p=$_s
		assert_output 'hello world'
	done
}

@test "trim removes empty lines" {
	run trim <<-'EOF'
	lorem
	
	
	ipsum
	
	EOF
	assert_output $'lorem\nipsum'
}

@test "trim removes whitespace-only lines" {
	run trim <<-'EOF'
	lorem
	 
	  
	ipsum
	 	
	EOF
	assert_output $'lorem\nipsum'
}

@test "uses only built-ins and sed" {
	ipath=$(isolated_path sed)

	PATH=${ipath} run "$(command -v trim)" '  hello world	'
	assert_output 'hello world'
	assert_success
}
