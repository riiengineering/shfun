// $CC -g -std=c99 -o proc_options proc_options.c

#include "getopts_long_test.h"

#include <stdio.h>
#include <getopt.h>

int main(int argc, char *argv[]) {
	char *optstring = shift_argv(&argc, &argv);
	if (NULL == optstring) {
		return 1;
	}

	struct option *longopts = optstring_to_longopts(optstring);

	int c, longidx;
	while (0 <= (c = getopt_long(
		            argc, argv,
		            ((!EMPTY_STRING(optstring) && ':' == optstring[0]) ? ":" : ""),
		            longopts,
		            &longidx))) {
		switch (c) {
		case '?':
			break;
		default:
			printf("%s", longopts[longidx].name);
			if (optarg) {
				printf("=%s", optarg);
			}
			break;
		}
		printf("\n");
	}

	if (argc > optind) {
		printf("\n");
		for (int i = optind; i < argc; ++i) {
			printf("%s%s", (i > optind ? " " : ""), argv[i]);
		}
		printf("\n");
	}

	return 0;
}
