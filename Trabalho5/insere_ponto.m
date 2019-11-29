function [xy, T] = insere_ponto(p, xy, T)

	global xy_rec T_rec;

	% Adicionando este vertice na lista xy
	xy(end+1, :) = p;

	% Obtendo o indice deste novo vertice na lista
	i_p = size(xy, 1);

	% Procurando o triangulo que contem este ponto
	i_tri = encontra_triangulo(p, xy, T);

	% Obtendo os indices dos tres pontos deste triangulo
	i_p0 = T(i_tri, 1);
	i_p1 = T(i_tri, 2);
	i_p2 = T(i_tri, 3);

	% Dividindo o triangulo em 3 sub-triangulos
	tri_1 = [i_p0, i_p1, i_p];
	tri_2 = [i_p1, i_p2, i_p];
	tri_3 = [i_p2, i_p0, i_p];

	% Removendo o triangulo original da lista
	T(i_tri, :) = [];

	% Adicionando os 3 novos triangulos na lista
	T(end+1:end+3, :) = [tri_1; tri_2; tri_3];
	
	% Preparando variaveis globais auxiliares para usar na recursao logo abaixo
	xy_rec = xy;
	T_rec = T;

	plota_figura(xy_rec, T, [], [], false, 'O tri\^angulo foi sub-dividido');

	% Criando uma lista de arestas a ser analisadas apenas pra plotar
	% Eu uso esta lista literalmente apenas pra desenhar as arestas na figura.
	% Ela nao eh utilizada no algoritmo
	global lista_arestas;
	lista_arestas(end+1, :) = [i_p0, i_p1];
	lista_arestas(end+1, :) = [i_p0, i_p2];
	lista_arestas(end+1, :) = [i_p1, i_p2];

	plota_figura(xy_rec, T, [], [], false, 'Adicionou as arestas externas (em verde) na pilha');

	% Fazendo, se necessario, a troca de arestas nestes tres corners
	troca_arestas(i_p, i_p0, i_p1);
	troca_arestas(i_p, i_p0, i_p2);
	troca_arestas(i_p, i_p1, i_p2);

	xy = xy_rec;
	T = T_rec;



end