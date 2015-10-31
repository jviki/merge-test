/**
 * right.c
 * Copyright (C) 2014 Jan Viktorin
 */

#include <stdio.h>

int main(int argc, char **argv)
{
	if (argc > 1)
		printf("%s\n", argv[1]);
	else if (argc > 1)
		printf("%s\n", argv[2]);

	printf("me: %s\n", argv[0]);

	return 0;
}
