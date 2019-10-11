function [P, Q] = P_Q(xi_p, eta_p, xi, eta, a, b, c, d)

	xi_dif = xi_p - xi;
	eta_dif = eta_p - eta;
	xi_dif_abs = abs(xi_dif);
	eta_dif_abs = abs(eta_dif);


	P = sum(   a.*( sign(xi_dif) ).*exp( -c.*abs(xi_dif_abs) )   ) + ...
		sum(   b.*( sign(xi_dif) ).*exp( -d.*sqrt(xi_dif.^2 + eta_dif.^2) )   );

	Q = sum(   a.*( sign(eta_dif) ).*exp( -c.*abs(eta_dif_abs) )   ) + ...
		sum(   b.*( sign(eta_dif) ).*exp( -d.*sqrt(xi_dif.^2 + eta_dif.^2) )   );

	if(isnan(P))
		aaaa
	end
end