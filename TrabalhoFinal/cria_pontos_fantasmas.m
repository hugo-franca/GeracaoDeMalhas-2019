function [Pontos_Fantasmas, Normais_Fantasmas, Valores_Fantasmas] = ...
				cria_pontos_fantasmas(Pontos, Normais, min_dominio, max_dominio, dim_grid_fantasma)

	tx = linspace(min_dominio(1), max_dominio(1), dim_grid_fantasma);
	ty = linspace(min_dominio(2), max_dominio(2), dim_grid_fantasma);
	tz = linspace(min_dominio(3), max_dominio(3), dim_grid_fantasma);
	[x_grid, y_grid, z_grid] = meshgrid(tx, ty, tz);
	contem_ponto = zeros(dim_grid_fantasma-1, dim_grid_fantasma-1, dim_grid_fantasma-1);


	% Percorrendo todos os pontos e marcando quais celulas do grid possuem ao menos um ponto
	n = size(Pontos, 1);
	for i_ponto=1:n

		% Percorrendo cada cubo
		for i=1:dim_grid_fantasma-1
			for j=1:dim_grid_fantasma-1
				for k=1:dim_grid_fantasma-1

					S = [x_grid(i, j, k), y_grid(i, j, k), z_grid(i, j, k)];
					T = [x_grid(i+1, j+1, k+1), y_grid(i+1, j+1, k+1), z_grid(i+1, j+1, k+1)];

					% Se o ponto for "menor" (cada coordenada) que este S, nao esta no cubo
					if( find( (Pontos(i_ponto, :) < S)==1 )   )
						continue;
					end

					% Se o ponto for "maior" que este T, nao esta no cubo
					if( find( (Pontos(i_ponto, :) > T)==1 )   )
						continue;
					end

					contem_ponto(i, j, k) = 1;

				end
			end
		end

	end

	Pontos_Fantasmas = [];
	Normais_Fantasmas = [];
	Valores_Fantasmas = [];

	% Adicionando um ponto no centro de cada celula que que nao tem ponto
	for i=1:dim_grid_fantasma-1
		for j=1:dim_grid_fantasma-1
			for k=1:dim_grid_fantasma-1

				% Se ja possui ponto nessa celula, ignora ela
				if( contem_ponto(i, j, k)==1 )
					continue;
				end

				S = [x_grid(i, j, k), y_grid(i, j, k), z_grid(i, j, k)];
				T = [x_grid(i+1, j+1, k+1), y_grid(i+1, j+1, k+1), z_grid(i+1, j+1, k+1)];


				% Criando um ponto no centro desta celula
				x = 0.5*(S + T);

				% Calculando a distancia deste ponto a todos os outros da superficie
				% Em seguida, pegamos o ponto que esta mais proximo deste
				[menor_dist, indice_menor_dist] = min( pdist2(x, Pontos) );
				p_mais_proximo = Pontos(indice_menor_dist, :);
				normal_p_mais_proximo = Normais(indice_menor_dist, :);

				% Vetor entre o ponto mais proximo e o novo ponto
				v = x - p_mais_proximo;

				% Se v e a normal estiverem em sentidos contrarios, inverte a distancia
				if( dot(v, normal_p_mais_proximo) < 0.0 )
					menor_dist = - menor_dist;
				end

				% Adiciona o novo ponto na lista de pontos fantasmas
				Pontos_Fantasmas(end+1, :) = x;
				Normais_Fantasmas(end+1, :) = normal_p_mais_proximo;
				Valores_Fantasmas(end+1, :) = menor_dist;
			end
		end
	end


end