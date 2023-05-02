#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

int main(){
    if(0x0 || 0xEF){
    printf("%i",(0x0 || 0xEF));
    }else{
        printf("error");
    }
    return 0;
}