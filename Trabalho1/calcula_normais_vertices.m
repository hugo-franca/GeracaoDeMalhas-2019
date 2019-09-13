function [norms_verts, norms_faces] = calcula_normais_vertices(V, F, V_C, C)

	n_vertices = size(V, 1);

	norms_faces = calcula_normais_faces(V, F);

	textprogressbar('Calculando normais: ');

	% Percorrendo cada vertice
	for i_vertice=1:n_vertices

		textprogressbar( 100*i_vertice/n_vertices );

		% Pegando cada corner deste vertice
		corners = V_C{i_vertice};

		% Percorrendo cada um dos corners, pegando a face dele, e adicionando na media ponderada
		media = 0.0;
		for i_corner=1:length(corners)
			face = F(C{ corners(i_corner) }.tri, :);

			normal_face = norms_faces(C{corners(i_corner)}.tri, :);
			
			
			v1 = V(face(1), :);
			v2 = V(face(2), :);
			v3 = V(face(3), :);

			% Comprimentos do lados do triangulo
			a = norm(v2 - v1);
			b = norm(v3 - v2);
			c = norm(v3 - v1);

			s = 0.5*(a + b + c);
			area = sqrt( s*(s-a)*(s-b)*(s-c) );

			media = media + area*normal_face;
		end
		media = media/norm(media);
		norms_verts(i_vertice, :) = media;
	end

	textprogressbar(100);
	textprogressbar('');

end