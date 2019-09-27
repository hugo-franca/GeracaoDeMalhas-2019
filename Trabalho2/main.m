clear;
clc
clear textprogressbar;
clear imagem_gif;
tic

% Parametros
n = 80; % Dimensao do grid
expoente_RBF = 1;
offset = 0.01;

% Funcao RBF
psi = @(r)( r.^expoente_RBF );

% Lendo a nuvem de pontos: Vai ler uma matriz P e uma matriz N
load('modelos/bunny.mat');
% load('modelos/cow.mat');
% load('modelos/teddy.mat');
% load('modelos/teapot.mat');

% Funcao interpoladora
interp_RBF = @(lambda, distancias)( dot(lambda, psi(distancias), 2) );

% Construindo os novos pontos da nuvem usando o offset
n_p = length(P);
P = [P; P + offset*N; P-offset*N];

% Construindo o rhs do sistema linear
f = [zeros(n_p, 1); ones(n_p, 1); -ones(n_p, 1)];

% Calculando a matriz do sistema linear
A = psi(pdist2(P, P));

% Calculando os coeficientes pelo sistema linear
lambda = A\f;

% Construindo o grid pra interpolar
intervalo_x = [min(P(:, 1)), max(P(:, 1))]*1.1;
intervalo_y = [min(P(:, 2)), max(P(:, 2))]*1.1;
intervalo_z = [min(P(:, 3)), max(P(:, 3))]*1.1;
tx = linspace(intervalo_x(1), intervalo_x(2), n);
ty = linspace(intervalo_y(1), intervalo_y(2), n);
tz = linspace(intervalo_z(1), intervalo_z(2), n);
[x_grid, y_grid, z_grid] = meshgrid(tx, ty, tz);
F_grid = zeros(n, n, n);

% Transformando o lambda numa matriz pra usar com o mat_distancias a seguir
mat_lambda = repmat(lambda', n*n, 1);

% Vou calcular o valor de F no grid por cortes
% Eu tentei fazer tudo de uma vez mas usava MUITA memoria pra grids muito refinados e estourava
textprogressbar('Calculando: ');
for k=1:n
	textprogressbar( 100*k/n );

	x_corte = x_grid(:, :, k);
	y_corte = y_grid(:, :, k);
	z_corte = z_grid(:, :, k);
	pontos_corte = [x_corte(:) y_corte(:) z_corte(:)];

	mat_distancias = pdist2(pontos_corte, P);
	F_corte = interp_RBF(mat_lambda, mat_distancias);
	F_grid(:, :, k) = reshape(F_corte, n, n);

end

textprogressbar(100);
textprogressbar('');

% Calculando a malha triangulada e plotando
[F, V] = isosurface(x_grid, y_grid, z_grid, F_grid, 0.0);
trimesh(F, V(:, 1), V(:, 2), V(:, 3));


% Configuracoes do plot
title("RBF: r^" + num2str(expoente_RBF) + "         Offset = " ...
	+ num2str(offset) +  "         Grid = " + num2str(n) + "x" + num2str(n) + "x" + num2str(n), ...
	'FontSize', 17);
view(180, 100);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gca,'xtick',[], 'ytick', [], 'ztick', []);
set(gca,'xticklabel',[]);
hold off;

toc