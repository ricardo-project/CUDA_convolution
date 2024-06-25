#include<iostream>
#include"cuda_runtime.h"
#include"device_launch_parameters.h"
#include<cstdio>
#include<cmath>
using namespace std;

#define N 1024
#define B 256
#define O 256

float Rand() {
	return (2*float(rand())/RAND_MAX - 1)*0.1;
}

__device__ void convolucao(float* x, float* h, float* z) {
	float V;
	int j;
	for (int i = 0; i < N; i++) {
		V = 0;
		for (j = 0; j < N; j++) V += x[j]*h[i - j + (i >= j ? 0 : N)];
		z[i] = V;
	}
}

__global__ void convCompleta(float *x, float *y, float *z) {

    int L = (blockIdx.x*blockDim.x + threadIdx.x)*N*O;
	int i, j, k;
	x += L;
	y += L;
	z += L;

    for(int k = 0; k < O; k++) {
        convolucao(x, y, z);
        x += N;
        y += N;
        z += N;
    }
}

int main(void) {

	srand(10);
	setlocale(LC_ALL, "Portuguese");

	// Variáveis genéricas
	int i, j, k;
	float *V, *S, L;

	int BN = B*N;
	float *X = new float[BN];
	float *Y = new float[BN];
	float *Z = new float[BN];
	for(i = 0; i < BN; i++) {
        X[i] = Rand();
        Y[i] = Rand();
	}

	float *x, *y, *z;
	int d = sizeof(float);
	cudaMalloc((void**)&x, d*BN);
	cudaMalloc((void**)&y, d*BN);
	cudaMalloc((void**)&z, d*BN);

	cudaMemcpy(x, X, d*BN, cudaMemcpyHostToDevice);
	cudaMemcpy(y, Y, d*BN, cudaMemcpyHostToDevice);

	cout << "RUN!!\n";
	float time;
	cudaEvent_t start, stop;

	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);

	convCompleta<<<1, B/O>>>(x, y, z);

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time, start, stop);

	cudaMemcpy(Z, z, d*BN, cudaMemcpyDeviceToHost);
	cout << "Time: " << time/1000 << " sec\n";


	getchar();
	for(i = 0; i < B; i++) {
		L = 0;
		V = Z + i*N;
		for (j = 0; j < N; j++) L += V[j];
		cout << i << ": " << L/N;

		if(i % 15 == 14) getchar();
        else cout << endl;
	}

	cudaFree(x);
	cudaFree(y);
	cudaFree(z);

	return 0;
}
