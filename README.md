# Matrix Multiply by CUDA

-	How to compile and run the program.
Run Developer Command Prompt for Visual Studio
nvcc MatrixMultiply-Pinned.cu -o MatrixMultiply-Pinned
MatrixMultiply-Pinned.exe 1024 1024 1024
(first is for nRows of A, second is for nColumns of A or nRows of B, third is for nColumns of B)

1.	What are the differences between pageable memory and pinned memory, what are the tradeoffs?
- Difference between Pageable memory and pinned memory
Pageable memory is the specific memory which is allowed to be paged in or paged out.
Pinned memory is the specific memory which is not allowed to be paged in or paged out. This is also called page-locked memory.
- Pageable memory vs Pinned memory
Compared to pageable memory, pinned memory has only 1 memory transfer. Hence memory transfer time is less for pinned memory than pageable memory.

2.	Compare the profiling results between your original code and the new version using pinned memory. What is the difference in execution time after changing to pinned memory?
I’ve evaluated for the calculation: A (1024 x 1024) x B (1024 x 1024) = C (1024 x 1024).
- Pageable memory
	Host to Device: 8ms
	Kernel: 147ms
	Device to Host: 6ms
- Pinned memory
	Host to Device: 6 ms
	Kernel: 147ms
	Device to Host: 3ms
As you can see, using pinned memory, time spent on Host to Device and Device to Host is decreased.

3.	What is a managed memory? What are the implications of using managed memory?
Managed memory is the specific memory which is accessible to both the CPU and GPU using a single pointer.
Using managed memory, we can share memory between the CPU and GPU.

4.	Compare the profiling results between your original code and the new version using managed memory. What do you observe in the profiling results?
nvprof MatrixMultiply-Unified.exe 1024 1024 1024
When we use managed memory, we can see the prints below.

==20236== Unified Memory profiling result:
Device "NVIDIA GeForce MX110 (0)"
   Count  Avg Size  Min Size  Max Size  Total Size  Total Time  Name
     128  128.00KB  128.00KB  128.00KB  16.00000MB  8.734900ms  Host To Device
     572  87.273KB  4.0000KB  1.0000MB  48.75000MB  328.0849ms  Device To Host

# Vector Addision by CUDA

-	How to compile and run the program.
Run Developer Command Prompt for Visual Studio
nvcc VectorAddition.cu -o VectorAddition
VectorAddition.exe 1024 16 (1024 is N, 16 is S_seg)

1.	Compared to the non-streamed vector addition, what performance gain do you get?
Input following command to see chart like below:
python VectorAddition-Performance.py
 
![image](https://user-images.githubusercontent.com/121934188/211287616-4d704b82-6ce8-4e1a-938a-bd98361d67f0.png)

As you can see, using streams, we can optimize total execution time.

2.	Use nvprof to collect traces and the NVIDIA Visual Profiler (nvvp) to visualize the overlap of communication and computation.
nvprof -o prof.nvvp VectorAddition.exe 67108864 16777216
Open prof.nvvp in Explorer. Then NVIDIA Visual Profiler will open and you can see like below.

 

3.	What is the impact of segment size on performance? Show in a bar plot.
We evaluated for different segment sizes (25, 250, 2500, 25000, 250000) with input length: 1000000.
As you can see in the bar chart, short segment is not good for performance.
The Best Segment Size = Input Length / Stream Count

 
