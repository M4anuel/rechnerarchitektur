#include <stdio.h>

#include "vector.h"

#define RED "\x1B[31m"
#define GREEN "\x1B[32m"
#define RESET "\x1B[0m"


void print_vector(const Vector *vector) {
    // print vector's fields: name and coordinates [x, y] in a row
    printf("%s [%.2f, %.2f]\n", vector->name, vector->x, vector->y);
}


void print_vectors(Vector *vectors[], size_t num_vectors) {
    // print info about each vector row by row using print_vector function above
    for (size_t i = 0; i < num_vectors; i++){
        print_vector(vectors[i]);
        printf("\n");
    }
}

void verify_and_print(Vector *vector, Vector *ground_truth_vector) {
    if (compare(vector, ground_truth_vector)) {
        printf(GREEN " --> OK\n" RESET);
    } else {
        printf(RED " --> ERROR\n");
        printf("Result is not equal to");
        print_vector(ground_truth_vector);
        printf("\n" RESET);
    }
}
