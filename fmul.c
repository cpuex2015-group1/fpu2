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
	f32_uint a, b, c, hh, hl, lh, ll, c_frac, hoge;
	exponential c_expo;
	
	a.ui = _a;
	b.ui = _b;

	c.sign = a.sign ^ b.sign;
	c_expo.ui = a.expo + b.expo + ((1<<7) + 1);

	hh.ui = (a.mhi|IMPL1) * (b.mhi|IMPL1);
	hl.ui = (a.mhi|IMPL1) *  b.mlo;
	lh.ui =  a.mlo * (b.mhi|IMPL1);
	// ll.ui =  a.mlo * b.mlo;


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
	c_frac.ui = ((hh.ui<<1) + 1 + (hl.ui>>10) + (lh.ui>>10));

	if (c_frac.q26)
	{
		c_expo.ui += 1;
		c_frac.ui += c_frac.q02<<2;
		c_frac.ui >>= 3;
	}
	else
	{
		c_expo.ui += 0;
		c_frac.ui += c_frac.q01<<1;
		c_frac.ui >>= 2;
	}


	// Expected:
	// tmp = ((uint64_t)hh.ui<<11) + ((uint64_t)hl.ui) + ((uint64_t)lh.ui) + ((uint64_t)ll.ui>>11); 
	// tmp = (tmp>>11);
	// c_frac.ui = tmp;

	// Expected:
	// c_frac.ui = hh.ui + (hl.ui>>11) + (lh.ui>>11);
	// c_frac.ui += (hl.mlo + lh.mlo + (ll.ui>>11)) >> 11;
	// c_frac.ui += (slice(hl.mlo, 10, 0) + slice(lh.mlo, 10, 0) + slice(ll.ui>>11, 10, 0)) >> 11;


	// if (a.expo == (1<<8)-1 || b.expo == (1<<8)-1)
	// {
	// 	c_expo.ui = (1<<8)-1;
	// 	c_frac.ui = 0;
	// } else
	if (c_expo.of || (c_expo.uf && (c_expo.base==(1<<8)-1))) //overflow := 1x,xxxx,xxxx
	{
		c.expo = (1<<8)-1;
		c.frac = 0;
	} else
	if (!c_expo.uf || !c_expo.base) //underflow := 00,xxxx,xxxx or 01,0000,0000
	{
		c.expo = 0;
		c.frac = 0;
		// TODO: denormalized number
	} else
	{
		c.expo = c_expo.base;
		c.frac = c_frac.frac;
	}

	return c.ui;
}