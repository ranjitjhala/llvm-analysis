/*
  Note, this test is important because p picks up two edges from q at
  the same step of the algorithm.  This gives us a chance to catch a
  potential regression in graph construction (due to context
  clobbering in FGL)
 */
int a;
int b;
int c;
int d;

int * p;
int * q;
int * r;
int ** pq;
int ** pp;

void callee(int * ptr)
{
  *ptr = *q;
}

void caller()
{
  callee(p);
}

void setup()
{
  q = &a;
}
