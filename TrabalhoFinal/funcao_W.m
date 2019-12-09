function resp = funcao_W(x, i, j, k, S_parts, T_parts)

	S = S_parts{i, j, k};
	T = T_parts{i, j, k};

	% Verifica se o ponto esta dentro desta particao
	% Se nao tiver, ja retorna zero
	if( find( (x < S)==1 ) )
		resp = 0.0;
		return;
	end

	% Se o ponto for "maior" que este T, nao esta no cubo
	if( find( (x > T)==1 ) )
		resp = 0.0;
		return;
	end


	d = 1.0 - prod( (x - S).*(T - x)./( 0.5*(T-S).^2 ) );

	resp = - 6*d^5 + 15*d^4 - 10*d^3 + 1;

end