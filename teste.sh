#!/bin/bash

gcc caminhos_seq.c -o caminhos_seq
nvcc caminhos.cu -o caminhos

declare -a n_vertices=( 4 8 32 256 512 )

for i in "${!n_vertices[@]}"
do
    ./caminhos_seq ${n_vertices[$i]} ./Entradas_Saidas/e$(($i + 1)).txt ./Entradas_Saidas/saida$(($i + 1)).txt
    ./caminhos ${n_vertices[$i]} ./Entradas_Saidas/e$(($i + 1)).txt ./Entradas_Saidas/saida_par$(($i + 1)).txt
    cmp --silent ./Entradas_Saidas/saida$(($i + 1)).txt ./Entradas_Saidas/saida_par$(($i + 1)).txt && echo "Test case $(($i + 1)): Files are EQUAL" || echo "Test case $(($i + 1)): Files are DIFFERENT"
done