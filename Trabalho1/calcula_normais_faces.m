function [f_normais] = calcula_normais_faces(V, F)

	num_faces = size(F, 1);

	f_normais = zeros(size(F)); 
	
	% Para cada face
	for( i=1:num_faces )

		% Vertices desta face
		v1 = V(F(i, 1), :);
		v2 = V(F(i, 2), :);
		v3 = V(F(i, 3), :);

		% Vetores da face
		a = v2 - v1;
		b = v3 - v2;
		c = v1 - v3;

		% Regra da mao direita
		n = cross(b-a, c-a);
		f_normais(i, :) = n/norm(n);

	end

end