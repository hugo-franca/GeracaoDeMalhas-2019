[P, N, F] = read_obj('armadillo.obj');
% [P, N, F] = read_obj('teste_ana/Test_02_Vert_6758.obj');


% trimesh(F, P(:, 1), P(:, 2), P(:, 3))
hold on

scatter3(P(:, 1), P(:, 2), P(:, 3), 'MarkerEdgeColor', 'b')	
quiver3(P(:, 1), P(:, 2), P(:, 3), N(:, 1), N(:, 2), N(:, 3))