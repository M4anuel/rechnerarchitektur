/*
 * author:   Manuel Flückiger
 * modified:    2023-04-17
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include "memory.h"
#include "memory.c"
#include "mips.h"
#include "mips.c"
#include "compiler.h"
#include "compiler.c"

int main ( int argc, char** argv ) {
    if (argc != 3)
    {
        printf("usage: <commandname> expression filename");
    }
    else 
    {
        printf("Input:\t %s \nPostfix:", argv[1]);

        compiler(argv[1], argv[2]);

        printf("\nMIPS binary saved to %s", argv[2]);
    }
    return EXIT_SUCCESS;
}

