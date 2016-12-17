#include <stdio.h>
#include <stdlib.h>
#include "ulity.h"

void *int_to_pointer(int i)
{
   int *pi = (int *)malloc(sizeof(int));
   *pi = i;
   return (void*)pi;
}

void *float_to_pointer(float f);
{
   float *pf = (float *)malloc(sizeof(float));
   *pf = f;
   return (void*)pf;
}

int pointer_to_int(void *pi);
{
   return *((int*)pi);
}

float pointer_to_float(void *pf);
{
   return *((float*)pf);
}


