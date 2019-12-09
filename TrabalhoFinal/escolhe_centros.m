
function centros_parts = escolhe_centros( ...
							qtdCentros, tipo_interpolacao, ...
							Pontos_Total, Normais_Total, Valores_Total, P_Particoes, Grau_P, ...
							k1, k2, ...
							psi, psi_x, psi_y, psi_z, ...
							psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz ...
						)

	
	% Matrizes usadas na maximizacao da funcao_maximizar_HRBF
	global A_max D_max P_max D_2_max G_max P_g_max;

	global A D D_2 G P A_p P_g G_p;

	% Quantidade de particoes em cada direcao
	[Mx, My, Mz] = size(P_Particoes);

	% Cada particao vai ter os seus centros
	centros_parts = cell(Mx, My, Mz);

	qtd_particoes = Mx*My*Mz;
	particao_atual = 0;

	% Para cada particao, vamos encontrar os centros dela
	for i_part = 1:Mx
		for j_part = 1:My
			for k_part = 1:Mz

				particao_atual  = particao_atual + 1;

				A_max = [];
				D_max = [];
				P_max = [];
				D_2_max = [];
				G_max = [];
				P_g_max = [];

				A = [];
				D = [];
				D_2 = [];
				G = [];
				P = [];
				A_p = [];
				P_g = [];
				G_p = [];

				

				% Separando os pontos e normais apenas da particao atual
				indices_pontos = P_Particoes{i_part, j_part, k_part};
				Pontos = Pontos_Total(indices_pontos, :);
				Normais = Normais_Total(indices_pontos, :);
				Valores = Valores_Total(indices_pontos);

				% Quantidade de pontos na nuvem
				n = size(Pontos, 1);

				% Se a qtdCentros for maior que n, retorna toda a nuvem
				texto = ['Calculando os centros da particao ', num2str(particao_atual), '/', num2str(qtd_particoes), ': '];
				textprogressbar(texto);
				if( qtdCentros >= n )
					centros_parts{i_part, j_part, k_part} = [1:n];
					textprogressbar(100);
					textprogressbar('')
					continue;
				end

				% Inicializando o conjunto com um ponto aleatorio
				centros = [1];

				
				for i = 2:qtdCentros

					textprogressbar( 100*i/qtdCentros );

					% Calculando os coeficientes da funcao interpoladora desta iteracao
					if( strcmp(tipo_interpolacao, 'HRBF') )
						[alfa, beta, lambda, base_p] = determina_coeficientes_HRBF( ...
															Pontos(centros, :), Normais(centros, :), Valores(centros), Grau_P, ...
															psi, psi_x, psi_y, psi_z, ...
															psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz, ...
															false ...
														);
					elseif( strcmp(tipo_interpolacao, 'LSHRBF') )
						[alfa, beta, lambda, base_p] = determina_coeficientes_LSHRBF( ...
															Pontos, Normais, Pontos(centros, :), Valores, Grau_P, ...
															psi, psi_x, psi_y, psi_z, ...
															psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz, ...
															false ...
														);
					end


					valor_funcao = funcao_maximizar_HRBF( ...
											Pontos, Normais, k1, k2, ...
											Pontos(centros, :), Grau_P, ...
											psi, psi_x, psi_y, psi_z, ...
											psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz, ...
											alfa, beta, lambda, base_p ...
										);

					% Retirando os centros que ja foram escolhidos 
					valor_funcao(centros) = -1; 

					% Obtendo o ponto que maximiza a funcao
					[maxValor, pontoEscolhido] = max( valor_funcao );				

					% Adiciona o ponto escolhido na lista de centros
					centros(end+1) = pontoEscolhido;
				end
				textprogressbar(100);
				textprogressbar('');


				centros_parts{i_part, j_part, k_part} = centros;


			end % k_part
		end % j_part
	end % i_part
	


end