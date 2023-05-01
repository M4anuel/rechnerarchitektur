#include <stdio.h>

int add(int a, int b)
{
    return a + b;
}

int multiply(int a, int b)
{
    return a * b;
}

int main()
{
    int (*function[])(int, int) = {add, multiply};
    int (*p)(int, int) = *function;

    printf("%d ", (*(p++))(2, 3));
    printf("%d", (*(--p))(2, 3));

    return 0;
}
