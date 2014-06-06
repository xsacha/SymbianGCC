/* { dg-do compile } */
/* { dg-options "-O2 -fshrink-wrap -fdump-rtl-pro_and_epilogue" } */

#include <string.h>

int c;
int x[2000];
__attribute__((regparm(1))) int foo (int a, int b)
 {
   int t[200];
   if (a == 0)
     return 1;
   if (c == 0)
     return 2;
   memcpy (t, x + b, sizeof t);
   return t[a];
 }

/* { dg-final { scan-rtl-dump "Prologue moved down" "pro_and_epilogue" } } */
/* { dg-final { cleanup-rtl-dump "pro_and_epilogue" } } */
