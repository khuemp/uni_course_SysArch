#include <stdio.h>
#include <time.h>

int main()
{
    FILE *p;
    p = fopen("test.out", "w");
    int steps = 64*1024*1024;
	
    for (long arraysize = 4*1024; arraysize < (long)1024*1024*1024; arraysize *= 2) {
        char *arr = new char[arraysize];

        for (long i = 0; i < arraysize; i++)
            arr[i] = 0;

        long lengthmod = arraysize - 1;
        clock_t start = clock();
        
        long x = 0;
        for (long i = steps; i > 0; i--) {
			x = arr[((i*4096) & lengthmod)+x];         
		}
    
        clock_t end = clock();
        fprintf(p, "%ld %lu\n", arraysize, end-start);
    }
    fclose(p);
}
