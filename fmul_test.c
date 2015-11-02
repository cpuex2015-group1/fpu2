#include <stdio.h>
#include <stdint.h>
#include "float.h"
#include "fmul.h"

#define DIFF_COUNT_MAX 8

int main()
{
	int64_t i, j;
	char str1[100], str2[100], str3[100], str4[100], str5[100];

	uint32_t diff_count[DIFF_COUNT_MAX*2];
	int64_t sum=0, e=0, v=0, overflow=0, underflow=0;
	for (i=0; i<DIFF_COUNT_MAX*2; i++) diff_count[i]=0;

	f32_uint inputA, inputB, expected, actual;
	inputA.fl=inputB.fl=0;
	inputA.expo = (1<<7);
	inputB.expo = (1<<7);

	// fprintf(stderr, "%.10e, %.10e\n", inputA.fl, inputB.fl);

	int64_t zero = 0;

	int64_t step = (1<<23)/10;
	for(i=0; i < (1<<23); i++)
	{
		inputA.frac = i;
		for(j=300; j < 350; j++)
		// for(j=0; j < (1<<3); j++)
		{
			inputB.frac = j;

			expected.fl = inputA.fl * inputB.fl;
			actual.ui = fmul(inputA.ui, inputB.ui);

			int diff = actual.ui - expected.ui;
			if (diff > DIFF_COUNT_MAX)
				overflow ++;
			else if (diff <= -DIFF_COUNT_MAX)
				overflow ++;
			else 
				diff_count[diff+DIFF_COUNT_MAX-1] ++;
			// if (actual.ui==0) zero++;
/*
			printf("[%s * %s] (%e * %e = %e)\n", dec2bin(inputA.ui, 32, str1), dec2bin(inputB.ui, 32, str2), inputA.fl, inputB.fl, expected.fl );
			printf("  expected:%s\n", dec2bin(expected.ui, 32, str1));
			printf("    actual:%s\n", dec2bin(actual.ui, 32, str1));
			printf("      diff:%s\n", dec2bin((uint32_t)diff, 32, str1));
//*/
		}
	}
	// fprintf(stderr, "%ld\n", zero);

	for (i=0; i<DIFF_COUNT_MAX*2; i++)
	{
		printf("%+3ld ulp:%11u\n", i-DIFF_COUNT_MAX+1, diff_count[i]);
		sum += diff_count[i];
	}
	printf("-------------------\n");
	printf("sum:%15ld\n", sum);
	for (i=0; i<DIFF_COUNT_MAX*2; i++)
	{
		e += (int64_t)diff_count[i] * (i-DIFF_COUNT_MAX+1);
		v += (int64_t)diff_count[i] * (i-DIFF_COUNT_MAX+1) * (i-DIFF_COUNT_MAX+1);
	}
	printf("exp:%15.5lf\n", (double)e/sum);
	printf("var:%15.5lf\n", (double)v/sum);
	printf(" overflow:%9ld\n", overflow);
	printf("underflow:%9ld\n", underflow);
	printf("-------------------\n");
	printf("total:%13ld\n", sum+overflow+underflow);

	return 0;
}