# program-paralelization-cuda
The objective of this work is to use the CUDA library to parallelize a sequential algorithm (_All Pairs Shortest Paths_) and verify the speedup obtained when executing both codes on the same machine.

# Enviroment
- GCC - Version 11.4.0
- UnZip - Version 6.00
- cuda-toolkit - Version 11.8

# Setup conda enviroment
```console
conda create -n pp_cuda -y
conda activate pp_cuda
conda install nvidia/label/cuda-11.8.0::cuda-cudart -y
conda install nvidia/label/cuda-11.8.0::cuda-toolkit -y
```

# Unzip inputs and outputs files
```console
unzip Entradas_Saidas.zip
```

# Test script
```console
chmod +x teste.sh
```

```console
./teste.sh
```

## Example of output after running the test script
- Google Colab - Tesla T4

```console
Tempo CPU = 0.00ms
Tempo GPU = 0.28ms
Test case 1: Files are EQUAL
Tempo CPU = 0.01ms
Tempo GPU = 0.24ms
Test case 2: Files are EQUAL
Tempo CPU = 0.67ms
Tempo GPU = 0.41ms
Test case 3: Files are EQUAL
Tempo CPU = 527.18ms
Tempo GPU = 1.52ms
Test case 4: Files are EQUAL
Tempo CPU = 8135.93ms
Tempo GPU = 8.82ms
Test case 5: Files are EQUAL
```

- CPU - i5-13450HX
- GPU - RTX 3050 mobile 6Gb

```console
Tempo CPU = 0.00ms
Tempo GPU = 0.12ms
Test case 1: Files are EQUAL
Tempo CPU = 0.00ms
Tempo GPU = 0.13ms
Test case 2: Files are EQUAL
Tempo CPU = 0.31ms
Tempo GPU = 0.14ms
Test case 3: Files are EQUAL
Tempo CPU = 202.83ms
Tempo GPU = 0.84ms
Test case 4: Files are EQUAL
Tempo CPU = 2280.42ms
Tempo GPU = 5.17ms
Test case 5: Files are EQUAL
```
