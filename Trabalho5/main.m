clear;
clc;
close all;

% ================================================
% === Definicao de parametros pelo usuario
% ================================================

% Lendo as coordenadas dos pontos
P = dlmread('malha/mesh400.xy');

% Lendo os triangulos da malha
T = dlmread('malha/mesh400.tri');

% Os dois pontos que serao inseridos
p1 = [0, 0];
p2 = [-0.3, 0.25];

% Flag para imprimir imagens passo-a-passo ou nao
% As imagens sao salvas na pasta "/imagens"
passo_a_passo = false;

% ==================================================
% === Fim da definicao de parametros pelo usuario
% ==================================================






global indice_imagem lista_arestas ampliar_imagem escrever_arquivos mostrar_imagem;
indice_imagem = 0;
lista_arestas = [];
ampliar_imagem = [];
escrever_arquivos = passo_a_passo;
mostrar_imagem = false;

% Arrumando os indices pra comecar de 1
T = T + 1;

% Exibindo uma figura com a malha inicial na tela
mostrar_imagem = true;
plota_figura(P, T, [], [], false, 'Malha Inicial');
mostrar_imagem = false;

% Definindo o ponto que sera inserido e plotando coisas
p = p1;
plota_figura(P, T, p, [], false, 'Malha Inicial e novo ponto (0, 0)');
ampliar_imagem = [-0.15, 0.07; -0.17, 0.06];
plota_figura(P, T, p, [], false, 'Malha Inicial (vis\~ao ampliada)');

% Inserindo o ponto na triangulacao
[P, T] = insere_ponto(p, P, T);

% Definindo o segundo ponto que sera inserido e plotando coisas
p = p2;
ampliar_imagem = [];
plota_figura(P, T, p, [], false, 'Malha atual e novo ponto (-0.3, 0.25)');
ampliar_imagem = [-0.4, -0.2; 0.15, 0.35];
plota_figura(P, T, p, [], false, 'Malha atual (vis\~ao ampliada)');

% Inserindo o segundo ponto
[P, T] = insere_ponto(p, P, T);

% Plotando mais coisas
ampliar_imagem = [];
plota_figura(P, T, [p1; p2], [], false, 'Malha Final');

% Plotando mais coisas de novo
mostrar_imagem = true;
plota_figura(P, T, [p1; p2], [], false, 'Malha Final');
mostrar_imagem = false;
