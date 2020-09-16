#include <stdio.h>

#include "Addition.h"
#include "Subtraction.h"
#include "Multiply.h"
#include "Divide.h"

int my_xor(int a, int b) { return a ^ b; }

int main()
{
    int x = 8;
    int y = 2;

    int z1 = Addition::twoValues(x, y);
    printf("Addition Result: %d\n", z1);

    int z2 = Subtraction::twoValues(x, y);
    printf("Subtraction Result: %d\n", z2);

    int z3 = Multiply::twoValues(x, y);
    printf("Multiply Result: %d\n", z3);

    int z4 = Divide::twoValues(x, y);
    printf("Multiply Result: %d\n", z4);

    int z5 = my_xor(x, y);
    printf("XOR result is %d\n", z5);

    return 0;
}
