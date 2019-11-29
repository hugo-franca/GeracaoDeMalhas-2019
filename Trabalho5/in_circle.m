function resp = in_circle(p, a, b, c)

	vec = [a; c; b; p];

	matriz = [vec, (vec(:, 1).^2 + vec(:, 2).^2), ones(4, 1)];
	
	% Se o det for < 0, o ponto p esta fora de circ([a, b, c])
	if( det(matriz)<0 )
		resp = false;
	else
		resp = true;
	end

end