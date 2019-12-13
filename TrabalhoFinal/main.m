clear;
clc
close all;
clear textprogressbar;
clear funcao_maximizar_HRBF;
tic

% ======================================================
% === Definicao de parametros pelo usuario
% ======================================================

% nome_modelo = 'esfera'
% nome_modelo = 'bunny'
nome_modelo = 'spot'
% nome_modelo = 'torus_ana'
% nome_modelo = 'cubo_buraco'
% nome_modelo = 'torcido'
% nome_modelo = 'armadillo'





% tipo_interpolacao = 'HRBF'
tipo_interpolacao = 'LSHRBF'

% Quantidade de particoes de unidade em cada direcao
Mx = 1;
My = Mx;
Mz = Mx;

% Quantidade de centros por particao
N_parts = 200;

% Dimensao do grid pra avaliar a funcao no final e reconstruir a superficie
dim_grid = 40;

% Dimensao do grid fantasma usado para adicionar pontos fantasmas em regioes muito vazias
% Quanto maior, mais ele remove as folhas falsas no LSHRBF, mas pode dar uma piorada na superficie
grid_fantasma = 1;

% ========================================================
% === Fim da definicao de parametros pelo usuario
% ========================================================






load(['modelos/', nome_modelo, '.mat']);




Valores = zeros( size(P, 1), 1 );


% Deixando as normais unitarias
for i=1:size(N, 1)
	N(i, :) = N(i, :)/norm(N(i, :));
end

% Normalizando os pontos
pmin = min(P, [], 1);
pmax = max(P, [], 1);
centroid = sum(P, 1);

psize = pmax - pmin;
centroid = psize / 2;
for i=1:size(P, 1)
  P(i,1:3) = ((P(i,1:3) - pmin - centroid) / max(psize));
  P(i,1:3) = P(i,1:3) * 10;
end

min_pou = min(P, [], 1);
max_pou = max(P, [], 1);
pou_size = max_pou - min_pou;

% Adiciona uma margem
margem_fator = 0.25;
max_pou = max_pou + pou_size*margem_fator;
min_pou = min_pou - pou_size*margem_fator;

% Parametros para a escolha dos centros
k1 = 100.0/norm(max_pou - min_pou);
k2 = 0.5;


% RBF e suas derivadas
psi = @(x)( norm(x).^3 );
psi_x = @(x)( 3.0*norm(x)*x(1) );
psi_y = @(x)( 3.0*norm(x)*x(2) );
psi_z = @(x)( 3.0*norm(x)*x(3) );
psi_xx = @(x)( 3.0*( norm(x)^2 + x(1)^2 )/norm(x) );
psi_yy = @(x)( 3.0*( norm(x)^2 + x(2)^2 )/norm(x) );
psi_zz = @(x)( 3.0*( norm(x)^2 + x(3)^2 )/norm(x) );
psi_xy = @(x)( 3.0*( x(1)*x(2) )/norm(x) );
psi_xz = @(x)( 3.0*( x(1)*x(3) )/norm(x) );
psi_yz = @(x)( 3.0*( x(2)*x(3) )/norm(x) );

H_psi = @(x) ...
	( [...
		psi_xx(x), psi_xy(x), psi_xz(x);
		psi_xy(x), psi_yy(x), psi_yz(x);
		psi_xz(x), psi_yz(x), psi_zz(x)
	]);

grad_psi = @(x)( [ psi_x(x); psi_y(x); psi_z(x) ] );


[S, T, P_Particoes] = cria_particoes_unidade(P, N, Valores, Mx, My, Mz, N_parts, min_pou, max_pou);

centros_parts = escolhe_centros( ...
							N_parts, tipo_interpolacao, ...	
							P, N, Valores, P_Particoes, 1, ...
							k1, k2, ...
							psi, psi_x, psi_y, psi_z, ...
							psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz ...
						);


% Adicionando pontos fantasmas em regioes muito vazias
% Isso ajuda a remover folhas falsas de nivel zero
[P_fantasma, N_fantasma, V_fantasma] = cria_pontos_fantasmas(P, N, min_pou, max_pou, grid_fantasma);
disp(['Pontos fantasmas adicionados: ', num2str(size(P_fantasma, 1))] );
P = [P; P_fantasma];
N = [N; N_fantasma];
Valores = [Valores; V_fantasma];
[S, T, P_Particoes] = cria_particoes_unidade(P, N, Valores, Mx, My, Mz, N_parts, min_pou, max_pou);


% Calculando a funcao interpoladora local de cada particao
disp('Calculando a funcao interpoladora final de cada particao...')
alfa = cell(Mx, My, Mz);
beta = cell(Mx, My, Mz);
lambda = cell(Mx, My, Mz);
base_p = cell(Mx, My, Mz);
for i_part = 1:Mx
	for j_part = 1:My
		for k_part = 1:Mz

			% Pegando apenas os pontos desta particao
			indices_pontos = P_Particoes{i_part, j_part, k_part};
			P_Local = P(indices_pontos, :);
			N_Local = N(indices_pontos, :);
			V_Local = Valores(indices_pontos);
			centros = centros_parts{i_part, j_part, k_part};


			if( strcmp(tipo_interpolacao, 'HRBF') )
				[alfa_aux, beta_aux, lambda_aux, base_p_aux] = ...
											determina_coeficientes_HRBF( ...	
												P_Local(centros, :), N_Local(centros, :), V_Local(centros), 1, ...
												psi, psi_x, psi_y, psi_z, ...
												psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz, ...
												true ...
											);
			elseif( strcmp(tipo_interpolacao, 'LSHRBF') )
				[alfa_aux, beta_aux, lambda_aux, base_p_aux] = ...
											determina_coeficientes_LSHRBF( ...	
												P_Local, N_Local, P_Local(centros, :), V_Local, 1, ...
												psi, psi_x, psi_y, psi_z, ...
												psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz, ...
												true ...
											);
			end

			alfa{i_part, j_part, k_part} = alfa_aux;
			beta{i_part, j_part, k_part} = beta_aux;
			lambda{i_part, j_part, k_part} = lambda_aux;
			base_p{i_part, j_part, k_part} = base_p_aux;

		end
	end
end



intervalo_x = 0.5*[S{1, 1, 1}(1) + min(P(:, 1)), T{Mx, My, Mz}(1) + max(P(:, 1))];
intervalo_y = 0.5*[S{1, 1, 1}(2) + min(P(:, 2)), T{Mx, My, Mz}(2) + max(P(:, 2))];
intervalo_z = 0.5*[S{1, 1, 1}(3) + min(P(:, 3)), T{Mx, My, Mz}(3) + max(P(:, 3))];
tx = linspace(intervalo_x(1), intervalo_x(2), dim_grid);
ty = linspace(intervalo_y(1), intervalo_y(2), dim_grid);
tz = linspace(intervalo_z(1), intervalo_z(2), dim_grid);
[x_grid, y_grid, z_grid] = meshgrid(tx, ty, tz);
F_grid = zeros(dim_grid, dim_grid, dim_grid);

textprogressbar('Avaliando a funcao no grid: ');
for( i=1:size(x_grid, 1) )
	textprogressbar( 100*i/size(x_grid, 1) );
	for( j=1:size(x_grid, 2) )
		for( k=1:size(x_grid, 3) )
			x = [x_grid(i, j, k), y_grid(i, j, k), z_grid(i, j, k)];

			F_grid(i, j, k) = funcao_interp_particao( ...
								x, P, P_Particoes, centros_parts, S, T, alfa, beta, lambda, ...
								psi, psi_x, psi_y, psi_z, base_p);

		end
	end
end
textprogressbar(100);
textprogressbar('');

tempo_execucao = toc


[f, v] = isosurface(x_grid, y_grid, z_grid, F_grid, 0.0);
nome_arq_results = ['results/', nome_modelo, '-tipo', tipo_interpolacao, ...
					'-centros', num2str(N_parts), '-parts', num2str(Mx)];
save(nome_arq_results, 	'P', 'N', 'P_Particoes', 'centros_parts', ...
						'N_parts', 'dim_grid', 'tempo_execucao', ...
						'S', 'T', ...
						'alfa', 'beta', 'lambda', 'base_p', ...
						'F_grid', 'x_grid', 'y_grid', 'z_grid', ...
						'f', 'v');


% hold on
% scatter3(P(:, 1), P(:, 2), P(:, 3), 'MarkerEdgeColor', 'b')	
% quiver3(P(:, 1), P(:, 2), P(:, 3), N(:, 1), N(:, 2), N(:, 3))
% aaa
% figure()

% [F, V] = isosurface(x_grid, y_grid, z_grid, F_grid, 0.0);
% trimesh(F, V(:, 1), V(:, 2), V(:, 3))
% trisurf(F, V(:, 1), V(:, 2), V(:, 3), 'EdgeColor', 'None')

figure('Name','Zero-level Isosurface','NumberTitle','off')
  set(gcf, 'Color', 'w');
  grid on;
  % [f, v] = isosurface(x_grid, y_grid, z_grid, F_grid, 0.0);
  % if eval_options(5)
  %   vertface2obj(v, f, fullfile(eval_dirout, eval_fileout));
  % end
  p = patch(isosurface(x_grid, y_grid, z_grid, F_grid, 0.0));
  isonormals(x_grid, y_grid, z_grid, F_grid, p);
  set(p,'FaceColor',[.9 .9 .9],'EdgeColor','none');
  daspect([1 1 1]);
  cl1 = camlight(-20,  55,'infinite'); set(cl1, 'Color', [1    0.65 0.15]);
  cl3 = camlight( 135,-20,'infinite'); set(cl3, 'Color', [1    0.55 0.15]);
  cl2 = camlight( 20, -55,'infinite'); set(cl2, 'Color', [0.15 0.65 1   ]);
  cl4 = camlight(-135, 20,'infinite'); set(cl4, 'Color', [0.15 0.55 1   ]);

  material dull;
  lighting phong;
  alpha(1);
  
  % [M_tot N_tot O_tot] = size(LSV2);  
  
  % axis([1 N_tot 1 M_tot 1 O_tot]); axis off;
  view(-45,45); 





hold on;
% Plotando os centros usados
% scatter3(P(:, 1), P(:, 2), P(:, 3), 'MarkerEdgeColor', 'b')	
% quiver3(P(:, 1), P(:, 2), P(:, 3), N(:, 1), N(:, 2), N(:, 3))
for i_part = 1:Mx
	for j_part = 1:My
		for k_part = 1:Mz
			P_Local = P(P_Particoes{i_part, j_part, k_part}, :);
			centros = centros_parts{i_part, j_part, k_part};
			scatter3(P_Local(centros, 1), P_Local(centros, 2), P_Local(centros, 3), 50, 'red', 'filled', 'MarkerEdgeColor', 'k')			
		end
	end
end

xlabel('x')
ylabel('y')
zlabel('z')


% OptionZ.FrameRate=15;OptionZ.Duration=5.5;OptionZ.Periodic=true;
% CaptureFigVid([0, 50; 180, -50; 360, -50], 'testevideo', OptionZ)

% % Parametros video bunny
% CaptureFigVid([0, 90; 360, 0], 'testevideo', OptionZ)