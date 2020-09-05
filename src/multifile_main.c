/**
 * This example shows how we can compile multiple source files into an executable
 * binary. The main function calls functions defined in multifile_func.h and
 * implemented in multifile_func.
 */

#include "multifile_func.h"

int main(void)
{
	say_hello();
	print_the_time();

	return 0;
}
