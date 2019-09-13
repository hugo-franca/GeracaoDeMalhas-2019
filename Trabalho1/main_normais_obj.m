clear;
clear textprogressbar;
clc;

disp('Lendo o arquivo obj.....')
[V, F] = read_obj('modelos/bunny.obj');
% [V, F] = read_obj('modelos/vanille.obj');


% Flag para plotar as normais ou entao apenas a superficie
flag_normais = true;

% Flag para destacar um anel de um vertice especifico, para demonstrar o uso da corner_table
% Escolha tambem qual vertice tera seu anel calculado
flag_anel = true;
indice_vert_anel = 10;



[V_corners, C] = constroi_cornertable(V, F);
norms_vertices = calcula_normais_vertices(V, F, V_corners, C);

plot_objeto(V, F);
hold on;

if( flag_normais )
	quiver3(V(:, 1), V(:, 2), V(:, 3), norms_vertices(:, 1), norms_vertices(:, 2), norms_vertices(:, 3), 'color', [1 0 0]);
end

if( flag_anel )
	verts_anel = anel(indice_vert_anel, V, V_corners, C);
	scatter3(verts_anel(:, 1), verts_anel(:, 2), verts_anel(:, 3), 50, 'filled', ...
			'MarkerEdgeColor','k', 'MarkerFaceColor',[0 0 1])
	scatter3(V(indice_vert_anel, 1), V(indice_vert_anel, 2), V(indice_vert_anel, 3), 50, 'filled', ...
			'MarkerEdgeColor','k', 'MarkerFaceColor',[0, 0, 0])
end



