function [V_tri, F_tri] = marching_tetrahedra(X, Y, Z, F)

	V_tri = [];
	F_tri = [];

	% Dimensoes
	Nx = size(X, 1);
	Ny = size(X, 2);
	Nz = size(X, 3);

	% Dados dois pontos v0, v1 e a funcao f aplicada neles, retorna o ponto entre v0, v1 em que f se anula
	% Supoe-se que f eh linear entre estes pontos
	zero_interp_lin = @(v0, v1, f0, f1)( v0 + (v1 - v0)*(f0/(f0-f1)) );

	% Esta tabela abaixo eh usada pra nao criar vertices repetidos na interface
	% imagine um vertice V e um outro V2 (do grid retangular meshgrid)
	% Se ja tiver calculado um ponto P sobre a reta [V, V2], eu vou indicar isso na posicao (V, V2) da tabela
	% Observe que eu tenho uma indexacao de V (do grid retangular) pra posicao da tabela
	pos_tabela = @(i, j, k)( (i-1)*Ny*Nz + (j-1)*Nz + k );
	tabela = sparse(Nx*Ny*Nz, Nx*Ny*Nz);

	textprogressbar('Executando Marching Tetrahedra: ');

	% Para cada um dos cubos...
	for i = 1:Nx-1
		
		textprogressbar( 100*i/Nx );

		for j = 1:Ny-1
			for k = 1:Nz-1

				% Separando os oito vertices deste cubo, apenas pra facilitar o entendimento (continua nao muito facil...)
				v{1} = [i j k];
				v{2} = [i+1 j k];
				v{3} = [i+1 j k+1];
				v{4} = [i j k+1];

				v{5} = [i j+1 k];
				v{6} = [i+1 j+1 k];
				v{7} = [i+1 j+1 k+1];
				v{8} = [i j+1 k+1];

				% Criando os 6 tetrahedros desse cubo pelo algoritmo CFK
				tetras = triangulacao_CFK(1, 2, 3, 4, 5, 6, 7, 8);

				% Para cada um dos 6 tetrahedros...
				for indice_tetra = 1:6
					t = tetras{indice_tetra};
					
					% Valor da funcao em cada um dos 4 vertices desse tetrahedro
					f(1) = F(v{t(1)}(1), v{t(1)}(2), v{t(1)}(3));
					f(2) = F(v{t(2)}(1), v{t(2)}(2), v{t(2)}(3));
					f(3) = F(v{t(3)}(1), v{t(3)}(2), v{t(3)}(3));
					f(4) = F(v{t(4)}(1), v{t(4)}(2), v{t(4)}(3));

					% Contando quantos valores positivos foram encontrados
					qtd_positivos = sum( f>0 );

					% Nao faz aboslutamente nada nesses casos
					if( qtd_positivos==0 || qtd_positivos==4 )
						continue;
					end

					% Coordenadas destes quatro vertices do tetrahedro
					v_tetra{1} = [	X(v{t(1)}(1), v{t(1)}(2), v{t(1)}(3)), Y(v{t(1)}(1), v{t(1)}(2), v{t(1)}(3)), Z(v{t(1)}(1), v{t(1)}(2), v{t(1)}(3)) ];
					v_tetra{2} = [	X(v{t(2)}(1), v{t(2)}(2), v{t(2)}(3)), Y(v{t(2)}(1), v{t(2)}(2), v{t(2)}(3)), Z(v{t(2)}(1), v{t(2)}(2), v{t(2)}(3)) ];
					v_tetra{3} = [	X(v{t(3)}(1), v{t(3)}(2), v{t(3)}(3)), Y(v{t(3)}(1), v{t(3)}(2), v{t(3)}(3)), Z(v{t(3)}(1), v{t(3)}(2), v{t(3)}(3)) ];
					v_tetra{4} = [	X(v{t(4)}(1), v{t(4)}(2), v{t(4)}(3)), Y(v{t(4)}(1), v{t(4)}(2), v{t(4)}(3)), Z(v{t(4)}(1), v{t(4)}(2), v{t(4)}(3)) ];

					% Indice dos quatro vertices na tabela usada pra evitar repeticoes
					ind_v_tetra(1) = pos_tabela(v{t(1)}(1), v{t(1)}(2), v{t(1)}(3));
					ind_v_tetra(2) = pos_tabela(v{t(2)}(1), v{t(2)}(2), v{t(2)}(3));
					ind_v_tetra(3) = pos_tabela(v{t(3)}(1), v{t(3)}(2), v{t(3)}(3));
					ind_v_tetra(4) = pos_tabela(v{t(4)}(1), v{t(4)}(2), v{t(4)}(3));

					% CASO 1: UM PONTO POSITIVO E 3 NEGATIVOS (OU O CONTRARIO)
					if( qtd_positivos==1 || qtd_positivos==3 )

						% Encontra qual dos vertices eh o positivo
						indice_positivo = find( f>0 );
						indices_negativos = find( f<=0 );
						indice_direcao = indice_positivo;

						% Se tiver no caso qtd_positivos==3, vou inverter os indices...
						if( qtd_positivos==3 )
							temp = indice_positivo;
							indice_positivo = indices_negativos;
							indices_negativos = temp;
							indice_direcao = indices_negativos(1);
						end

						% Bom, nesse caso vamos criar um triangulo. Portanto temos que obter 3 pontos p1, p2, p3

						% Se p1 ainda nao foi inserido na tabela (em alguma iteracao anterior...), vamos inseri-lo!
						posicao = tabela(ind_v_tetra(indice_positivo), ind_v_tetra(indices_negativos(1)));
						if( posicao==0 )
							p1 = zero_interp_lin(v_tetra{indice_positivo}, v_tetra{indices_negativos(1)}, f(indice_positivo), f(indices_negativos(1)) );
							V_tri(end+1, :) = p1;
							indice_p1 = size(V_tri, 1);
							tabela(ind_v_tetra(indice_positivo), ind_v_tetra(indices_negativos(1))) = indice_p1;
							tabela(ind_v_tetra(indices_negativos(1)), ind_v_tetra(indice_positivo)) = indice_p1;
						else
							p1 = V_tri(posicao, :);
							indice_p1 = posicao;
						end

						% Se p2 ainda nao foi inserido na tabela (em alguma iteracao anterior...), vamos inseri-lo!
						posicao = tabela(ind_v_tetra(indice_positivo), ind_v_tetra(indices_negativos(2)));
						if( posicao==0 )
							p2 = zero_interp_lin(v_tetra{indice_positivo}, v_tetra{indices_negativos(2)}, f(indice_positivo), f(indices_negativos(2)) );
							V_tri(end+1, :) = p2;
							indice_p2 = size(V_tri, 1);
							tabela(ind_v_tetra(indice_positivo), ind_v_tetra(indices_negativos(2))) = indice_p2;
							tabela(ind_v_tetra(indices_negativos(2)), ind_v_tetra(indice_positivo)) = indice_p2;
						else
							p2 = V_tri(posicao, :);
							indice_p2 = posicao;
						end

						% Se p3 ainda nao foi inserido na tabela (em alguma iteracao anterior...), vamos inseri-lo!
						posicao = tabela(ind_v_tetra(indice_positivo), ind_v_tetra(indices_negativos(3)));
						if( posicao==0 )
							p3 = zero_interp_lin(v_tetra{indice_positivo}, v_tetra{indices_negativos(3)}, f(indice_positivo), f(indices_negativos(3)) );
							V_tri(end+1, :) = p3;
							indice_p3 = size(V_tri, 1);
							tabela(ind_v_tetra(indice_positivo), ind_v_tetra(indices_negativos(3))) = indice_p3;
							tabela(ind_v_tetra(indices_negativos(3)), ind_v_tetra(indice_positivo)) = indice_p3;
						else
							p3 = V_tri(posicao, :);
							indice_p3 = posicao;
						end



						% Consertando a orientacao dos pontos, se necessario (pra ficar antihorario)
						% A normal, pela regra da mao direita, vai apontar sempre pro lado positivo da funcao implicita
						cross_prod = cross(p2-p1, p3-p1);
						p_direcao = v_tetra{indice_direcao}; 
						direcao = p_direcao - p1;
						if( dot(cross_prod, direcao) < 0 )
							temp = p2;
							p2 = p3;
							p3 = temp;

							temp = indice_p2;
							indice_p2 = indice_p3;
							indice_p3 = temp;
						end
						
						% Cria uma nova face para a superficie com p1, p2, p3
						F_tri(end+1, :) = [indice_p1 indice_p2 indice_p3];

					% CASO 2: TEM DOIS VALORES POSITIVOS E DOIS NEGATIVOS
					elseif( qtd_positivos==2 )

						% Encontra quais dos vertices sao os positivos
						indices_positivos = find( f>0 );
						indices_negativos = find( f<=0 );
						indice_direcao = indices_positivos(1);

						
						% Bom, nesse caso vamos criar dois triangulos, a partir de um quadrilatero
						% Portanto temos que obter 4 pontos p1, p2, p3, p4

						% Se p1 ainda nao foi inserido na tabela (em alguma iteracao anterior...), vamos inseri-lo!
						posicao = tabela(ind_v_tetra(indices_positivos(1)), ind_v_tetra(indices_negativos(1)));
						if( posicao==0 )
							p1 = zero_interp_lin(v_tetra{indices_positivos(1)}, v_tetra{indices_negativos(1)}, f(indices_positivos(1)), f(indices_negativos(1)) );
							V_tri(end+1, :) = p1;
							indice_p1 = size(V_tri, 1);
							tabela(ind_v_tetra(indices_positivos(1)), ind_v_tetra(indices_negativos(1))) = indice_p1;
							tabela(ind_v_tetra(indices_negativos(1)), ind_v_tetra(indices_positivos(1))) = indice_p1;
						else
							p1 = V_tri(posicao, :);
							indice_p1 = posicao;
						end

						% Se p2 ainda nao foi inserido na tabela (em alguma iteracao anterior...), vamos inseri-lo!
						posicao = tabela(ind_v_tetra(indices_positivos(2)), ind_v_tetra(indices_negativos(1)));
						if( posicao==0 )
							p2 = zero_interp_lin(v_tetra{indices_positivos(2)}, v_tetra{indices_negativos(1)}, f(indices_positivos(2)), f(indices_negativos(1)) );
							V_tri(end+1, :) = p2;
							indice_p2 = size(V_tri, 1);
							tabela(ind_v_tetra(indices_positivos(2)), ind_v_tetra(indices_negativos(1))) = indice_p2;
							tabela(ind_v_tetra(indices_negativos(1)), ind_v_tetra(indices_positivos(2))) = indice_p2;
						else
							p2 = V_tri(posicao, :);
							indice_p2 = posicao;
						end

						% Se p3 ainda nao foi inserido na tabela (em alguma iteracao anterior...), vamos inseri-lo!
						posicao = tabela(ind_v_tetra(indices_positivos(2)), ind_v_tetra(indices_negativos(2)));
						if( posicao==0 )
							p3 = zero_interp_lin(v_tetra{indices_positivos(2)}, v_tetra{indices_negativos(2)}, f(indices_positivos(2)), f(indices_negativos(2)) );
							V_tri(end+1, :) = p3;
							indice_p3 = size(V_tri, 1);
							tabela(ind_v_tetra(indices_positivos(2)), ind_v_tetra(indices_negativos(2))) = indice_p3;
							tabela(ind_v_tetra(indices_negativos(2)), ind_v_tetra(indices_positivos(2))) = indice_p3;
						else
							p3 = V_tri(posicao, :);
							indice_p3 = posicao;
						end

						% Se p4 ainda nao foi inserido na tabela (em alguma iteracao anterior...), vamos inseri-lo!
						posicao = tabela(ind_v_tetra(indices_positivos(1)), ind_v_tetra(indices_negativos(2)));
						if( posicao==0 )
							p4 = zero_interp_lin(v_tetra{indices_positivos(1)}, v_tetra{indices_negativos(2)}, f(indices_positivos(1)), f(indices_negativos(2)) );
							V_tri(end+1, :) = p4;
							indice_p4 = size(V_tri, 1);
							tabela(ind_v_tetra(indices_positivos(1)), ind_v_tetra(indices_negativos(2))) = indice_p4;
							tabela(ind_v_tetra(indices_negativos(2)), ind_v_tetra(indices_positivos(1))) = indice_p4;
						else
							p4 = V_tri(posicao, :);
							indice_p4 = posicao;
						end


						% Consertando a orientacao, se necessario (pra ficar anti-horario)
						cross_prod = cross(p2-p1, p3-p1);
						p_direcao = v_tetra{indice_direcao}; 
						direcao = p_direcao - p1;
						if( dot(cross_prod, direcao) < 0 )
							temp = p2;
							p2 = p4;
							p4 = temp;

							temp = indice_p2;
							indice_p2 = indice_p4;
							indice_p4 = temp;
						end

						% Adicionando duas novas faces
						% Face 1: [p1 p2 p3]
						F_tri(end+1, :) = [indice_p1 indice_p2 indice_p3];
						% Face 2: [p3 p4 p1]
						F_tri(end+1, :) = [indice_p3 indice_p4 indice_p1];

					end



				end
			end
		end
	end

	textprogressbar(100);
	textprogressbar('');

end