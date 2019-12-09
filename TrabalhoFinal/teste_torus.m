clear;
clc
close all;
clear textprogressbar;
tic

load('modelos/torus.mat');
Valores = zeros( size(P, 1), 1 );


% tipo_interpolacao = 'HRBF'
tipo_interpolacao = 'LSHRBF'

% Quantidade de particoes em cada direcao
Mx = 1;
My = 1;
Mz = 1;

erro = [];

for N_parts=[1:121]

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


	[S, T, P_Particoes, P, N, Valores] = cria_particoes_unidade(P, N, Valores, Mx, My, Mz, N_parts);


	centros_parts = escolhe_centros( ...
								N_parts, tipo_interpolacao, ...	
								P, N, Valores, P_Particoes, 1, ...
								psi, psi_x, psi_y, psi_z, ...
								psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz ...
							);



	% Calculando a funcao interpoladora de cada particao
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
													psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz ...
												);
				elseif( strcmp(tipo_interpolacao, 'LSHRBF') )
					[alfa_aux, beta_aux, lambda_aux, base_p_aux] = ...
												determina_coeficientes_LSHRBF( ...	
													P_Local, N_Local, P_Local(centros, :), V_Local, 1, ...
													psi, psi_x, psi_y, psi_z, ...
													psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz ...
												);
				end

				alfa{i_part, j_part, k_part} = alfa_aux;
				beta{i_part, j_part, k_part} = beta_aux;
				lambda{i_part, j_part, k_part} = lambda_aux;
				base_p{i_part, j_part, k_part} = base_p_aux;

			end
		end
	end



	dim_grid = 80;
	intervalo_x = 0.5*[S{1, 1, 1}(1) + min(P(:, 1)), T{Mx, My, Mz}(1) + max(P(:, 1))];
	intervalo_y = 0.5*[S{1, 1, 1}(2) + min(P(:, 2)), T{Mx, My, Mz}(2) + max(P(:, 2))];
	intervalo_z = 0.5*[S{1, 1, 1}(3) + min(P(:, 3)), T{Mx, My, Mz}(3) + max(P(:, 3))];
	tx = linspace(intervalo_x(1), intervalo_x(2), dim_grid);
	ty = linspace(intervalo_y(1), intervalo_y(2), dim_grid);
	tz = linspace(intervalo_z(1), intervalo_z(2), dim_grid);
	[x_grid, y_grid, z_grid] = meshgrid(tx, ty, tz);
	F_grid = zeros(dim_grid, dim_grid, dim_grid);

	% textprogressbar('Avaliando a funcao no grid: ')
	% for( i=1:size(x_grid, 1) )
	% 	textprogressbar( 100*i/size(x_grid, 1) );

	% 	for( j=1:size(x_grid, 2) )
	% 		for( k=1:size(x_grid, 3) )
	% 			x = [x_grid(i, j, k), y_grid(i, j, k), z_grid(i, j, k)];

	% 			F_grid(i, j, k) = funcao_interp_particao( ...
	% 								x, P, P_Particoes, centros_parts, S, T, alfa, beta, lambda, ...
	% 								psi, psi_x, psi_y, psi_z, base_p);

	% 		end
	% 	end
	% end
	% textprogressbar(100);
	% textprogressbar('');

	R = 2;
	r = 1;
	% funcao_torus = @(x, y, z)( (x.^2 + y.^2 + z.^2 + R^2 - r^2).^2 - 4*R*R*( x.^2 + y.^2 ) );
	funcao_torus = @(x, y, z)( (sqrt(x.^2 + y.^2) - R).^2 + z.^2 - r*r  );
	F_exata_grid = funcao_torus(x_grid, y_grid, z_grid);

	F_comp_exato = [];
	F_comp_aprox = [];

	% Para cada particula calcula o erro em sua celula
	dx = tx(2) - tx(1);
	dy = ty(2) - ty(1);
	dz = tz(2) - tz(1);
	xMin = intervalo_x(1);
	yMin = intervalo_y(1);
	zMin = intervalo_z(1);
	for indice_p = 1:size(P, 1)
		ponto = P(indice_p, :);

		i = floor( (ponto(1) - xMin)/dx ) + 1;
		j = floor( (ponto(2) - yMin)/dy ) + 1;
		k = floor( (ponto(3) - zMin)/dz ) + 1;

		celula_p1 = [x_grid(i, j, k) y_grid(i, j, k) z_grid(i, j, k)];
		celula_p2 = [x_grid(i+1, j+1, k+1) y_grid(i+1, j+1, k+1) z_grid(i+1, j+1, k+1)];

		% Adiciona o centro desta celula na lista
		centro = 0.5*(celula_p1 + celula_p2);
		F_comp_exato(end+1) = funcao_torus( centro(1), centro(2), centro(3) );
		F_comp_aprox(end+1) = funcao_interp_particao( ...
						centro, P, P_Particoes, centros_parts, S, T, alfa, beta, lambda, ...
						psi, psi_x, psi_y, psi_z, base_p);
	
	end


	% for( i=1:dim_grid-1 )
	% 	textprogressbar( 100*i/(dim_grid-1));
	% 	for( j=1:dim_grid-1 )
	% 		for( k=1:dim_grid-1 )

	% 			celula_p1 = [x_grid(i, j, k) y_grid(i, j, k) z_grid(i, j, k)];
	% 			celula_p2 = [x_grid(i+1, j+1, k+1) y_grid(i+1, j+1, k+1) z_grid(i+1, j+1, k+1)];

	% 			% Verifica se existe alguma particula nesta celula
	% 			for indice_p = 1:size(P, 1)

	% 				ponto = P(indice_p, :);

	% 				% Se o ponto for "menor" (cada coordenada) que este S, nao esta no cubo
	% 				if( find( (ponto < celula_p1)==1 )   )
	% 					continue;
	% 				end

	% 				% Se o ponto for "maior" que este T, nao esta no cubo
	% 				if( find( (ponto > celula_p2)==1 )   )
	% 					continue;
	% 				end

	% 				% Adiciona o centro desta celula na lista
	% 				centro = 0.5*(celula_p1 + celula_p2);
	% 				F_comp_exato(end+1) = funcao_torus( centro(1), centro(2), centro(3) );
	% 				F_comp_aprox(end+1) = funcao_interp_particao( ...
	% 								centro, P, P_Particoes, centros_parts, S, T, alfa, beta, lambda, ...
	% 								psi, psi_x, psi_y, psi_z, base_p);
	% 			end

	% 		end
	% 	end
	% end
	% textprogressbar(100);
	% textprogressbar('');

	diferenca = F_comp_exato - F_comp_aprox;

	erro(end+1) = norm( diferenca )
		
	% isosurface(x_grid, y_grid, z_grid, F_exata_grid, 0.0);
	% xlabel('x')
	% ylabel('y')
	% zlabel('z')
	% figure
	% isosurface(x_grid, y_grid, z_grid, F_grid, 0.0);
	% xlabel('x')
	% ylabel('y')
	% zlabel('z')
	% aaaa

end

save(['modelos/erro', tipo_interpolacao, '.mat'], 'erro')