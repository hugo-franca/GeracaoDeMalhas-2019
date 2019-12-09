function resp = funcao_maximizar_HRBF( ...
							x, normal, k1, k2, ...
							Pontos, Grau_P, ...
							psi, psi_x, psi_y, psi_z, ...
							psi_xx, psi_xy, psi_xz, psi_yy, psi_yz, psi_zz, ...
							alfa, beta, lambda, base_p ...
						)

	% Defininando a matriz hessiana de psi
	H_psi = @(x) ...
	( [...
		psi_xx(x), psi_xy(x), psi_xz(x);
		psi_xy(x), psi_yy(x), psi_yz(x);
		psi_xz(x), psi_yz(x), psi_zz(x)
	]);

	% Definindo o gradiente de psi
	grad_psi = @(x)( [ psi_x(x); psi_y(x); psi_z(x) ] );

	% Valor da funcao interpoladora no ponto x
	valor_f = funcao_interp(x, Pontos, alfa, beta, lambda, psi, psi_x, psi_y, psi_z, base_p);	

	% Valor do gradiente da funcao interpoladora no ponto x
	valor_grad = grad_interp(x, Pontos, alfa, beta, lambda, grad_psi, H_psi, base_p);

	% Calculando a distancia entre x e cada centro. Pegando a menor delas
	distancias = pdist2( x, Pontos );
	n_pontos = size(x, 1);
	distancias = [distancias, Inf*ones(n_pontos, 1)];
	dist_minima = min( distancias' );

	% Montando o vetor de quatro elementos
	vec = [k1*valor_f, k2*(valor_grad - normal)];

	% Finalmente, Calculando o valor da funcao

	% Usar isso no matlab velho que nao tem vecnorm
	vec = vec';
	normas = zeros(1, size(vec, 2));
	for coluna=1:size(vec, 2)
		normas(coluna) = norm( vec(:, coluna) );
	end
	resp = normas.*dist_minima;

	% Usar isso no matlab novo
	% resp = vecnorm(vec').*dist_minima;

end