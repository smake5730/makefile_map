/**
 * This example shows how we can compile multiple source files into an executable
 * binary. The main function calls functions defined in multifile_func.h and
 * implemented in multifile_func.
 */

#include "multifile_func.h"
#include <stdio.h>
#include <time.h>

void say_hello(void)
{
	printf("Hello, human. How are you today?\n");
}

void print_the_time(void)
{
	time_t currrent_time;

	time(&currrent_time);

	// No '\n' in the format string because ctime adds one
	printf("Right now it is: %s", ctime(&currrent_time));
}
