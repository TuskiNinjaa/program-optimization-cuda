// ----------------------------------------------------------------------------
// Nome dos alunos do grupo:
// Vitor Yuske Watanabe - 2020.1905.058-4
// Raissa Rinaldi Yoshioka - 2020.1905.049-5
// ----------------------------------------------------------------------------
// Dado um grafo direcionado com pesos nas arestas, encontrar distância do caminho mais curto entre cada par de vértices.
// Supor:
//		Arestas possuem pesos > 0
//		Grafo não possui loops (aresta de um vértice para ele mesmo)
//		Número de vértices do grafo é potência de 2
//
// Para compilar: nvcc caminhos.cu -o caminhos
// Para executar: ./caminhos nVértices arquivoEntrada arquivoSaída

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

// ----------------------------------------------------------------------------
// Macro para checagem de erro das chamadas às funções do CUDA
#define checa_cuda(result)                          \
    if (result != cudaSuccess)                      \
    {                                               \
        printf("%s\n", cudaGetErrorString(result)); \
        exit(1);                                    \
    }

// ----------------------------------------------------------------------------
void leArqIn(char *nomeArqIn, int nElem, unsigned int *mat)
{
    unsigned int p;

    FILE *arqIn = fopen(nomeArqIn, "rt"); // Arquivo texto de entrada

    if (arqIn == NULL)
    {
        printf("\nArquivo texto de entrada não encontrado\n");
        exit(1);
    }

    // Lê matriz nElem x nElem de adjacências do arquivo de entrada
    // Inicializa matriz nElem x nElem de distâncias com distâncias mínimas de caminhos com até 1 aresta
    for (int i = 0; i < nElem; i++)
        for (int j = 0; j < nElem; j++)
        {
            fscanf(arqIn, "%u", &p); // peso da aresta (i,j)
            // Peso 0 indica ausência de aresta de i para j
            if (p == 0 && i != j)
                mat[i * nElem + j] = INT_MAX; // mat[i][j] = infinito
            else
                mat[i * nElem + j] = p; // mat[i][j] = adj[i][j] = peso da aresta (i,j)
        }

    fclose(arqIn);
}

// ----------------------------------------------------------------------------
__global__ void calculaDist(int nElem, unsigned int *matIn, unsigned int *matOut)
{
	// linha i = coordenada y do id GLOBAL da thread
	int i = blockIdx.y * blockDim.y + threadIdx.y;
	// coluna j = coordenada x do id GLOBAL da thread
	int j = blockIdx.x * blockDim.x + threadIdx.x;

	// Se thread corresponde a uma célula da matriz C
	if ((i < nElem) && (j < nElem))
	{
        unsigned int dij = INT_MAX, dikj;
        for (int k = 0; k < nElem; k++)
        {
            dikj = matIn[i * nElem + k] + matIn[k * nElem + j]; // matIn[i][k] + matIn[k][j]
            if (dikj < dij)
                dij = dikj;
        }
        matOut[i * nElem + j] = dij; // matOut[i][j]
	}
}

// ----------------------------------------------------------------------------
void escreveArqOut(char *nomeArqOut, int nElem, unsigned int *mat)
{
    FILE *arqOut; // Arquivo texto de saída

    arqOut = fopen(nomeArqOut, "wt");

    // Escreve matriz nElem x nElem de distâncias no arquivo de saída
    for (int i = 0; i < nElem; i++)
    {
        for (int j = 0; j < nElem; j++)
            if (mat[i * nElem + j] != INT_MAX)              // mat[i][j]
                fprintf(arqOut, "%d ", mat[i * nElem + j]); // Distância mínima de i para j
            else
                fprintf(arqOut, "-1 "); // Não há caminho de i para j
        fprintf(arqOut, "\n");
    }

    fclose(arqOut);
}

// ----------------------------------------------------------------------------
// Programa principal
int main(int argc, char **argv)
{
    if (argc != 4)
    {
        printf("O programa foi executado com argumentos incorretos.\n");
        printf("Uso: ./caminhos_seq nVértices arquivoEntrada arquivoSaída\n");
        exit(1);
    }

    int nVert = atoi(argv[1]); // Obtém número de vértices do grafo

    // Obtém nome dos arquivos de entrada e saída
    char nomeArqIn[100],
        nomeArqOut[100];

    strcpy(nomeArqIn, argv[2]);
    strcpy(nomeArqOut, argv[3]);

    // Cria variáveis
    unsigned int nBytes = nVert * nVert * sizeof(int), // Tamanho dos vetores em bytes
        *distInHost, *distInDevice, *distOutDevice;

    // Aloca o vetor no host
    distInHost = (unsigned int *)malloc(nBytes);
    if (distInHost == NULL)
    {
        printf("\nErro na alocação das estruturas de dados\n");
        exit(1);
    }

    // Lê matriz de adjacências do arquivo de entrada e inicializa matriz de distâncias
    leArqIn(nomeArqIn, nVert, distInHost);

    // Aloca vetores na memória global da GPU
    checa_cuda(cudaMalloc((void **)&distInDevice, nBytes));
    checa_cuda(cudaMalloc((void **)&distOutDevice, nBytes));

	// Determina nBlocos e nThreadsBloco
	// nBlocos.x = teto(m / nThreadsBloco.x)
	// nBlocos.y = teto(n / nThreadsBloco.y)
	dim3 nThreadsBloco(32,32);
	dim3 nBlocos((nVert + (nThreadsBloco.x - 1)) / nThreadsBloco.x, (nVert + (nThreadsBloco.y - 1)) / nThreadsBloco.y);

    // Inicia medição de tempo de execução na GPU
    cudaEvent_t d_ini, d_fim;
    cudaEventCreate(&d_ini);
    cudaEventCreate(&d_fim);
    cudaEventRecord(d_ini, 0);

    // Copia dados de entrada do host para memória global da GPU
    checa_cuda(cudaMemcpy(distInDevice, distInHost, nBytes, cudaMemcpyHostToDevice));

    // Repete log_2(nVert) passos
    for (int alcance = 2; alcance <= nVert; alcance <<= 1)
    {
        // Usando distâncias mínimas de caminhos com até (alcance) arestas,
        // calcula distâncias mínimas de caminhos com até (2*alcance) arestas
        calculaDist<<<nBlocos, nThreadsBloco>>>(nVert, distInDevice, distOutDevice);

        // Host aguarda a execução da GPU
        cudaDeviceSynchronize();

        // Atribui os valores de distOutDevice em distInDevice
        checa_cuda(cudaMemcpy(distInDevice, distOutDevice, nBytes, cudaMemcpyDeviceToDevice));
    }

    // Copia dados de entrada da GPU para o host
    checa_cuda(cudaMemcpy(distInHost, distInDevice, nBytes, cudaMemcpyDeviceToHost));

    // Finaliza medição do tempo de execução
    cudaEventRecord(d_fim, 0);
    cudaEventSynchronize(d_fim);
    float d_tempo; // Tempo de execução na GPU em milissegundos
    cudaEventElapsedTime(&d_tempo, d_ini, d_fim);
    cudaEventDestroy(d_ini);
    cudaEventDestroy(d_fim);
    printf("Tempo GPU = %.2fms\n", d_tempo);

    // Escreve matriz de distâncias no arquivo de saída
    escreveArqOut(nomeArqOut, nVert, distInHost);

    // Libera vetores na memória global da GPU
    checa_cuda(cudaFree(distInDevice));
    checa_cuda(cudaFree(distOutDevice));

    // Libera vetor no host
    free(distInHost);

    return 0;
}
