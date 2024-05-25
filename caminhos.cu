// ----------------------------------------------------------------------------
// Dado um grafo direcionado com pesos nas arestas, encontrar distância do caminho mais curto entre cada par de vértices.
// Supor:
//		Arestas possuem pesos > 0
//		Grafo não possui loops (aresta de um vértice para ele mesmo)
//		Número de vértices do grafo é potência de 2
//
// Para compilar: gcc caminhos_seq.c -o caminhos_seq
// Para executar: ./caminhos_seq nVértices arquivoEntrada arquivoSaída

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <sys/time.h>

// ----------------------------------------------------------------------------
void leArqIn(char *nomeArqIn, int nElem, unsigned int *mat)
{
	unsigned int p;

	FILE *arqIn = fopen(nomeArqIn, "rt");	// Arquivo texto de entrada

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
				mat[i*nElem + j] = INT_MAX; // mat[i][j] = infinito
			else
				mat[i*nElem + j] = p; // mat[i][j] = adj[i][j] = peso da aresta (i,j)
		}

	fclose(arqIn);
}

// ----------------------------------------------------------------------------
void calculaDist(int nElem, unsigned int *matIn, unsigned int *matOut)
{
	unsigned int dij, dikj;

	// Para cada par de vértices i e j
	for (int i = 0; i < nElem; i++)
		for (int j = 0; j < nElem; j++)
		{
			// Calcula distância mínima de i para j, testando,
			// para cada vértice k, distância de i para k + distância de k para j
			dij = INT_MAX;
			for (int k = 0; k < nElem; k++)
			{
				dikj = matIn[i*nElem + k] + matIn[k*nElem + j]; // matIn[i][k] + matIn[k][j]
				if (dikj < dij)
					dij = dikj;
			}
			matOut[i*nElem + j] = dij; // matOut[i][j]
		}
}

// ----------------------------------------------------------------------------
void escreveArqOut(char* nomeArqOut, int nElem, unsigned int *mat)
{
	FILE *arqOut;	// Arquivo texto de saída

	arqOut = fopen(nomeArqOut, "wt");

	// Escreve matriz nElem x nElem de distâncias no arquivo de saída
	for (int i = 0; i < nElem; i++)
	{
		for (int j = 0; j < nElem; j++)
			if (mat[i*nElem + j] != INT_MAX)	// mat[i][j]
				fprintf(arqOut, "%d ", mat[i*nElem + j]); // Distância mínima de i para j
			else
				fprintf(arqOut, "-1 ");	// Não há caminho de i para j
		fprintf(arqOut, "\n");
	}

	fclose(arqOut);
}

// ----------------------------------------------------------------------------
// Programa principal
int main(int argc, char** argv)
{
	if(argc != 4)
	{
		printf("O programa foi executado com argumentos incorretos.\n");
		printf("Uso: ./caminhos_seq nVértices arquivoEntrada arquivoSaída\n");
		exit(1);
	}

	int nVert = atoi(argv[1]);	// Obtém número de vértices do grafo

	// Obtém nome dos arquivos de entrada e saída
	char nomeArqIn[100],
		  nomeArqOut[100] ;

	strcpy(nomeArqIn, argv[2]) ;
	strcpy(nomeArqOut, argv[3]) ;

	// Aloca matrizes nVert x nVert de distâncias mais curtas
	int nBytes = nVert * nVert * sizeof(int);
	unsigned int *distIn = (unsigned int *) malloc(nBytes);
	unsigned int *distOut = (unsigned int *) malloc(nBytes);
	unsigned int *auxTroca;
	if (distIn == NULL || distOut == NULL)
	{
		printf("\nErro na alocação das estruturas de dados\n");
		exit(1);
	}

	// Lê matriz de adjacências do arquivo de entrada e inicializa matriz de distâncias
	leArqIn(nomeArqIn, nVert, distIn);

	// Inicia medição do tempo de execução
	struct timeval h_ini, h_fim;
	gettimeofday(&h_ini, 0);

	// Repete log_2(nVert) passos
	for (int alcance = 2; alcance <= nVert; alcance<<=1)
	{
		// Usando distâncias mínimas de caminhos com até (alcance) arestas,
		// calcula distâncias mínimas de caminhos com até (2*alcance) arestas
		calculaDist(nVert, distIn, distOut);

		// Troca ponteiros de matrizes de distâncias distIn e distOut
		auxTroca = distIn;
		distIn   = distOut;
		distOut  = auxTroca;
	}
	
	// Finaliza medição do tempo de execução
	gettimeofday(&h_fim, 0);
	long segundos = h_fim.tv_sec - h_ini.tv_sec;
	long microsegundos = h_fim.tv_usec - h_ini.tv_usec;
	double h_tempo = (segundos * 1e3) + (microsegundos * 1e-3); // Tempo de execução na CPU em ms

	// Escreve matriz de distâncias no arquivo de saída
	escreveArqOut(nomeArqOut, nVert, distIn);

	printf("Tempo CPU = %.2fms\n", h_tempo);

	// Libera matrizes
	free(distIn);
	free(distOut);

	return 0;
}
