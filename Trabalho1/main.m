clear;
clear textprogressbar;
clc;
tic

% Escolher um dos exemplos abaixo. Todos estao definidos no arquivo exemplos.m
% nome_exemplo = 'esfera';
% nome_exemplo = 'torus';
% nome_exemplo = 'genus-2';
% nome_exemplo = 'triple-torus';
% nome_exemplo = 'calice-vinho';
% nome_exemplo = 'falling-drop';
nome_exemplo = 'interlocked-torus';

% Quantidade de intervalos para discretizar cada eixo
N = 50;

% Flag para plotar as normais junto com as superficies ou nao
flag_plotar_normais = false;




% Pegando as informacoes do exemplo escolhido (ver arquivo exemplos.m)
[f, intervalo_x, intervalo_y, intervalo_z] = exemplos(nome_exemplo, 0.0);

% Criando um grid retangular e avaliando a funcao nos pontos
disp('Criando um grid retangular e avaliando a funcao nos pontos')
t_x = linspace(intervalo_x(1), intervalo_x(2), N);
t_y = linspace(intervalo_y(1), intervalo_y(2), N);
t_z = linspace(intervalo_z(1), intervalo_z(2), N);
[x y z] = meshgrid(t_x, t_y, t_z);
f_grid = f(x, y, z);


% Criando a superfície triangulada pelo marching tetrahedra
[V, F] = marching_tetrahedra(x, y, z, f_grid);

% Construindo corner table, calculando normais, fazendo suavizacao de vertices
[V_corners, C] = constroi_cornertable(V, F);
[normais_antes] = calcula_normais_vertices(V, F, V_corners, C);
V2 = suavizacao_vertices(V, F, V_corners, C, normais_antes);
[normais_depois] = calcula_normais_vertices(V2, F, V_corners, C);

% Calculando razoes de aspecto dos triangulos antes e depois da suavizacao
razoes_ruim = calcula_razoes_aspecto(V, F);
razoes = calcula_razoes_aspecto(V2, F);

% ==============
% Abaixo desta linha sao apenas plots e coisas de visualizacao
% Nao tem mais nenhum algoritmo do trabalho
% ==============

% Plotando a superficie SEM SUAVIZACAO e o seu histograma de razao de aspectos dos triangulos
grafico = subplot(1, 2, 2);
hist_edges = [0:0.1:1];
h1 = histogram(razoes_ruim, hist_edges, 'Normalization', 'probability', 'Orientation', 'horizontal');
h1 = max(h1.Values);
set(grafico, 'Units', 'Normalized', 'Position', [0.8, 0.1, 0.15, 0.8]);
title('Qualidade', 'FontSize', 15);
xl_1 = gca;
grafico = subplot(1, 2, 1);
plot_objeto(V, F);
hold on;
if( flag_plotar_normais )
	quiver3(V(:, 1), V(:, 2), V(:, 3), normais_antes(:, 1), normais_antes(:, 2), normais_antes(:, 3), 'color', [1 0 0]);
end
set(grafico, 'Units', 'Normalized', 'Position', [0.05, 0.1, 0.7, 0.8]);
title('Superficie SEM suavizacao de vertices', 'FontSize', 15);
fig1 = gcf;



figure;
% Plotando a superficie COM SUAVIZACAO e o seu histograma de razao de aspectos dos triangulos
grafico = subplot(1, 2, 2);
h2 = histogram(razoes, hist_edges, 'Normalization', 'probability', 'Orientation', 'horizontal');
limite_hist = max([h1 max(h2.Values)]);
limite_hist = 1.1*limite_hist;
xlim([0  limite_hist]);
xlim(xl_1, [0 limite_hist]);
set(grafico, 'Units', 'Normalized', 'Position', [0.8, 0.1, 0.15, 0.8]);
title('Qualidade', 'FontSize', 15);

grafico = subplot(1, 2, 1);
plot_objeto(V2, F);
hold on;
if( flag_plotar_normais )
	quiver3(V2(:, 1), V2(:, 2), V2(:, 3), normais_depois(:, 1), normais_depois(:, 2), normais_depois(:, 3), 'color', [1 0 0]);
end
set(grafico, 'Units', 'Normalized', 'Position', [0.05, 0.1, 0.7, 0.8]);
title('Superficie COM suavizacao de vertices', 'FontSize', 15);

% saveas(fig1, [nome_exemplo '-semsuav.png']);
% saveas(gcf, [nome_exemplo '-comsuav.png']);




toc