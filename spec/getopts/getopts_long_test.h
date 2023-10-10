// header file containing utility functions for the C programs

#define _GNU_SOURCE

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>

#define NUL '\0'
#define EMPTY_STRING(s) (s && NUL == *s)

// helpers

char *shquot(const char *s) {
	if (NULL == s) { return NULL; }

	size_t len = strlen(s);

	size_t rlen = (2 + len);
	for (const char *p = s-1; (p = strstr(p+1, "'"));) { rlen += 3; }

	char *res = calloc((rlen + 1), sizeof(char));
	if (NULL == res) { return NULL; }

	const char *p = s;
	size_t i = 0;
	res[i++] = '\'';
	for (; i < (rlen - 1); ++i) {
		if (NUL == *p) { break; }
		if ('\'' == *p) {
			if ((i + 3 + 1) >= rlen) { goto fail; }
			res[i++] = '\''; res[i++] = '\\'; res[i++] = '\''; res[i] = '\'';
			++p;
		} else {
			res[i] = *(p++);
		}
	}
	res[i++] = '\'';
	res[i++] = NUL;

	return res;
  fail:
	free(res);
	return NULL;
}

char *dump_stream(FILE *stream) {
	// from beginning to current position
	long len = ftell(stream);

	char *buf = malloc(len+1);
	buf[0] = NUL;

	rewind(stream);
	fread(buf, sizeof(*buf), len, stream);
	buf[len] = NUL;

	(void)fseek(stream, len, SEEK_SET);
	return buf;
}

void chomp(char *buf) {
	size_t len = strlen(buf);
	if ('\n' == buf[len-1]) {
		buf[len-1] = NUL;
	}
}

char *shift_argv(int *argc, char **argv[]) {
	if (2 > *argc) { return NULL; }

	char *first = (*argv)[1];

	for (int i = 2; i < (*argc); ++i) {
		(*argv)[i-1] = (*argv)[i];
	}
	(*argv)[(*argc)-1] = NULL;
	--(*argc);

	return first;
}


struct option *optstring_to_longopts(const char *optstring) {
	static int __flag;

	size_t i;
	size_t nopts = 0;

	if (optstring && ':' == *optstring) {
		/* ignore leading : for error suppression */
		++optstring;
	}

	if (!EMPTY_STRING(optstring)) {
		++nopts;
		for (i = 0; optstring[i]; ++i) {
			if (',' == optstring[i]) { ++nopts; }
		}
	}

	if (1 > nopts) { return NULL; }

	struct option *longopts = calloc(nopts+1, sizeof(struct option));
	if (NULL == longopts) { return NULL; }

	char *s = strdup(optstring);

	i = 0;
	char *t = strtok(s, ",");
	do {
		switch (t[strlen(t)-1]) {
		case ':':
			t[strlen(t)-1] = NUL;
			longopts[i].has_arg = required_argument;
			break;
		case '?':
			t[strlen(t)-1] = NUL;
			longopts[i].has_arg = optional_argument;
			break;
		default:
			longopts[i].has_arg = no_argument;
			break;
		}

		longopts[i].name = strdup(t);
		longopts[i].flag = &__flag;
		longopts[i].val = i;
	} while ((++i < nopts) && (t = strtok(NULL, ",")));

	free(s);

	return longopts;
}

void free_longopts(struct option *longopts) {
	if (NULL == longopts) { return; }

	for (struct option *p = longopts; p->name; ++p) {
		free((char *)p->name);
	}
	free(longopts);
}

void print_longopts(struct option *longopts) {
	if (NULL == longopts) {
		printf("%s\n", (const char *)NULL);
		return;
	}

	printf("{\n");
	for (struct option *p = longopts; (p->name); ++p) {
		printf(
			"\t{ .name = \"%s\", .has_arg = %s, int val = %u },\n",
			p->name,
			( required_argument == p->has_arg ? "required_argument"
			: optional_argument == p->has_arg ? "optional_argument"
			: no_argument == p->has_arg ? "no_argument"
			: "?"),
			p->val);
	}
	printf("}\n");
}

void print_argv(int argc, char *const *argv) {
	for (int i = 0; i < argc; ++i) {
		printf("%s'%s'", (i ? " " : ""), argv[i]);
	}
	printf("\n");
}
