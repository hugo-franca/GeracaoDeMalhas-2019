function valor = funcao_interp(x, centros, alfa, beta, lambda, psi, psi_x, psi_y, psi_z, base_p)
	
	n_centros = size(centros, 1);
	n_pontos = size(x, 1);

	global A_max D_max P_max;

	% Construindo a matriz A
	j = n_centros;
	for( i=1:n_pontos )
		dif = x(i, :) - centros(j, :);
		A_max(i, j) = psi( dif );
	end

	% Construindo a matriz D
	j = n_centros;
	for( i=1:n_pontos )
		dif = x(i, :) - centros(j, :);
		D_max(i, 3*(j-1) + 1) = psi_x( dif );
		D_max(i, 3*(j-1) + 2) = psi_y( dif );
		D_max(i, 3*(j-1) + 3) = psi_z( dif );
	end

	% Construindo a matriz P
	if( isempty(P_max) )
		N = size(base_p, 1);
		P_max = zeros(n_pontos, N);
		for( i=1:n_pontos )
			x_i = x(i, :);
			for( j=1:N )
				P_max(i, j) = x_i(1)^base_p(j, 1)*x_i(2)^base_p(j, 2)*x_i(3)^base_p(j, 3);
			end
		end
	end

	valor = [A_max, -D_max, P_max]*[alfa; beta; lambda];

end