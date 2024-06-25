#include<iostream>
#include<ctime>
using namespace std;

#define N 1024
#define B 256

double Rand() {
    return (2*double(rand())/RAND_MAX - 1)*0.1;
}

void convolution(double *x, double *h, double *z) {
    int j;
    double V;
    for(int i = 0; i < N; i++) {
        V = 0;
        for(j = 0; j < N; j++) V += x[j]*h[i - j + (i >= j ? 0 : N)];
        z[i] = V;
    }
}

int main() {

    srand(10);
    cout << "Start...\n";

    int i, j, k;
    double *X, *H, *Z, V;
    double **x = new double*[B];
    double **h = new double*[B];
    double **z = new double*[B];
    for(i = 0; i < B; i++) {
        X = new double[N];
        H = new double[N];
        for(j = 0; j < N; j++) {
            X[j] = Rand();
            H[j] = Rand();
        }
        x[i] = X;
        h[i] = H;
        z[i] = new double[N];
    }
    cout << "RUN!!!\n\n";

    clock_t s, e;
    s = clock();
    for(i = 0; i < B; i++) convolution(x[i], h[i], z[i]);
    e = clock();
    cout << "Time: " << double(e - s)/CLOCKS_PER_SEC << " sec\n\n";

    for(i = 0; i < B; i++) {
        V = 0;
        Z = z[i];
        for(j = 0; j < N; j++) V += Z[j];
        cout << i << ": " << V/N;
        if(i % 15 == 14) getchar();
        else cout << endl;
    }
    return 0;
}
