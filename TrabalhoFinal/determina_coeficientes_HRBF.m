% OUTPUT
% 	V: Coordenadas dos pontos da nuvem de pontos
% 	N: Vetor normal da superficie em cada ponto da nuvem
% 	psi: funcao de base radial
% 	psi_x, psi_y, psi_z: derivadas da funcao de base radial

% OUTPUT
% 	Coeficientes da funcao interpoladora
function [alfa, beta, lambda, base_p] = determina_coeficientes_HRBF( ...
										Pontos, Normais, Valores, Grau_P, ...
										psi, psi_x, psi_y, psi_z, ...
										psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz, ...
										limpar_tudo ...
									)


	global A D D_2 G P A_p P_g G_p;

	% Esse caso acontece nas particoes vazias que nao possuem pontos dentro delas
	if( isempty(Pontos) )
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

	% Diferenca entre a qtd de centros ja inseridos e a nova quantidade
	dif_n = n - size(A, 2);
	centro_ini = n - dif_n + 1;

	% Construindo a matriz A
	for( i=centro_ini:n )

		% Adicionando uma linha inteira e uma coluna inteira
		for( j=1:n )
			A(i, j) = psi( Pontos(i, :) - Pontos(j, :) );
			A(j, i) = psi( Pontos(j, :) - Pontos(i, :) );
			% Eh simetrico, mas enfim... vou deixar os dois soh pra generalizar caso nao fosse
		end
	end

	% Construindo a matriz D
	for( i=centro_ini:n )

		% Adicionando uma linha inteira e tres colunas inteiras
		for( j=1:n )

			% Uma linha
			dif = Pontos(i, :) - Pontos(j, :);
			D(i, 3*(j-1) + 1) = psi_x( dif );
			D(i, 3*(j-1) + 2) = psi_y( dif );
			D(i, 3*(j-1) + 3) = psi_z( dif );

			% Tres colunas
			dif = Pontos(j, :) - Pontos(i, :);
			D(j, 3*(i-1) + 1) = psi_x( dif );
			D(j, 3*(i-1) + 2) = psi_y( dif );
			D(j, 3*(i-1) + 3) = psi_z( dif );
		end
	end


	% Construindo a matriz D_2
	% Tres linhas inteiras e uma coluna inteira
	for( i=centro_ini:n )
		for( j=1:n )

			% Tres linhas
			dif = Pontos(i, :) - Pontos(j, :);
			D_2(3*(i-1) + 1, j) = psi_x( dif );
			D_2(3*(i-1) + 2, j) = psi_y( dif );
			D_2(3*(i-1) + 3, j) = psi_z( dif );

			% Uma coluna
			dif = Pontos(j, :) - Pontos(i, :);
			D_2(3*(j-1) + 1, i) = psi_x( dif );
			D_2(3*(j-1) + 2, i) = psi_y( dif );
			D_2(3*(j-1) + 3, i) = psi_z( dif );
		end
	end


	% Construindo a matriz G
	% Adicionando apenas uma nova linha ou uma nova coluna de blocos H
	for( i=centro_ini:n )
		for( j=1:n )

			% Sentido (i, j)
			if( i==j )
				H = zeros(3, 3);
			else
				dif = Pontos(i, :) - Pontos(j, :);
				H(1, 1) = psi_xx( dif );
				H(1, 2) = psi_xy( dif );
				H(1, 3) = psi_xz( dif );
				H(2, 1) = H(1, 2);
				H(2, 2) = psi_yy( dif );
				H(2, 3) = psi_yz( dif );
				H(3, 1) = H(1, 3);
				H(3, 2) = H(2, 3);
				H(3, 3) = psi_zz( dif );

				% H = hessiana( {dif} );
			end

			G(3*(i-1) + 1:3*(i-1) + 3, 3*(j-1) + 1:3*(j-1) + 3) = H;


			% Sentido (j, i)
			if( i==j )
				H = zeros(3, 3);
			else
				dif = Pontos(j, :) - Pontos(i, :);
				H(1, 1) = psi_xx( dif );
				H(1, 2) = psi_xy( dif );
				H(1, 3) = psi_xz( dif );
				H(2, 1) = H(1, 2);
				H(2, 2) = psi_yy( dif );
				H(2, 3) = psi_yz( dif );
				H(3, 1) = H(1, 3);
				H(3, 2) = H(2, 3);
				H(3, 3) = psi_zz( dif );

				% H = hessiana( {dif} );
			end

			G(3*(j-1) + 1:3*(j-1) + 3, 3*(i-1) + 1:3*(i-1) + 3) = H;
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
	% Adicionando apenas uma nova linha
	for( i=centro_ini:n )
		x = Pontos(i, :);
		for( j=1:N )
			P(i, j) = x(1)^expoentes(j, 1)*x(2)^expoentes(j, 2)*x(3)^expoentes(j, 3);
		end
	end


	% Construindo a matriz P_g
	for( i=centro_ini:n )
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

	matriz = [	A, -D, P; ...
				D_2, -G, P_g; ...
				P', P_g', zeros(N, N)];

	% Construindo o rhs
	rhs = zeros(length(matriz), 1);
	linha = n + 1;
	for( i=1:n )
		rhs(i) = Valores(i);

		rhs(linha) = Normais(i, 1);
		rhs(linha + 1) = Normais(i, 2);
		rhs(linha + 2) = Normais(i, 3);
		linha = linha + 3;
	end

	x = matriz \ rhs;

	alfa = x(1:n);
	beta = x(n+1:4*n);
	lambda = x(4*n+1:end);
	base_p = expoentes;

end
