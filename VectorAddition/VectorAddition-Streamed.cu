/*
* CUDA Problem (Vector Addition)
* 
*/

// Include Header Files

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <algorithm>
#include <cuda_runtime.h>

using std::generate;

typedef double DataType;

__global__ void vecAdd(DataType *in1, DataType *in2, DataType *out, int len) {
//@@ Insert code to implement vector addition here
  int idx = (blockDim.x * blockIdx.x) + threadIdx.x;

  // Boundary check
  if (idx < len)
    out[idx] = in1[idx] + in2[idx];
}

//@@ Insert code to implement timer start
clock_t st, en;
void timerStart() {
  st = clock();
}

//@@ Insert code to implement timer stop
void timerStop(char stepName[]) {
  en = clock();
  clock_t elapsed = en - st;
  printf("%s: %u ms elapsed.\n", stepName, elapsed);
}

int main(int argc, char **argv) {
  int inputLength;
  int S_seg;
  DataType *hostInput1;
  DataType *hostInput2;
  DataType *hostOutput;
  DataType *resultRef;
  DataType *deviceInput1;
  DataType *deviceInput2;
  DataType *deviceOutput;

  // Create CUDA Streams
  cudaStream_t stream[4];
  for (int i = 0; i < 4; ++i)
    cudaStreamCreate(stream + i);

  //@@ Insert code below to read in inputLength from args
  inputLength = atoi(argv[1]);
  S_seg = atoi(argv[2]);

  printf("The input length is %d, and the segment size is %d\n", inputLength, S_seg);
  
  //@@ Insert code below to allocate Host memory for input and output
  size_t bytes = inputLength * sizeof(DataType);
  cudaMallocHost(&hostInput1, bytes);
  cudaMallocHost(&hostInput2, bytes);
  cudaMallocHost(&hostOutput, bytes);

  //@@ Insert code below to initialize hostInput1 and hostInput2 to random numbers, and create reference result in CPU
  generate(hostInput1, hostInput1 + inputLength, []() { return (DataType)rand() / RAND_MAX; });
  generate(hostInput2, hostInput2 + inputLength, []() { return (DataType)rand() / RAND_MAX; });

  //@@ Insert code below to allocate GPU memory here
  cudaMalloc(&deviceInput1, bytes);
  cudaMalloc(&deviceInput2, bytes);
  cudaMalloc(&deviceOutput, bytes);

  //@@ Insert code to below to Copy memory to the GPU here
  timerStart();
  for (int p_start = 0, k = 0; p_start < inputLength; p_start += S_seg, (++k) %= 4) {
    int p_end = p_start + S_seg;
    if (p_end > inputLength)
      p_end = inputLength;
    
    cudaMemcpyAsync(deviceInput1 + p_start, hostInput1 + p_start, (p_end - p_start) * sizeof(DataType), cudaMemcpyHostToDevice, stream[k]);
  }
  for (int p_start = 0, k = 0; p_start < inputLength; p_start += S_seg, (++k) %= 4) {
    int p_end = p_start + S_seg;
    if (p_end > inputLength)
      p_end = inputLength;
    
    cudaMemcpyAsync(deviceInput2 + p_start, hostInput2 + p_start, (p_end - p_start) * sizeof(DataType), cudaMemcpyHostToDevice, stream[k]);
  }
  timerStop("Host to Device");

  //@@ Launch the GPU Kernel here
  timerStart();
  for (int p_start = 0, k = 0; p_start < inputLength; p_start += S_seg, (++k) %= 4) {
    int p_end = p_start + S_seg;
    if (p_end > inputLength)
      p_end = inputLength;
    
    //@@ Initialize the 1D grid and block dimensions here
    int BLOCK_SIZE = 256;
    int GRID_SIZE = (p_end - p_start + BLOCK_SIZE - 1) / BLOCK_SIZE;
    
    vecAdd<<<GRID_SIZE, BLOCK_SIZE, 0, stream[k]>>>(deviceInput1 + p_start, deviceInput2 + p_start, deviceOutput + p_start, p_end - p_start);
  }
  timerStop("Kernel");

  //@@ Copy the GPU memory back to the CPU here
  timerStart();
  for (int p_start = 0, k = 0; p_start < inputLength; p_start += S_seg, (++k) %= 4) {
    int p_end = p_start + S_seg;
    if (p_end > inputLength)
      p_end = inputLength;
    
    cudaMemcpyAsync(hostOutput + p_start, deviceOutput + p_start, (p_end - p_start) * sizeof(DataType), cudaMemcpyDeviceToHost, stream[k]);
  }
  cudaThreadSynchronize();
  timerStop("Device To Host");

  //@@ Insert code below to compare the output with the reference
  cudaMallocHost(&resultRef, bytes);
  for (int i = 0; i < inputLength; ++i)
    resultRef[i] = hostInput1[i] + hostInput2[i];

  for (int i = 0; i < inputLength; ++i)
    if (fabs(hostOutput[i] - resultRef[i]) > 1e-6) {
      printf("Wrong\n");
      break;
    }

  //@@ Free the GPU memory here
  cudaFree(deviceInput1);
  cudaFree(deviceInput2);
  cudaFree(deviceOutput);

  //@@ Free the CPU memory here
  cudaFree(hostInput1);
  cudaFree(hostInput2);
  cudaFree(hostOutput);
  cudaFree(resultRef);

  return 0;
}
