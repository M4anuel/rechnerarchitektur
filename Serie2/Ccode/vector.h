#pragma once

#include <string.h>
#include <stdbool.h>
#include <math.h>

# define PI 3.14159265358979323846


struct Vector {
    float x;
    float y;
    char name[50];
};

typedef struct Vector Vector;


bool compare(Vector *first_vector, Vector *second_vector) {
    if (fabs(first_vector->x - second_vector->x) < 1.0e-5 && fabs(first_vector->y - second_vector->y) < 1.0e-5) {
        return true;
    } else {
        return false;
    }
}


Vector sum(Vector *vectors[], size_t num_vectors) {
    // return a sum of all vectors. This sum will also be a vector!

    Vector result= {0, 0, ""};

    for(size_t i = 0; i < num_vectors; ++i){
        result.x += vectors[i]->x;
        result.y += vectors[i]->y;
        strcat(result.name, vectors[i]->name);

        if (i < num_vectors -1){
            strcat(result.name, "+");
        }
    }
    // Hint: use strcat function to create a nice name of sum vector
    return result;
}


Vector multiply(Vector *vector, float scalar) {
    // return a vector multiplied by a scalar. The result will also be a vector!
    Vector result={vector->x * scalar, vector->y * scalar, ""};

    char scalar_str[10];
    sprintf(scalar_str, "%.2f", scalar);  // e.g, scalar = 1.23 --> scalar_str = "1.23"
    strcat(result.name, scalar_str);
    strcat(result.name, " *");
    strcat(result.name, vector->name);
    
    // Hint: use strcat function to create a nice name of this vector
    return result;
}


float norm_squared(Vector *vector) {
    // return the squared norm (L2 squared norm / euclidean norm) of a vector

    return (vector->x) * (vector->x) + (vector->y) * (vector->y) ;
}


float dot_product(Vector *first_vector, Vector *second_vector) {
    // return dot product of two vectors
    return (first_vector->x) * (second_vector->x) + (first_vector->y) * (second_vector->y);
}

Vector rotation(Vector *vector, float angle) {
    // return vector rotated by {angle} degrees
    float radians = (angle * PI)/180;
    Vector result={ (vector->x) * cos(radians) - (vector->y) * sin(radians),
                    (vector->x) * sin(radians) + (vector->y) * cos(radians),
                     ""};

    char angle_str[10];
    sprintf(angle_str, "%.2f", angle);  // e.g, angle = 23.5 --> angle_str = "23.5"
    strcat(result.name, vector->name);
    strcat(result.name, " rotated ");
    strcat(result.name, angle_str);
    strcat(result.name, " degrees");

    // Hint: use strcat function to create a nice name of this vector
    return result;
}
