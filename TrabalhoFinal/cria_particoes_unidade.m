function [S, T, Pontos_Particao] = cria_particoes_unidade(Pontos, Normais, Valores, Mx, My, Mz, minimo_centros, min_dominio, max_dominio)


	% Parametro de sobreposicao
	k_param = 1.2;

	% Obtendo os extremos da nuvem de pontos
	intervalo_x = [min_dominio(1), max_dominio(1)];
	intervalo_y = [min_dominio(2), max_dominio(2)];
	intervalo_z = [min_dominio(3), max_dominio(3)];

	% Particionando de forma nao-sobreposta usando o linspace
	x = linspace(intervalo_x(1), intervalo_x(2), Mx+1);
	y = linspace(intervalo_y(1), intervalo_y(2), My+1);
	z = linspace(intervalo_z(1), intervalo_z(2), Mz+1);

	% Percorrendo os Mx*My*Mz cubos e criando sobreposicoes
	S = cell(Mx, My, Mz);
	T = cell(Mx, My, Mz);
	for i=1:Mx
		for j=1:My
			for k=1:Mz
				

				S_temp = [ x(i), y(j), z(k) ];
				T_temp = [ x(i+1), y(j+1), z(k+1) ];

				S{i, j, k} = S_temp - 0.5*(k_param-1.0)*( T_temp - S_temp );
				T{i, j, k} = T_temp + 0.5*(k_param-1.0)*( T_temp - S_temp );
			end
		end
	end

	% Agora eu vou ver quais pontos estao dentro de cada particao
	textprogressbar('Particionando a nuvem de pontos: ')
	% Para cada ponto, vemos quais particoes contem ele
	n = size(Pontos, 1);
	Pontos_Particao = cell(Mx, My, Mz);
	for i_ponto=1:n

		textprogressbar( 100*i_ponto/n );

		% Percorrendo cada cubo
		for i=1:Mx
			for j=1:My
				for k=1:Mz

					% Se o ponto for "menor" (cada coordenada) que este S, nao esta no cubo
					if( find( (Pontos(i_ponto, :) < S{i, j, k})==1 )   )
						continue;
					end

					% Se o ponto for "maior" que este T, nao esta no cubo
					if( find( (Pontos(i_ponto, :) > T{i, j, k})==1 )   )
						continue;
					end

					Pontos_Particao{i, j, k}(end+1) = i_ponto;

				end
			end
		end

	end

	textprogressbar(100);
	textprogressbar('');

end