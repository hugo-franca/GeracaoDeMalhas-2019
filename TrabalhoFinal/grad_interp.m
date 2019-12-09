function valor = grad_interp(x, centros, alfa, beta, lambda, grad_psi, H_psi, base_p)
	
	global D_2_max G_max P_g_max;

	n_pontos = size(x, 1);
	n_centros = size(centros, 1);


	% Construindo a matriz D_2 (apenas as ultimas colunas, relativas ao ultimo centro)
	for( i=1:n_pontos )
		j = n_centros;
		dif = x(i, :) - centros(j, :);
		D_2_max(3*(i-1) + 1:3*(i-1) + 3, j) = grad_psi( dif );
	end

	% Apenas adicionando as colunas do ultimo centro
	for( i=1:n_pontos )
		j = n_centros;
		dif = x(i, :) - centros(j, :);

		if( norm(dif)<1e-10 )
			H = zeros(3, 3);
		else
			H = H_psi(dif);
		end

		G_max(3*(i-1) + 1:3*(i-1) + 3, 3*(j-1) + 1:3*(j-1) + 3) = H;
	end


	
	% Construindo a matriz P_g (soh precisa uma vez, pois ela nao depende dos centros...)
	if( isempty(P_g_max) )
		N = size(base_p, 1);
		for( i=1:n_pontos )
			for( j=1:N )
				p_j = base_p(j, :);

				% Tirando uns bugs que daria divisao por zero...
				if( p_j(1)==0 )
					parte_x = 0.0;
				else
					parte_x = p_j(1)*x(i, 1)^(p_j(1) - 1);
				end
				if( p_j(2)==0 )
					parte_y = 0.0;
				else
					parte_y = p_j(2)*x(i, 2)^(p_j(2) - 1);
				end
				if( p_j(3)==0 )
					parte_z = 0.0;
				else
					parte_z = p_j(3)*x(i, 3)^(p_j(3) - 1);
				end

				P_g_max(3*(i-1) + 1, j) = parte_x*( x(i, 2)^p_j(2) )*( x(i, 3)^p_j(3) );
				P_g_max(3*(i-1) + 2, j) = parte_y*( x(i, 1)^p_j(1) )*( x(i, 3)^p_j(3) );
				P_g_max(3*(i-1) + 3, j) = parte_z*( x(i, 2)^p_j(2) )*( x(i, 1)^p_j(1) );
			end
		end
	end

	valor = [D_2_max, -G_max, P_g_max]*[alfa; beta; lambda];
	valor = reshape(valor, 3, n_pontos)';





	% % Versao escalar
	% n = size(centros, 1);

	% valor = 0.0;
	% for( j=1:n )
	% 	dif = x - centros(j, :);
	% 	beta_j = beta( 3*(j-1) + 1 :  3*(j-1) + 3);

	% 	if( norm(dif)<1e-10 )
	% 		hessiana = 0.0;
	% 	else
	% 		hessiana = H_psi(dif);
	% 	end
		

	% 	valor = valor + alfa(j)*grad_psi(dif) - hessiana*beta_j;
	% end

	% % Parte do polinomio
	% N = length(lambda);
	% for( j=1:N )
	% 	p_j = base_p(j, :);

	% 	% Tirando uns bugs que daria divisao por zero...
	% 	if( p_j(1)==0 )
	% 		parte_x = 0.0;
	% 	else
	% 		parte_x = p_j(1)*x(1)^(p_j(1) - 1);
	% 	end
	% 	if( p_j(2)==0 )
	% 		parte_y = 0.0;
	% 	else
	% 		parte_y = p_j(2)*x(2)^(p_j(2) - 1);
	% 	end
	% 	if( p_j(3)==0 )
	% 		parte_z = 0.0;
	% 	else
	% 		parte_z = p_j(3)*x(3)^(p_j(3) - 1);
	% 	end

	% 	dpdx = parte_x*( x(2)^p_j(2) )*( x(3)^p_j(3) );
	% 	dpdy = parte_y*( x(1)^p_j(1) )*( x(3)^p_j(3) );
	% 	dpdz = parte_z*( x(2)^p_j(2) )*( x(1)^p_j(1) );

	% 	valor = valor + lambda(j)*[ dpdx; dpdy; dpdz ];
	% end

end