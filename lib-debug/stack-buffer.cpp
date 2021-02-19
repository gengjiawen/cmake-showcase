#include "stack-buffer.h"
#include <stdio.h>

int overflow() {
  printf("segement fault");
  *((int*)0x8100000000000000) = 5;

  printf("overflow");
  int* array = new int[100];
  array[0] = 0;
  int res = array[1 + 100];  // BOOM
  delete[] array;
  return res;
}