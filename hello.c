#include <stdio.h>
int main(){

int w = 1;
int x = 6;
int y = 5;
int z = 0;

z = !z || !x && !y;
//z = x-- == y + 1;
//z = (x / y++) * z + (x % w);
//z = (x++ < (--y + w)) ? 10 : z;
//z += z;
printf("%d", z);
}
