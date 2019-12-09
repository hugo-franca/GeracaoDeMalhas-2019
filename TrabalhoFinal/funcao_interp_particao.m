% Alfa_parts eh uma lista de vetores. Cada vetor da lista sao os coeficientes de uma particao
% Beta_parts eh uma lista de vetores. Cada vetor da lista sao os coeficientes de uma particao
% Lambda_parts eh uma lista de vetores. Cada vetor da lista sao os coeficientes de uma particao

% Pontos_Total: TODOS os pontos da nuvem. Alguns deles nem sao usados na interpolacao (pois apenas os centros sao usados)
% P_Particoes: Indices de Todos os pontos que compoem a nuvem de cada particao. Alguns deles podem nem ser usados (apenas os centros sao usados)
% Centros_Particoes: Indices dos centros de cada particao. Estes sim sao os pontos que sao usados na interpolacao

function valor = funcao_interp_particao(x, Pontos_Total, P_Particoes, Centros_Particoes, S, T, ...
								alfa_parts, beta_parts, lambda_parts, psi, psi_x, psi_y, psi_z, base_p_parts)
	
	% Quantidade de particoes em cada direcao
	Mx = size(P_Particoes, 1);
	My = size(P_Particoes, 2);
	Mz = size(P_Particoes, 3);

	% Calculando o valor da funcao interpoladora local de cada particao...
	% Aproveitando pra calcular a funcao W de cada particao
	valor_f = zeros(Mx, My, Mz);
	valor_W = zeros(Mx, My, Mz);
	for i_part = 1:Mx
		for j_part = 1:My
			for k_part = 1:Mz


				% Pegando apenas os centros desta particao
				indices_pontos = P_Particoes{i_part, j_part, k_part};
				P_Local = Pontos_Total(indices_pontos, :);
				centros = P_Local(Centros_Particoes{i_part, j_part, k_part}, :);

				% Pegando apenas os coeficientes desta particao
				alfa = alfa_parts{i_part, j_part, k_part};
				beta = beta_parts{i_part, j_part, k_part};
				lambda = lambda_parts{i_part, j_part, k_part};
				base_p = base_p_parts{i_part, j_part, k_part};

				% Ignora particoes vazias que nao tinham nenhum ponto dentro delas
				if( isempty(alfa) )
					continue;
				end
				
				n = size(centros, 1);

				valor = 0.0;
				for( j=1:n )
					dif = x - centros(j, :);
					beta_j = beta( 3*(j-1) + 1 :  3*(j-1) + 3);
					grad_j = [ psi_x(dif), psi_y(dif), psi_z(dif) ];

					valor = valor + alfa(j)*psi(dif) - dot( beta_j, grad_j );
				end

				% Parte do polinomio
				P = x(1).^base_p(:, 1)'.* ...
					x(2).^base_p(:, 2)'.* ...
					x(3).^base_p(:, 3)';

				valor_f(i_part, j_part, k_part) = valor + dot( lambda, P );

				valor_W(i_part, j_part, k_part) = funcao_W(x, i_part, j_part, k_part, S, T);

			end
		end
	end

	soma_W = sum( valor_W(:) );

	valor = dot(valor_f(:), valor_W(:))/soma_W;

end