#!/bin/bash

gcc caminhos_seq.c -o caminhos_seq -Wall
# gcc esparso_par.c -fopenmp -o esparso_par.o -Wall

declare -a n_vertices=( 4 8 32 256 512 )

for i in "${!n_vertices[@]}"
do
    ./caminhos_seq ${n_vertices[$i]} ./Entradas_Saidas/e$(($i + 1)).txt ./Entradas_Saidas/saida_teste$(($i + 1)).txt
    # ./esparso_par.o ./Entradas/e$i.txt ./Saidas/par_s$i.txt
done

for i in {1..5}
do
    cmp --silent ./Entradas_Saidas/saida$i.txt ./Entradas_Saidas/saida_teste$i.txt && echo "Test case $i: Files are EQUAL" || echo "Test case $i: Files are DIFFERENT"
done