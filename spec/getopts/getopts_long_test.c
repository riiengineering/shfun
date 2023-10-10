// $CC -g -std=c99 -o getopts_long_test getopts_long_test.c

#include "getopts_long_test.h"

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <inttypes.h>
#include <unistd.h>

#define DEBUG 0

struct test_data {
	const char *it;
	const char *optstring;
	int optind;
	const char *optarg;
	char **argv;
	int argc;
};
#define NUM_STR_ARGS(...) (sizeof((char *[]){__VA_ARGS__})/sizeof(char *))
#define TEST_ARGV(...) ((char *[]){__FILE__, __VA_ARGS__}), .argc = (NUM_STR_ARGS(__VA_ARGS__)+1)

struct test_data TESTS[] = {
	{
		.it = "reports end of options with an empty optstring and no arguments",
		.optstring = "",
		.argv = TEST_ARGV()
	},
	{
		.it = "reports end of options when no options are passed",
		.optstring = "foo",
		.argv = TEST_ARGV()
	},
	{
		.it = "prints an error when unsupported options are passed",
		.optstring = "foo,bar,baz",
		.argv = TEST_ARGV("--illegal")
	},
	{
		.it = "returns an unsupported option in OPTARG_LONG if the optstring starts with :",
		.optstring = ":foo,bar,baz",
		.argv = TEST_ARGV("--illegal")
	},
	{
		.it = "extracts required arguments in next ARGV",
		.optstring = "required:",
		.argv = TEST_ARGV("--required", "foo")
	},
	{
		.it = "extracts a required argument in next ARGV starting with -",
		.optstring = "required:",
		.argv = TEST_ARGV("--required", "-not-an-option")
	},
	{
		.it = "extracts a required argument in next ARGV starting with --",
		.optstring = "required:",
		.argv = TEST_ARGV("--required", "--not-an-option")
	},
	{
		.it = "extracts required arguments after =",
		.optstring = "required:",
		.argv = TEST_ARGV("--required=foo")
	},
	{
		.it = "prints an error if a required argument is missing",
		.optstring = "required:",
		.argv = TEST_ARGV("--required")
	},
	{
		.it = "returns the option in OPTARG_LONG if a required argument is omitted and the optstring starts with :",
		.optstring = ":required:",
		.argv = TEST_ARGV("--required")
	},
	{
		.it = "accepts empty arguments",
		.optstring = "required:",
		.argv = TEST_ARGV("--required", "")
	},
	{
		.it = "ignores optional arguments in next ARGV",
		.optstring = "optional?",
		.argv = TEST_ARGV("--optional", "foo")
	},
	{
		.it = "extracts optional arguments after =",
		.optstring = "optional?",
		.argv = TEST_ARGV("--optional=foo")
	},
	{
		.it = "sets OPTARG_LONG if an empty argument is passed after =",
		.optstring = "optional?",
		.argv = TEST_ARGV("--optional="),
		.optarg = "something"
	},
	{
		.it = "unsets OPTARG_LONG if no optional argument is passed",
		.optstring = "optional?",
		.argv = TEST_ARGV("--optional"),
		.optarg = "something"
	},
	{
		.it = "prints an error if an unexpected argument is passed for a flag option (after =)",
		.optstring = "flag",
		.argv = TEST_ARGV("--flag=2"),
		.optarg = "something"
	},
	{
		.it = "handles an unexpected argument passed after a flag= option (optstring leading :)",
		.optstring = ":flag",
		.argv = TEST_ARGV("--flag=2")
	},
	{
		.it = "ignores an argument passed after a flag in the next ARGV",
		.optstring = "flag",
		.argv = TEST_ARGV("--flag", "2")
	},
	{
		.it = "reports end of options when reaching a positional argument",
		.optstring = "flag",
		.argv = TEST_ARGV("--flag", "2"),
		.optind = 2
	},
	{
		.it = "respects --",
		.optstring = "flag1,flag2,flag3",
		.argv = TEST_ARGV("--flag1", "--", "--flag3"),
		.optind = 2
	},
	{}
};




/* test functions */

struct test_result {
	int return_value;
	char *longoption;

	int optind;
	int opterr;
	int optopt;
	char *optarg;

	char *stdout_data;
	char *stderr_data;
};

void free_test_result(struct test_result *r) {
	if (r->longoption) { free(r->longoption); }
	if (r->optarg) { free(r->optarg); }
	if (r->stdout_data) { free(r->stdout_data); }
	if (r->stderr_data) { free(r->stderr_data); }
	free(r);
}

struct test_result *exec_test(struct test_data *test_data) {
	struct option *longopts = optstring_to_longopts(test_data->optstring);

#if DEBUG
	printf("ARGV = (%d) ", test_data->argc);
		print_argv(test_data->argc, test_data->argv);
	printf("optstring = %s\n", test_data->optstring);
	printf("longopts = "); print_longopts(longopts);
#endif

	FILE *_stdout = tmpfile();
	FILE *_stderr = tmpfile();

	int old_stdout = dup(1);
	int old_stderr = dup(2);

	dup2(fileno(_stdout), 1);
	dup2(fileno(_stderr), 2);

	char *optarg_set = (test_data->optarg ? strdup(test_data->optarg) : NULL);

	int longidx = -1;
	optind = (1 < test_data->optind ? test_data->optind : 1);
	if (optarg_set) {
		optarg = optarg_set;
	}
	int c = getopt_long(
		test_data->argc, test_data->argv,
		((!EMPTY_STRING(test_data->optstring) && ':' == test_data->optstring[0]) ? ":" : ""),
		longopts,
		&longidx);

	dup2(old_stdout, 1);
	dup2(old_stderr, 2);

	struct test_result *res = malloc(sizeof(struct test_result));
	if (NULL == res) { return NULL; }

	struct option *opt = (longopts && 0 <= longidx && longopts[longidx].name)
		? &longopts[longidx]
		: NULL;

	res->return_value = c;
	res->longoption = (opt ? strdup(opt->name) : NULL);

	res->optind = optind;
	res->opterr = opterr;
	res->optopt = optopt;
	res->optarg = (optarg ? strdup(optarg) : NULL);

	res->stdout_data = dump_stream(_stdout);
	chomp(res->stdout_data);
	res->stderr_data = dump_stream(_stderr);
	chomp(res->stderr_data);

	if (optarg_set) { free(optarg_set); }
	free_longopts(longopts);

	fclose(_stdout);
	fclose(_stderr);

	return res;
}

void run_test(struct test_data *test_data) {
	struct test_result *res = exec_test(test_data);
	free_test_result(res);
}

void spec_test(struct test_data *test_data) {
	struct test_result *res = exec_test(test_data);

	char *example_name_q = shquot(test_data->it);
	char *optstring_q = shquot(test_data->optstring);

	uint8_t status;
	char *_opt_q;
	switch (res->return_value) {
	case '?':
		status = 0;
		_opt_q = shquot("?");
		break;
	case ':':
		status = 0;
		_opt_q = shquot(":");
		break;
	default:
		status = (int8_t)res->return_value;
		_opt_q = shquot(res->longoption);
		break;
	}

	char *optarg_set_q = (test_data->optarg ? shquot(test_data->optarg) : NULL);
	char *optarg_q = (res->optarg ? shquot(res->optarg) : NULL);

	char *stdout_q = shquot(res->stdout_data);
	char *stderr_q = shquot(res->stderr_data);

	printf("  It %s\n", (example_name_q ? example_name_q : "''"));

	if (1 < test_data->optind) {
		printf("    OPTIND_LONG=%u\n", test_data->optind);
	}

	if (optarg_set_q) {
		printf("    OPTARG_LONG=%s\n", optarg_set_q);
	}

	printf("    When call getopts_long %s _opt",
	       (optstring_q ? optstring_q : "''"));
	for (int i = 1; i < test_data->argc; ++i) {
		char *s = shquot(test_data->argv[i]);
		printf(" %s", s);
		if (s) { free(s); }
	}
	printf("\n\n");
	if (0 == status) {
		printf("    The status should be success\n");
	} else {
		printf("    The status should equal %"PRIu8"\n", status);
	}
	printf("    The stdout should equal %s\n", stdout_q);
	printf("    The stderr should equal %s\n", stderr_q);
	printf("\n");

	if (_opt_q) {
		printf("    The variable _opt should equal %s\n", _opt_q);
	} else {
		printf("    The variable _opt should be defined\n");
	}

	if (optarg_q) {
		printf("    The variable OPTARG_LONG should equal %s\n", optarg_q);
	} else {
		printf("    The variable OPTARG_LONG should be undefined\n");
	}

	printf("    The variable OPTIND_LONG should equal %u\n", res->optind);

	printf("  End\n\n");

	if (example_name_q) { free(example_name_q); }
	if (optstring_q) { free(optstring_q); }
	if (_opt_q) { free(_opt_q); }
	if (optarg_set_q) { free(optarg_set_q); }
	if (optarg_q) { free(optarg_q); }

	if (stdout_q) { free(stdout_q); }
	if (stderr_q) { free(stderr_q); }

	free_test_result(res);
}

/* main */
#define MODE_RUN 1
#define MODE_SPEC 2

int main(int argc, char *argv[]) {
	int mode = MODE_RUN;
	if (1 < argc) {
		if (0 == strcasecmp(argv[1], "run")) {
			mode = MODE_RUN;
		} else if (0 == strcasecmp(argv[1], "spec")) {
			mode = MODE_SPEC;
		} else {
			fprintf(stderr, "invalid mode: %s\n", argv[1]);
			return 1;
		}
	}

	for (struct test_data *t = TESTS; (t->it); ++t) {
		switch (mode) {
		case MODE_RUN:
			run_test(t);
			break;
		case MODE_SPEC:
			spec_test(t);
			break;
		}
	}

	return 0;
}
