#include <stdio.h>

int get_number()
{
    static int number = 8;
    return --number;
}

int main()
{
    int number = 1;
    for (number; number; number--)
    {
        printf("%d ", number);
    }

    return 0;
}
