#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "float.h"
#include "fmul.h"

int main()
{
  int64_t i, j;
  char str1[100], str2[100], str3[100], str4[100], str5[100];

  f32_uint a, b, c;

  FILE *in, *out, *all;
  if ( ((in  = fopen("fmul_input.dat", "w")) == NULL)
    || ((out = fopen("fmul_expected.dat", "w")) == NULL)
    || ((all = fopen("fmul_checker.dat", "w")) == NULL))
  {
    fprintf(stderr, "file err\n"); return 1;
  }

  int k=0;
  for (i=0; i<1000000; i++)
  // for (i=0; i<1000000; i++)
  {
    a.ui = rand() * 2 + rand()%2;
    b.ui = rand() * 2 + rand()%2;

    // a.expo = 0;
    // a.expo = (1<<8)-1;
    // b.frac = 0;
    // a.frac = 0;

    c.fl = a.fl * b.fl;
    // c.sign = a.sign ^ b.sign;
    // c.fl = fmul(a.ui, b.ui);
    // c.fl = fmul(a.ui, b.ui);


    if ( (a.expo == 0)
      || (a.expo == ((1<<8) - 1))
      || (b.expo == 0)
      || (b.expo == ((1<<8) - 1))
      )
    {
      k++;
      i--;
      continue;
    }

    if (c.expo == 0)
    {
      i--;
      continue;
    }

    // if (c.expo == 0)
    //   c.frac = 0;

    // if (c.expo == (1<<8) - 1)
    //   c.frac = 0;

    fprintf(in,  "%s\n", dec2bin(a.ui, 32, str1));
    fprintf(in,  "%s\n", dec2bin(b.ui, 32, str1));
    fprintf(out, "%s\n", dec2bin(c.ui, 32, str1));
    fprintf(all, "%s %s %s\n", dec2bin(c.ui, 32, str1),dec2bin(a.ui, 32, str2), dec2bin(b.ui, 32, str3));
  }

  fprintf(stderr, "%d\n", k);

  fclose(in);
  fclose(out);
  fclose(all);

  return 0;
}
