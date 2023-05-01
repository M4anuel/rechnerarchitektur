#include <stdio.h>

#include "vector.h"
#include "vector_printing.h"


int main() {
    // initialization
    Vector vectors[] = {{5, -4, "a"},
                        {-2.5, 1.5, "b"}};
    size_t num_vectors = sizeof(vectors) / sizeof(vectors[0]);

    Vector *pvectors[num_vectors];
    for (size_t i = 0; i < num_vectors; ++i) {
        pvectors[i] = &vectors[i];
    }
    print_vectors(pvectors, num_vectors);
    printf("\n");
    
    // sum
    Vector manually_calculated_sum = {2.5, -2.5, ""};
    Vector result_sum = sum(pvectors, num_vectors);

    print_vector(&result_sum);
    verify_and_print(&result_sum, &manually_calculated_sum);

    printf("\n");

    // scalar multiplication
    Vector manually_calculated_scalar_multiplication = {6.0, -4.8, ""};
    Vector result_scalar_multiplication = multiply(*pvectors, 1.2);

    print_vector(&result_scalar_multiplication);
    verify_and_print(&result_scalar_multiplication, &manually_calculated_scalar_multiplication);

    printf("\n");

    // norm
    Vector manually_calculated_norm_squared = {41.0, 8.5, ""};
    Vector result_norm_squared = {norm_squared(*pvectors), norm_squared(*(pvectors + 1)), "norms"};

    print_vector(&result_norm_squared);
    verify_and_print(&result_norm_squared, &manually_calculated_norm_squared);

    printf("\n");

    // dot product
    Vector manually_calculated_dot_product = {-18.5, norm_squared(*pvectors), ""};
    Vector result_dot_product = {dot_product(*pvectors, *(pvectors + 1)), dot_product(*pvectors, *pvectors), "<a, b> and <a, a>"};

    print_vector(&result_dot_product);
    verify_and_print(&result_dot_product, &manually_calculated_dot_product);

    printf("\n");

    // rotation
    Vector manually_calculated_rotated_vector = {4, 5, ""};
    Vector result_rotated_vector = rotation(*pvectors, 90);

    print_vector(&result_rotated_vector);
    verify_and_print(&result_rotated_vector, &manually_calculated_rotated_vector);

    printf("\n");

    // orthogonality
    Vector manually_calculated_orthogonal = {0.0, 0.0, ""};

    Vector rotated_first_vector = rotation(pvectors[0], 90);
    Vector rotated_second_vector = rotation(pvectors[1], 90);

    Vector result_dot_product_orthogonal = {dot_product(*pvectors, &rotated_first_vector),
                                            dot_product(*(pvectors + 1), &rotated_second_vector),
                                            "dot products of orthogonal"};

    print_vector(&result_dot_product_orthogonal);
    verify_and_print(&result_dot_product_orthogonal, &manually_calculated_orthogonal);

    printf("\n");

    return 0;
}
