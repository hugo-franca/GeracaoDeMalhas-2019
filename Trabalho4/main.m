
clear;
clear classes;
clear textprogressbar;
clc;

% Ponto de visao
p = [1.5, 0, 0];


% Lendo uma nuvem de pontos em uma matriz V
% Voce pode mudar este arquivo para qualquer outro, desde que a nuvem esteja armazenada em uma matriz com nome V
load('modelos/esfera.mat');
% load('modelos/paraboloide.mat');




% Calculando o fecho convexo da nuvem de pontos
F = convhulln(V);

% Construindo a corner table do fecho convexo
[V_Corners, F_Corners, Corners] = constroi_cornertable(V, F);

% Calculando as faces visiveis do fecho convexo pelo ponto p
[faces_visiveis, horizonte] = calcula_faces_visiveis(V, F, V_Corners, F_Corners, Corners, p);


% Plotando as coisas
hold on
V(end+1, :) = p;
scatter3(p(1), p(2), p(3))
trimesh(F, V(:, 1), V(:, 2), V(:, 3), 'EdgeColor','k')
trisurf(F(faces_visiveis, :), V(:, 1), V(:, 2), V(:, 3),'Facecolor','red','FaceAlpha',0.99,'EdgeColor','none')

horizonte = horizonte(:);
qtd = length(horizonte);
x = [V(horizonte(:), 1), repmat(p(1), qtd, 1)]';
y = [V(horizonte(:), 2), repmat(p(2), qtd, 1)]';
z = [V(horizonte(:), 3), repmat(p(3), qtd, 1)]';
plot3(x, y, z, '-b');

