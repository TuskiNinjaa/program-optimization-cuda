# program-optimization-cuda
The objective of this work is to use the CUDA library to parallelize a sequential algorithm and verify the speedup obtained when executing both codes on the same machine.

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
