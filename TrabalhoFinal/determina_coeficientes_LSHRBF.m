% OUTPUT
% 	V: Coordenadas dos pontos da nuvem de pontos
% 	N: Vetor normal da superficie em cada ponto da nuvem
% 	psi: funcao de base radial
% 	psi_x, psi_y, psi_z: derivadas da funcao de base radial

% OUTPUT
% 	Coeficientes da funcao interpoladora
function [alfa, beta, lambda, base_p] = determina_coeficientes_LSHRBF( ...
										Pontos, Normais, Centros, Valores, Grau_P, ...
										psi, psi_x, psi_y, psi_z, ...
										psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz, ...
										limpar_tudo ...
									)
	
	global A D D_2 G P A_p P_g G_p;


	% Esse caso acontece nas particoes vazias que nao possuem pontos dentro delas
	if( isempty(Centros) || isempty(Pontos) )
		alfa = [];
		beta = [];
		lambda = [];
		base_p = [];
		return
	end


	% Vai recalcular novamente todas as matrizes desde o inicio
	if( limpar_tudo )
		clear A D D_2 G P A_p P_g G_p;
		A = [];
		D = [];
		D_2 = [];
		G = [];
		P = [];
		A_p = [];
		P_g = [];
		G_p = [];
	end


	% Quantidade de pontos na nuvem
	n = size(Pontos, 1);

	% Quantidade de centros
	L = size(Centros, 1);

	% Diferenca entre a qtd de centros ja inseridos e a nova quantidade
	dif_L = L - size(A, 2);
	centro_ini = L - dif_L + 1;
	
	% Construindo a matriz A
	% j = L;
	for( i=1:n )
		for( j=centro_ini:L )
			A(i, j) = psi( Pontos(i, :) - Centros(j, :) );
		end
	end


	% Construindo a matriz D
	% j = L;
	for( i=1:n )
		for( j=centro_ini:L )
			dif = Pontos(i, :) - Centros(j, :);
			D(i, 3*(j-1) + 1) = psi_x( dif );
			D(i, 3*(j-1) + 2) = psi_y( dif );
			D(i, 3*(j-1) + 3) = psi_z( dif );
		end
	end

	% Construindo a matriz D_2
	% j = L;
	for( i=1:n )
		for( j=centro_ini:L )
			dif = Pontos(i, :) - Centros(j, :);
			D_2(3*(i-1) + 1, j) = psi_x( dif );
			D_2(3*(i-1) + 2, j) = psi_y( dif );
			D_2(3*(i-1) + 3, j) = psi_z( dif );
		end
	end


	% Construindo a matriz G
	% j = L;
	for( i=1:n )
		for( j=centro_ini:L )
			dif = Pontos(i, :) - Centros(j, :);

			if( norm(dif) < 1e-7 )
				H = zeros(3, 3);
			else
				H(1, 1) = psi_xx( dif );
				H(1, 2) = psi_xy( dif );
				H(1, 3) = psi_xz( dif );
				H(2, 1) = H(1, 2);
				H(2, 2) = psi_yy( dif );
				H(2, 3) = psi_yz( dif );
				H(3, 1) = H(1, 3);
				H(3, 2) = H(2, 3);
				H(3, 3) = psi_zz( dif );
			end

			G(3*(i-1) + 1:3*(i-1) + 3, 3*(j-1) + 1:3*(j-1) + 3) = H;
		end
	end

	% Construindo uma base para o espaco de polinomios de grau Grau_P
	% Cada linha da matriz expoentes (no final) possui os tres expoentes de um dos "monomios" da base
	% Por exemplo: a linha [1 2 1] corresponde ao monomio x*y^2*z
	expoentes = repmat( [0:Grau_P]' , 1, 3);
	expoentes = expoentes(:);
	expoentes = unique( nchoosek(expoentes, 3) , 'rows' );
	indices = find( sum(expoentes')<=Grau_P );
	expoentes = expoentes(indices, :);
	N = size(expoentes, 1);

	% Construindo a matriz P
	if( isempty(P) )
		P = zeros(n, N);
		for( i=1:n )
			x = Pontos(i, :);
			for( j=1:N )
				P(i, j) = x(1)^expoentes(j, 1)*x(2)^expoentes(j, 2)*x(3)^expoentes(j, 3);
			end
		end
	end

	% Construindo a matriz A_p
	% j = L;
	for( i=1:N )
		for( j=centro_ini:L )
			x = Centros(j, :);
			A_p(i, j) = x(1)^expoentes(i, 1)*x(2)^expoentes(i, 2)*x(3)^expoentes(i, 3);
		end
	end

	% Construindo a matriz P_g
	if( isempty(P_g) )
		P_g = zeros(3*n, N);
		for( i=1:n )
			x = Pontos(i, :);
			for( j=1:N )
				p_j = expoentes(j, :);

				% Tirando uns bugs que daria divisao por zero...
				if( p_j(1)==0 )
					parte_x = 0.0;
				else
					parte_x = p_j(1)*x(1)^(p_j(1) - 1);
				end
				if( p_j(2)==0 )
					parte_y = 0.0;
				else
					parte_y = p_j(2)*x(2)^(p_j(2) - 1);
				end
				if( p_j(3)==0 )
					parte_z = 0.0;
				else
					parte_z = p_j(3)*x(3)^(p_j(3) - 1);
				end

				P_g(3*(i-1) + 1, j) = parte_x*( x(2)^p_j(2) )*( x(3)^p_j(3) );
				P_g(3*(i-1) + 2, j) = parte_y*( x(1)^p_j(1) )*( x(3)^p_j(3) );
				P_g(3*(i-1) + 3, j) = parte_z*( x(2)^p_j(2) )*( x(1)^p_j(1) );

			end
		end
	end

	% Construindo a matriz G_p
	% j = L;
	for( i=1:N )
		p_i = expoentes(i, :);

		for( j=centro_ini:L )
			
			x = Centros(j, :);

			% Tirando uns bugs que daria divisao por zero...
			if( p_i(1)==0 )
				parte_x = 0.0;
			else
				parte_x = p_i(1)*x(1)^(p_i(1) - 1);
			end
			if( p_i(2)==0 )
				parte_y = 0.0;
			else
				parte_y = p_i(2)*x(2)^(p_i(2) - 1);
			end
			if( p_i(3)==0 )
				parte_z = 0.0;
			else
				parte_z = p_i(3)*x(3)^(p_i(3) - 1);
			end

			G_p(i, 3*(j-1) + 1) = parte_x*( x(2)^p_i(2) )*( x(3)^p_i(3) );
			G_p(i, 3*(j-1) + 2) = parte_y*( x(1)^p_i(1) )*( x(3)^p_i(3) );
			G_p(i, 3*(j-1) + 3) = parte_z*( x(2)^p_i(2) )*( x(1)^p_i(1) );
		end
	end


	matriz = [	A, -D, P; ...
				D_2, -G, P_g; ...
				A_p, G_p, zeros(N, N)];

	% matriz = [	A, -D, ...
	% 			D_2, -G];


	% Construindo o rhs
	rhs = zeros(size(matriz, 1), 1);
	linha = n + 1;
	for( i=1:n )
		rhs(i) = Valores(i);
		
		rhs(linha) = Normais(i, 1);
		rhs(linha + 1) = Normais(i, 2);
		rhs(linha + 2) = Normais(i, 3);
		linha = linha + 3;
	end

	x = matriz \ rhs;

	alfa = x(1:L);
	beta = x(L+1:4*L);
	lambda = x(4*L+1:end);
	base_p = expoentes;

end
