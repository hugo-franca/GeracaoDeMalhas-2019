% p: ponto de entrada. Deseja-se encontrar o triangulo que contem este ponto
% xy: coordenadas dos pontso da malha
% T: Triangulos da malha

function i_tri = encontra_triangulo(p, xy, T)

	p = p';

	% Quantidade de triangulos
	n_triangulos = size(T, 1);

	% Percorre cada triangulo e encontra qual contem p
	for( i_tri=1:n_triangulos )

		% Pegando os tres pontos deste triangulo
		p0 = xy(T(i_tri, 1), :)';
		p1 = xy(T(i_tri, 2), :)';
		p2 = xy(T(i_tri, 3), :)';

		% Calculando s e t para obter as coordenadas baricentricas
		sol = [p1-p0, p2-p0]\( p-p0 );
		s = sol(1);
		t = sol(2);

		% Encontrou o triangulo
		if( s>=0 && s<=1 && t>=0 && t<=1 && ((s+t)<=1) )
			return;
		end

	end

	% Nao encontrou nenhum triangulo
	i_tri = -1;

end