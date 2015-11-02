#include <stdio.h>
#include <stdint.h>
#include "float.h"
#include "fmul.h"

typedef union exponential
{
	struct
	{
		uint32_t base: 8;
		uint32_t uf: 1;
		uint32_t of: 1;
		uint32_t none: 22;
	};
	uint32_t ui;
} exponential;

uint32_t fmul (uint32_t _a, uint32_t _b)
{
	uint64_t tmp;
	int inf, zero, a_nan, b_nan, a_deno, b_deno;
	int a_deno_count, b_deno_count;
	int a_inf, b_inf, a_zero, b_zero;
	f32_uint a, b, c, hh, hl, lh, ll, c_frac, c_frac_sub, a_hi, b_hi;
	exponential c_expo;

	a.ui = _a;
	b.ui = _b;

	a_nan  = (a.expo == (1<<8)-1) && (a.frac != 0);
	a_inf  = (a.expo == (1<<8)-1) && (a.frac == 0);

	a_zero = (a.expo == 0) && (a.frac == 0);
	a_deno = (a.expo == 0) && (a.frac != 0);

	b_nan  = (b.expo == (1<< 8)-1) && (b.frac != 0);
	b_inf  = (b.expo == (1<< 8)-1) && (b.frac == 0);
	b_zero = (b.expo == 0) && (b.frac == 0);
	b_deno = (b.expo == 0) && (b.frac != 0);

	inf  = a_inf  || b_inf;
	zero = a_zero || b_zero;

	c.sign = a.sign ^ b.sign;
	c_expo.ui = a.expo + b.expo + ((1<<7) + 1);

	a_hi.ui = (a_deno ? a.mhi : (a.mhi|IMPL1));
	b_hi.ui = (b_deno ? b.mhi : (b.mhi|IMPL1));

	hh.ui = a_hi.ui * b_hi.ui;
	hl.ui = a_hi.ui * b.mlo;
	lh.ui = a.mlo * b_hi.ui;
	ll.ui =  a.mlo * b.mlo;


	// v1
	// c_frac.ui = hh.ui + (hl.ui>>10) + (lh.ui>>10) + 2;

	// if (c_frac.q25)
	// {
	// 	c_expo.ui += 1;
	// 	c_frac.ui >>= 2;
	// }
	// else
	// {
	// 	c_expo.ui += 0;
	// 	c_frac.ui >>= 1;
	// }


	// v2
	// c_frac.ui = ((hh.ui<<1) + (hl.ui>>10) + (lh.ui>>10) + 1);
	c_frac.ui = (hh.ui<<1) + 1 + (hl.ui>>10) + (lh.ui>>10);
	c_frac_sub.ui = hl.mlo + lh.mlo + ll.mhi;

	if (a_deno || b_deno)
	{

		int i;
		for (i=26; i>0; i--)
		{

			if (c_frac.ui>>i)
			{
				c_expo.ui += (i-24);
				if (i>23)
				{
					c_frac.ui += c_frac.ui & (1<<(i-24));
					c_frac.ui >>= (i-23);
				} else
				if (i!=23)
				{
					c_frac.ui <<= (23-i);
					c_frac.ui += 1<<(22-i);
				}
				break;
			}
		}

		// if (c_frac.ui>>26)
		// {
		// 	c_expo.ui += (26-24);//2;
		// 	c_frac.ui += c_frac.q02<<2;
		// 	c_frac.ui >>= (26-23);//3;
		// } else
		// if (c_frac.ui>>25)
		// {
		// 	c_expo.ui += (25-24);//1;
		// 	c_frac.ui += c_frac.q01<<1;
		// 	c_frac.ui >>= (25-23);//2;
		// } else
		// if (c_frac.ui>>24)
		// {
		// 	c_expo.ui += (24-24);//0;
		// 	c_frac.ui += c_frac.q00;
		// 	c_frac.ui >>= (24-23);//1;
		// } else
		// if (c_frac.ui>>23)
		// {
		// 	c_expo.ui += (23-24);//-1;
		// 	c_frac.ui >>= (23-23);//0;
		// } else
		// if (c_frac.ui>>22)
		// {
		// 	c_expo.ui += (22-24);//-2;
		// 	c_frac.ui <<= 1;
		// } else
		// if (c_frac.ui>>21)
		// {
		// 	c_expo.ui += (21-24);//-3;
		// 	c_frac.ui <<= 2;
		// } else
		// if (c_frac.ui>>20)
		// {
		// 	c_expo.ui += (20-24);//-4;
		// 	c_frac.ui <<= 3;
		// } else
		// if (c_frac.ui>>19)
		// {
		// 	c_expo.ui += (19-24);//-5;
		// 	c_frac.ui <<= 4;
		// }
	} else
	{
		if (c_frac.q26)
		{
			c_expo.ui += 1;
			c_frac.ui += c_frac.q02<<2;
			c_frac.ui >>= 3;
		} else
		{
			c_expo.ui += 0;
			c_frac.ui += c_frac.q01<<1;
			c_frac.ui >>= 2;
		}
	}

	// Expected:
	// tmp = ((uint64_t)hh.ui<<11) + ((uint64_t)hl.ui) + ((uint64_t)lh.ui) + ((uint64_t)ll.ui>>11); 
	// tmp = (tmp>>11);
	// c_frac.ui = tmp;

	// Expected:
	// c_frac.ui = hh.ui + (hl.ui>>11) + (lh.ui>>11);
	// c_frac.ui += (hl.mlo + lh.mlo + (ll.ui>>11)) >> 11;
	// c_frac.ui += (slice(hl.mlo, 10, 0) + slice(lh.mlo, 10, 0) + slice(ll.ui>>11, 10, 0)) >> 11;

	if (b_nan)
	{
		c.sign = b.sign;
		c.expo = (1<<8)-1;
		c.frac = 0;//(1<<22) | a.frac;
	} else
	if (a_nan)
	{
		c.sign = a.sign;
		c.expo = (1<<8)-1;
		c.frac = 0;//(1<<22) | a.frac;
	} else
	if ((a_inf || b_inf) && (a_zero || b_zero))
	{
		c.sign = 1;
		c.expo = (1<<8)-1;
		c.frac = 0;
	} else
	if (a_inf || b_inf)
	{
		c.sign = c.sign;
		c.expo = (1<<8)-1;
		c.frac = 0;
	} else
	if (a_zero || b_zero)
	{
		c.sign = c.sign;
		c.expo = 0;
		c.frac = 0;
	} else
	if (c_expo.of || (c_expo.uf &(c_expo.base==(1<<8)-1))) //overflow := 1x,xxxx,xxxx
	{
		c.sign = c.sign;
		c.expo = (1<<8)-1;
		c.frac = 0;
	} else
	if (!c_expo.uf || !c_expo.base) //underflow := 00,xxxx,xxxx or 01,0000,0000
	{
		c.sign = c.sign;
		c.expo = 0;
		c.frac = 0;
	} else
	{
		c.sign = c.sign;
		c.expo = c_expo.base;
		c.frac = c_frac.frac;
	}

	return c.ui;
}