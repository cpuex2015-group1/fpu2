#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "float.h"
#include "fmul.h"

#define DIFF_COUNT_MAX 10

int main()
{
  int32_t i, j=0;
  char output_str[100], expect_str[100], a_str[100], b_str[100], str[100];
  f32_uint output, expect, a, b;

  uint32_t diff_count[DIFF_COUNT_MAX*2];
  int64_t sum=0, e=0, v=0, overflow = 0, underflow = 0;
  for (i=0; i<DIFF_COUNT_MAX*2; i++) diff_count[i] = 0;

  FILE *output_file, *expect_file, *checker_file;
  if ( ((output_file = fopen("../fmul_sim/output.dat", "r")) == NULL)
    || ((expect_file = fopen("fmul_expected.dat", "r")) == NULL)
    || ((checker_file = fopen("fmul_checker.dat", "r")) == NULL))
  {
    fprintf(stderr, "file err\n"); return 1;
  }

  int m2, m1, z, p1, p2, o;
  m2 = m1 = z = p1 = p2 = o = 0;
  for (i=0; i<1000000; i++)
  {
  	fscanf(output_file, "%s", output_str);
  	fscanf(expect_file, "%s", expect_str);
  	fscanf(checker_file, "%s %s %s", str, a_str, b_str);

  	a.ui = strtol(a_str, NULL, 2);
  	b.ui = strtol(b_str, NULL, 2);
  	output.ui = strtol(output_str, NULL, 2);
  	// output.ui = fmul(a.ui, b.ui);
  	
    // expect.ui = strtol(expect_str, NULL, 2);
    expect.ui = fmul(a.ui, b.ui);

  	int32_t diff = output.ui - expect.ui;

  	if (diff < -1 || 1 < diff)
  	{
  		printf("#%3d diff:\n", i);
  		printf("       a: ");
  		// print4(dec2bin(a.ui,32,str));
  		print_float(a.ui);
  		printf(" (%+.30e)", a.fl);
  		puts("");
  		printf("       b: ");
  		// print4(dec2bin(b.ui,32,str));
  		print_float(b.ui);
  		printf(" (%+.30e)", b.fl);
  		puts("");
  		printf("  output: ");
  		// print4(dec2bin(output.ui,32,str));
  		print_float(output.ui);
  		printf(" (%+.30e)", output.fl);
  		puts("");
  		printf("  expect: ");
  		// print4(dec2bin(expect.ui,32,str));
  		print_float(expect.ui);
  		printf(" (%+.30e)", expect.fl);
  		puts("");
  		printf("    diff: ");
  		// print4(dec2bin(diff,32,str));
      print_float(output.ui ^ expect.ui);
  		// print_float(- output.ui + expect.ui);
  		printf(" (%d)", diff);
  		puts("");
      // printf("      HL: ");
      // // print4(dec2bin(diff,32,str));
      // print_float((a.mhi|IMPL1)*b.mlo);
      // printf(" (%d)", diff);
      // puts("");
      // printf("      LH: ");
      // // print4(dec2bin(diff,32,str));
      // print_float((b.mhi|IMPL1)*a.mlo);
      // printf(" (%d)", diff);
      // puts("");
      // printf("      LL: ");
      // // print4(dec2bin(diff,32,str));
      // print_float((a.mlo*b.mlo)>>13);
      // printf(" (%d)", diff);
      // puts("");
  		puts("");

      if (a.expo == 0 || b.expo == 0)
        m2++;
  	}
    
    if (-1 <= diff && diff <= 1)
      diff_count[diff+DIFF_COUNT_MAX-1] ++;
    else
      overflow++;

    if (a.expo == 0 || b.expo == 0)
      m1++;


    // // if ((diff <= -DIFF_COUNT_MAX) || (DIFF_COUNT_MAX < diff ))
    // if (abs(diff) > 101)
    // {
    //   overflow ++;
    // } else
    // // if (diff >   DIFF_COUNT_MAX)
    // // {
    // //   overflow ++;
    // // } else
    // // if (diff <= -DIFF_COUNT_MAX) {
    // //   overflow ++;
    // // } else
    // {
    //   diff_count[diff+DIFF_COUNT_MAX-1] ++;
    // }
  }

  for (i=0; i<DIFF_COUNT_MAX*2; i++)
  {
    fprintf(stderr, "%+4dulp:%11u\n", i-DIFF_COUNT_MAX+1, diff_count[i]);
    sum += diff_count[i];
  }
  fprintf(stderr, "-------------------\n");
  fprintf(stderr, "sum:%15ld\n", sum);
  fprintf(stderr, "ouf:%15ld\n", overflow);
  fprintf(stderr, "  of denorm:%7d\n", m2);
  fprintf(stderr, "-------------------\n");

  fprintf(stderr, "denorm:%12d\n", m1);

  fclose(output_file);
  fclose(expect_file);
  fclose(checker_file);

  return 0;
}
