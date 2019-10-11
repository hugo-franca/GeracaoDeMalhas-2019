function [X, Y, err] = resolve_equacoes(	metodo_edp, metodo_iter, tol, maxIteracoes, X, Y, xi, eta, ...
									xi_i, eta_i, a_param, b_param, c_param, d_param)
	
	disp(['Resolvendo pelo metodo ', metodo_iter, '...']);
	if( strcmp(metodo_iter, 'jacobi') )
		[X, Y, err] = jacobi(metodo_edp, tol, maxIteracoes, X, Y, xi, eta, ...
						xi_i, eta_i, a_param, b_param, c_param, d_param);
	elseif( strcmp(metodo_iter, 'gauss_seidel') )
		[X, Y, err] = gauss_seidel(metodo_edp, tol, maxIteracoes, X, Y, xi, eta, ...
						xi_i, eta_i, a_param, b_param, c_param, d_param);
	elseif( strcmp(metodo_iter, 'sor') )
		[X, Y, err] = SOR(metodo_edp, tol, maxIteracoes, X, Y, xi, eta, ...
						xi_i, eta_i, a_param, b_param, c_param, d_param);
	end

end

function [X, Y, err_vec] = gauss_seidel(	metodo_edp, tol, maxIteracoes, X, Y, xi, eta, ...
						xi_i, eta_i, a_param, b_param, c_param, d_param)
	

	d_xi = xi(2) - xi(1);
	d_eta = eta(2) - eta(1);

	err = inf;
	iter = 0;

	while( (err>tol) && (iter<maxIteracoes) )

		X_ant = X;
		Y_ant = Y;

		% Gauss-seidel etc
		for i=2:length(xi)-1
			for j=2:length(eta)-1

				g11 = ((X(i+1, j) - X(i-1, j))/(2*d_xi)).^2 + ((Y(i+1, j) - Y(i-1, j))/(2*d_xi)).^2; 
				g22 = ((X(i, j+1) - X(i, j-1))/(2*d_eta)).^2 + ((Y(i, j+1) - Y(i, j-1))/(2*d_eta)).^2; 
				g12 = ((X(i+1, j) - X(i-1, j))/(2*d_xi))*((X(i, j+1) - X(i, j-1))/(2*d_eta)) ...
						+ ((Y(i+1, j) - Y(i-1, j))/(2*d_xi))*((Y(i, j+1) - Y(i, j-1))/(2*d_eta));
				g = g11*g22 - g12*g12;


				a = 2*d_eta*d_eta*g22;
				b = d_eta*d_xi*g12;
				c = 2*d_xi*d_xi*g11;

				if( strcmp(metodo_edp, 'winslow') )
					rhs_x = 0.0;
					rhs_y = 0.0;
				elseif( strcmp(metodo_edp, 'ttm') )
					[P, Q] = P_Q(xi(i), eta(j), xi_i, eta_i, a_param, b_param, c_param, d_param);
					rhs_x = g*( ( P*(X(i+1, j) - X(i-1, j))/(2*d_xi) ) + ( Q*(X(i, j+1) - X(i, j-1))/(2*d_eta) ) );
					rhs_y = g*( ( P*(Y(i+1, j) - Y(i-1, j))/(2*d_xi) ) + ( Q*(Y(i, j+1) - Y(i, j-1))/(2*d_eta) ) );
				end

				X(i, j) = -rhs_x*2.0*d_xi*d_xi*d_eta*d_eta + a*(X(i+1, j) + X(i-1, j)) + c*(X(i, j+1)+ X(i, j-1)) ...
						 - b*( X(i+1, j+1) + X(i-1, j-1) - X(i-1, j+1) - X(i+1, j-1) );
				X(i, j) = 0.5*X(i, j)/(a + c);

				Y(i, j) = -rhs_y*2.0*d_xi*d_xi*d_eta*d_eta + a*(Y(i+1, j) + Y(i-1, j)) + c*(Y(i, j+1)+ Y(i, j-1)) ...
						 - b*( Y(i+1, j+1) + Y(i-1, j-1) - Y(i-1, j+1) - Y(i+1, j-1) );
				Y(i, j) = 0.5*Y(i, j)/(a + c);

			end
		end

		e1 = norm(X_ant(:) - X(:));
		e2 = norm(Y_ant(:)- Y(:));
		err = sqrt(e1*e1 + e2*e2);
		iter = iter+1;

		err_vec(iter) = err;

	end


end

function [X, Y, err_vec] = SOR(	metodo_edp, tol, maxIteracoes, X, Y, xi, eta, ...
						xi_i, eta_i, a_param, b_param, c_param, d_param)
	
	
	% Parametro SOR
	omega = 1.2;

	d_xi = xi(2) - xi(1);
	d_eta = eta(2) - eta(1);

	err = inf;
	iter = 0;

	while( (err>tol) && (iter<maxIteracoes) )

		X_ant = X;
		Y_ant = Y;

		% Gauss-seidel etc
		for i=2:length(xi)-1
			for j=2:length(eta)-1

				g11 = ((X(i+1, j) - X(i-1, j))/(2*d_xi)).^2 + ((Y(i+1, j) - Y(i-1, j))/(2*d_xi)).^2; 
				g22 = ((X(i, j+1) - X(i, j-1))/(2*d_eta)).^2 + ((Y(i, j+1) - Y(i, j-1))/(2*d_eta)).^2; 
				g12 = ((X(i+1, j) - X(i-1, j))/(2*d_xi))*((X(i, j+1) - X(i, j-1))/(2*d_eta)) ...
						+ ((Y(i+1, j) - Y(i-1, j))/(2*d_xi))*((Y(i, j+1) - Y(i, j-1))/(2*d_eta));
				g = g11*g22 - g12*g12;


				a = 2*d_eta*d_eta*g22;
				b = d_eta*d_xi*g12;
				c = 2*d_xi*d_xi*g11;

				if( strcmp(metodo_edp, 'winslow') )
					rhs_x = 0.0;
					rhs_y = 0.0;
				elseif( strcmp(metodo_edp, 'ttm') )
					[P, Q] = P_Q(xi(i), eta(j), xi_i, eta_i, a_param, b_param, c_param, d_param);
					rhs_x = g*( ( P*(X(i+1, j) - X(i-1, j))/(2*d_xi) ) + ( Q*(X(i, j+1) - X(i, j-1))/(2*d_eta) ) );
					rhs_y = g*( ( P*(Y(i+1, j) - Y(i-1, j))/(2*d_xi) ) + ( Q*(Y(i, j+1) - Y(i, j-1))/(2*d_eta) ) );
				end

				X(i, j) = (1.0 - omega)*X(i, j) + omega*0.5*( -rhs_x*2.0*d_xi*d_xi*d_eta*d_eta + a*(X(i+1, j) + X(i-1, j)) + c*(X(i, j+1)+ X(i, j-1)) ...
						 - b*( X(i+1, j+1) + X(i-1, j-1) - X(i-1, j+1) - X(i+1, j-1) ) )/(a+c);
				% X(i, j) = 0.5*X(i, j)/(a + c);

				Y(i, j) = (1.0 - omega)*Y(i, j) + omega*0.5*( -rhs_y*2.0*d_xi*d_xi*d_eta*d_eta + a*(Y(i+1, j) + Y(i-1, j)) + c*(Y(i, j+1)+ Y(i, j-1)) ...
						 - b*( Y(i+1, j+1) + Y(i-1, j-1) - Y(i-1, j+1) - Y(i+1, j-1) ) )/(a+c);
				% Y(i, j) = 0.5*Y(i, j)/(a + c);

			end
		end

		e1 = norm(X_ant(:) - X(:));
		e2 = norm(Y_ant(:)- Y(:));
		err = sqrt(e1*e1 + e2*e2);
		iter = iter+1;

		err_vec(iter) = err;

	end


end

function [X, Y, err_vec] = jacobi(metodo_edp, tol, maxIteracoes, X, Y, xi, eta, ...
				xi_i, eta_i, a_param, b_param, c_param, d_param)
	
	d_xi = xi(2) - xi(1);
	d_eta = eta(2) - eta(1);

	err = inf;
	iter = 0;

	while( (err>tol) && (iter<maxIteracoes) )

		X_ant = X;
		Y_ant = Y;

		% Gauss-seidel etc
		for i=2:length(xi)-1
			for j=2:length(eta)-1

				g11 = ((X_ant(i+1, j) - X_ant(i-1, j))/(2*d_xi)).^2 + ((Y_ant(i+1, j) - Y_ant(i-1, j))/(2*d_xi)).^2; 
				g22 = ((X_ant(i, j+1) - X_ant(i, j-1))/(2*d_eta)).^2 + ((Y_ant(i, j+1) - Y_ant(i, j-1))/(2*d_eta)).^2; 
				g12 = ((X_ant(i+1, j) - X_ant(i-1, j))/(2*d_xi))*((X_ant(i, j+1) - X_ant(i, j-1))/(2*d_eta)) ...
						+ ((Y_ant(i+1, j) - Y_ant(i-1, j))/(2*d_xi))*((Y_ant(i, j+1) - Y_ant(i, j-1))/(2*d_eta));
				g = g11*g22 - g12*g12;


				a = 2*d_eta*d_eta*g22;
				b = d_eta*d_xi*g12;
				c = 2*d_xi*d_xi*g11;

				if( strcmp(metodo_edp, 'winslow') )
					rhs_x = 0.0;
					rhs_y = 0.0;
				elseif( strcmp(metodo_edp, 'ttm') )
					[P, Q] = P_Q(xi(i), eta(j), xi_i, eta_i, a_param, b_param, c_param, d_param);
					rhs_x = g*( ( P*(X_ant(i+1, j) - X_ant(i-1, j))/(2*d_xi) ) + ( Q*(X_ant(i, j+1) - X_ant(i, j-1))/(2*d_eta) ) );
					rhs_y = g*( ( P*(Y_ant(i+1, j) - Y_ant(i-1, j))/(2*d_xi) ) + ( Q*(Y_ant(i, j+1) - Y_ant(i, j-1))/(2*d_eta) ) );
				end

				X(i, j) = -rhs_x*2.0*d_xi*d_xi*d_eta*d_eta + a*(X_ant(i+1, j) + X_ant(i-1, j)) + c*(X_ant(i, j+1)+ X_ant(i, j-1)) ...
						 - b*( X_ant(i+1, j+1) + X_ant(i-1, j-1) - X_ant(i-1, j+1) - X_ant(i+1, j-1) );
				X(i, j) = 0.5*X(i, j)/(a + c);

				Y(i, j) = -rhs_y*2.0*d_xi*d_xi*d_eta*d_eta + a*(Y_ant(i+1, j) + Y_ant(i-1, j)) + c*(Y_ant(i, j+1)+ Y_ant(i, j-1)) ...
						 - b*( Y_ant(i+1, j+1) + Y_ant(i-1, j-1) - Y_ant(i-1, j+1) - Y_ant(i+1, j-1) );
				Y(i, j) = 0.5*Y(i, j)/(a + c);

			end
		end

		e1 = norm(X_ant(:) - X(:));
		e2 = norm(Y_ant(:)- Y(:));
		err = sqrt(e1*e1 + e2*e2);
		iter = iter+1;

		err_vec(iter) = err;
	end

end