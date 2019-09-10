function V = suavizacao_vertices(V, F, V_corners, Corner_table, Normais)

	n_vertices = size(V, 1);

	alpha = 1.0;

	textprogressbar('Suavizacao de vertices: ')

	for i = 1:n_vertices

		textprogressbar(100*i/n_vertices);

		verts_anel = anel(i, V, V_corners, Corner_table);
		v = V(i, :);
		b_v = baricentro(verts_anel);
		d_v = b_v - v;
		n_v = Normais(i, :);
		V(i, :) = v + alpha*( d_v - dot(d_v, n_v)*n_v );
	end

	textprogressbar(100);
	textprogressbar('');

end

function vertices = anel(indice_v, V, V_corners, Corner_table)
	vertices = [];

	corners = V_corners{indice_v}; % Pega todos os corners deste vertice
	for i_corner=1:length(corners) % Percorre cada um dos corners
		corner = Corner_table{ corners(i_corner) }; % Obtem a estrutura  deste corner na table 
		prox_corner = Corner_table{ corner.prox }; % Obtem a estrutura do proximo coner na table
		i_v = prox_corner.vert; % Indice do vertice do prox corner
		vertices(end+1, :) = V(i_v, :); % Adiciona o vertice na lista do anel
	end
end

function v = baricentro(verts)
	n = size(verts, 1);
	v = [0 0 0];
	for i=1:n
		v = v + verts(i, :);
	end
	v = v/n;
end