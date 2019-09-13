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

function v = baricentro(verts)
	n = size(verts, 1);
	v = [0 0 0];
	for i=1:n
		v = v + verts(i, :);
	end
	v = v/n;
end