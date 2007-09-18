#include "../../../Math/O3Matrix.h"
#include "../../../Math/O3Vector.h"
#include <iostream>

int main(int argc, char** argv) {
	Vector<float, 3> omg(1.,2.,3.);
	long long i;
	long long j = 1000000000;
	float mat[] = { 1. , 2. , 3. , 4. ,
			5. , 6. , 7. , 8. , 
			9. , 10., 11., 12.,
			13., 14., 15., 16.};
	for (i=0;i<j;i++) {
		Matrix<float, 4, 4> matr(mat);
		matr[1][1] = matr[0][3];
	}
	return 0;
}
