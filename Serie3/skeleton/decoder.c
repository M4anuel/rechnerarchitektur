/*
 * author:   Manuel Flückiger
 * modified:    2023-04-17
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

typedef uint32_t word;
long get_file_size(char *);

word decode (unsigned char buffer[4]){
    word w = 0;
    int i;
    for (i = 0; i < 4; i++) {
        w = (w << 8) | (buffer[i] & 0xFF);
    }
    return w;
}

word decode2 (unsigned char buffer[4]){
    FILE *fptr;
    word w = 0;
        w+= buffer[3];
        w+= (buffer[2] << 1*8);
        w+= (buffer[1] << 2*8);
        w+= (buffer[0] << 3*8);
    return w;
}
int main(int argc, char **argv)
{
    char filename[] = "test.mips";
    FILE *fptr;

    unsigned char buffer[4];//32bit string

    fptr = fopen(filename, "rb"); // r for read, b for binary
    
    for (int i = 0; i < get_file_size(filename)/4; i++){
        fseek(fptr, sizeof(buffer)*i, SEEK_SET);
        fread(buffer, sizeof(buffer), 1, fptr);

        printf("%x ",decode2(buffer));

        //for (int j = 0; j < 4; j++)
         //   printf("%02x ", buffer[j]);
        printf("\n");
    }

    return EXIT_SUCCESS;
}
long get_file_size(char *filename) {
    FILE *fp = fopen(filename, "r");

    if (fp==NULL)
        return -1;

    if (fseek(fp, 0, SEEK_END) < 0) {
        fclose(fp);
        return -1;
    }

    long size = ftell(fp);
    // release the resources when not required
    fclose(fp);
    return size;
}


