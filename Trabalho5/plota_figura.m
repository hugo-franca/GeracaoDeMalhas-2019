function plota_figura(P, T, novo_ponto, aresta_atual, aresta_ruim, titulo_imagem)
	global indice_imagem lista_arestas ampliar_imagem escrever_arquivos mostrar_imagem;

	if( ~mostrar_imagem )
		fig = figure('visible', 'off');
	else
		fig = figure();
	end

	
	hold on;
	triplot(T, P(:, 1), P(:, 2))
	% scatter(P(:, 1), P(:, 2), 15, 'b', 'filled')
	title(titulo_imagem, 'Interpreter','latex');

	% parametros para visualizacao no primeiro exemplo
	if( ~isempty(ampliar_imagem) )
		xlim(ampliar_imagem(1, :));
		ylim(ampliar_imagem(2, :));
	end

	if( ~isempty(lista_arestas) )
		for( i=1:size(lista_arestas, 1) )
			aresta = lista_arestas(i, :);
			plot(P(aresta, 1), P(aresta, 2), 'g', 'LineWidth', 1.0);
		end
	end

	if( ~isempty(aresta_atual) )
		if( aresta_ruim )
			plot(P(aresta_atual, 1), P(aresta_atual, 2), 'r', 'LineWidth', 1.0);
		else
			plot(P(aresta_atual, 1), P(aresta_atual, 2), 'y', 'LineWidth', 1.0);
		end

		posicao = find( ismember(lista_arestas, aresta_atual, 'rows')==true );
		lista_arestas(posicao, :) = [];
	end

	if( ~isempty(novo_ponto) )
		scatter(novo_ponto(:, 1), novo_ponto(:, 2), 15, 'r', 'filled');
	end

	if( escrever_arquivos && ~mostrar_imagem )
		nome_arq = ['imagens/passo_', num2str(indice_imagem), '.png'];
		saveas(fig, nome_arq);
		indice_imagem = indice_imagem + 1;
	end

	
end