function razoes = calcula_razoes_aspecto(V, F)

	razoes = zeros(size(F, 1), 1);


	% Para cada face...
	for i=1:size(F, 1)

		face = F(i, :);

		v1 = V(face(1), :);
		v2 = V(face(2), :);
		v3 = V(face(3), :);

		% Comprimentos do lados do triangulo
		a = norm(v2 - v1);
		b = norm(v3 - v2);
		c = norm(v3 - v1);

		s = 0.5*(a + b + c);
		area = sqrt( s*(s-a)*(s-b)*(s-c) );
		razoes(i) = 4*sqrt(3)*area/(a^2 + b^2 + c^2);

	end

end