#include <stdio.h>
#include "stack-buffer.h"

int main() {
  int c = overflow();
  printf("%d", c);
}
