#include <stdio.h>

#include "Addition.h"
#include "Multiply.h"

int my_xor(int a, int b) { return a ^ b; }

int main()
{
    int x = 4;
    int y = 5;

    int z1 = Addition::twoValues(x, y);
    printf("\nAddition Result: %d\n", z1);

    int z2 = Multiply::twoValues(x, y);
    printf("Multiply Result: %d\n", z2);

    int z3 = my_xor(x, y);
    printf("XOR result is %d\n", z3);

    return 0;
}
