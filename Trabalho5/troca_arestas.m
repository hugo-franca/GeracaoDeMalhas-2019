% corner cuja aresta oposta sera trocada (se necessario)

function troca_arestas(p, a, b)

	% Vou deixar isto como variavel global pra poder usar direito a recursao...
	global xy_rec T_rec lista_arestas;

	plota_figura(xy_rec, T_rec, [], [a, b], false, 'Verificando se esta aresta (amarela) \''e Delaunay');

	% Construindo a corner table da malha
	[v_corners, corners] = constroi_cornertable(xy_rec, T_rec);

	% Obtem todos os corners do vertice p
	corners_p = v_corners{p};

	% Encontra qual corner de p pertence ao triangulo [p, a, b]
	for i=1:length(corners_p)
		c = corners{ corners_p(i) };
		c_prox = corners{c.prox};
		c_ant = corners{c_prox.prox};

		if( c_prox.vert==a && c_ant.vert==b )
			break;
		elseif( c_prox.vert==b && c_ant.vert==a )
			break;
		end
	end


	% Se este corner nao possui um oposto, isto significa que esta aresta esta no contorno
	% Nao preciso fazer nada neste caso
	if( c.oposto==-1 )
		return;
	end


	% Obtendo o corner oposto ao p
	c_oposto = corners{c.oposto};

	% Obtendo o proximo corner do c e o corner anterior do c
	c_prox = corners{c.prox};
	c_ant = corners{c_prox.prox};

	% Obtendo os tres vertices [a, b, p] do triangulo deste corner
	% Nota: p eh o vertice do corner. [a, b] sao os vertices da aresta a ser trocada
	p = c.vert;
	a = c_prox.vert;
	b = c_ant.vert;

	% Obtendo o vertice oposto p2, que forma o triangulo [a, p2, b]
	p2 = c_oposto.vert;

	% Obtendo as coordenadas destes 4 vertices p, a, b, c
	xy_p = xy_rec(p, :);
	xy_a = xy_rec(a, :);
	xy_b = xy_rec(b, :);
	xy_p2 = xy_rec(p2, :);

	% Usa o teste in_circle para ver se precisa trocar a aresta [a, b]
	incircle = in_circle(xy_p, xy_a, xy_b, xy_p2);

	% Se o teste for verdadeiro, vamos trocar a aresta
	if( incircle==true )

		plota_figura(xy_rec, T_rec, [], [a, b], true, 'A aresta N\~AO \''e Delaunay!!!!');

		% Obtem os dois triangulos que serao removidos e remove eles
		tri_1_antigo = c.tri;
		tri_2_antigo = c_oposto.tri;

		% Cria os dois novos triangulos e insere eles na lista
		tri_1 = [a, p2, p];
		tri_2 = [p2, b, p];
		T_rec(tri_1_antigo, :) = tri_1;
		T_rec(tri_2_antigo, :) = tri_2;

		% Plota a nova malha
		plota_figura(xy_rec, T_rec, [], [], false, 'A aresta foi invertida');

		% Adicionando as arestas que serao chamadas em seguida na lista pra plotar a figura
		lista_arestas(end+1, :) = [p2, b];
		lista_arestas(end+1, :) = [b, p];
		lista_arestas(end+1, :) = [a, p2];
		lista_arestas(end+1, :) = [p, a];

		% Chamada recursiva nas 4 arestas ao redor dos 2 novos triangulos
		troca_arestas( p, p2, b );
		troca_arestas( p2, b, p );
		troca_arestas( p, a, p2 );
		troca_arestas( p2, p, a );
	else
		% Ela eh delaunay
		plota_figura(xy_rec, T_rec, [], [], false, 'A aresta j\''a \''e Delaunay. Nenhum problema');
	end


end