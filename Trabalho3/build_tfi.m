% Mesh Generation -- SME5827 -- ICMC-USP
% Author: Afonso Paiva -- apneto@icmc.usp.br
% Date: 2019/09/13
%
% Transfinite Interpolation (TFI)
function [X, Y, xi, eta] = build_tfi(m, n, exemplo)


	if( strcmp(exemplo, 'quadrado') )
		xi = [0.0:1.0/m:1.0];
		eta = [0.0:1.0/n:1.0];
		fator = 1.0;
		rB = @(s) (fator*[s, 0.0]);
		rT = @(s) (fator*[s, 1.0]);
		rL = @(s) (fator*[0.0, s]);
		rR = @(s) (fator*[1.0, s]);
	elseif( strcmp(exemplo, 'chevron') )
		xi = [0.0:1.0/m:1.0];
		eta = [0.0:1.0/n:1.0];
		rB = @(s) ([s, -s*(s<=0.5) + (s-1)*(s>0.5)]);
		rT = @(s) ([s, (1-s)*(s<=0.5) + s*(s>0.5)]);
		rL = @(s) ([0.0, s]);
		rR = @(s) ([1.0, s]);
	elseif( strcmp(exemplo, 'swan') )
		xi = [0.0:1.0/m:1.0];
		eta = [0.0:1.0/n:1.0];
		rB = @(s) ([s, 0.0]);
		rT = @(s) ([s, 1-3*s+3*s.^2]);
		rL = @(s) ([0.0, s]);
		rR = @(s) ([1+2*s-2*s.^2, s]);
	elseif( strcmp(exemplo, 'airfoil') )
		[xi, eta] = discretiza_xi_eta_airfoil(m, n);
		rB = @(s) (airfoil_bottom(s));
		rT = @(s) (airfoil_top(s));
		rL = @(s) (airfoil_left(s));
		rR = @(s) (airfoil_left(s)); %Esquerda eh igual direita
	end

	 

	TFI = @(xi, eta)( (1-xi)*rL(eta) + xi*rR(eta) + (1-eta)*rB(xi) + eta*rT(xi)  ...
				- (1-xi)*(1-eta)*rB(0) - (1-xi)*eta*rT(0)  ...
				- xi*(1-eta)*rB(1) - xi*eta*rT(1) );

	for i=1:length(xi)
		for j=1:length(eta)
			result = TFI(xi(i), eta(j));
			X(i, j) = result(1);
			Y(i, j) = result(2);
		end
	end

end

function [xi, eta] = discretiza_xi_eta_airfoil(m, n)
	xMin = -1.0;
	xMax = 1.5;
	yMin = -0.6;
	yMax = 0.6;
	Lx = xMax - xMin;
	Ly = yMax - yMin;

	perimetro = 2*Lx + 2*Ly;

	fracao_dir_cima = 0.5*Ly/perimetro;
	fracao_dir_baixo = 0.5*Ly/perimetro;
	fracao_esquerda = Ly/perimetro;
	fracao_cima = Lx/perimetro;
	fracao_baixo = Lx/perimetro;

	m_dir_cima = round(fracao_dir_cima*m);
	m_dir_baixo = round(fracao_dir_baixo*m);
	m_esquerda = round(fracao_esquerda*m);
	m_cima = round(fracao_cima*m);
	m_baixo = round(fracao_baixo*m);
	total_m = m_dir_cima + m_dir_baixo + m_esquerda + m_cima + m_baixo;
	m_cima = m_cima + m - total_m;

	xi = linspace(0, fracao_dir_cima, m_dir_cima);
	xi = [xi(1:end-1), linspace(fracao_dir_cima, fracao_cima + fracao_dir_cima, m_cima+1)];
	xi = [xi(1:end-1), linspace(fracao_dir_cima + fracao_cima, fracao_dir_cima + fracao_cima + fracao_esquerda, m_esquerda+1)];
	xi = [xi(1:end-1), linspace(fracao_dir_cima + fracao_cima + fracao_esquerda, ...
								fracao_dir_cima + fracao_cima + fracao_esquerda + fracao_baixo, m_baixo+1)];
	xi = [xi(1:end-1), linspace(fracao_dir_cima + fracao_cima + fracao_esquerda + fracao_baixo, ...
								fracao_dir_cima + fracao_cima + fracao_esquerda + fracao_baixo + fracao_dir_baixo, m_dir_baixo+1)];

	eta = linspace(0.0, 1.0, n);
end

function resp = airfoil_left(s)
	xMax = 1.5;
	x_inicio_airfoil = 1.0;

	Lx = xMax - x_inicio_airfoil;

	resp = [xMax - s*Lx, 0.0];
end

function resp = airfoil_top(s)

	if( s==0 || s==1 )
		resp = [1.0, 0.0];
		return;
	end

	inverteu = false;
	if( s > 0.5 )
		s = 1.0 - s;
		inverteu = true;
	end

	t = 0.15;

	s = 1.0 - 2.0*s;
	resp(1) = s;
	if( inverteu )
		resp(2) = - 5.0*t*( 0.2969*sqrt(s) - 0.1260*s - 0.3516*s.^2 + 0.2843*s.^3 - 0.1015*s.^4 );
	else
		resp(2) = 5.0*t*( 0.2969*sqrt(s) - 0.1260*s - 0.3516*s.^2 + 0.2843*s.^3 - 0.1015*s.^4 );
	end

end

function resp = airfoil_bottom(s)

	xMin = -1.0;
	xMax = 1.5;
	yMin = -0.6;
	yMax = 0.6;

	Lx = xMax - xMin;
	Ly = yMax - yMin;

	perimetro = 2*Lx + 2*Ly;

	fracao_dir_cima = 0.5*Ly/perimetro;
	fracao_dir_baixo = 0.5*Ly/perimetro;
	fracao_esquerda = Ly/perimetro;
	fracao_cima = Lx/perimetro;
	fracao_baixo = Lx/perimetro;

	if( s <= fracao_dir_cima )
		s = s/fracao_dir_cima;
		resp = [xMax, yMax*s];
	elseif( s <= fracao_cima + fracao_dir_cima )
		s = (s-fracao_dir_cima)/fracao_cima;
		resp = [xMax - s*Lx, yMax];
	elseif( s <= fracao_esquerda + fracao_cima + fracao_dir_cima )
		s = (s - fracao_cima - fracao_dir_cima)/fracao_esquerda;
		resp = [xMin, yMax - s*Ly];
	elseif( s <= fracao_baixo + fracao_esquerda + fracao_cima + fracao_dir_cima )
		s = (s - fracao_esquerda - fracao_cima - fracao_dir_cima)/fracao_baixo;
		resp = [xMin + s*Lx, yMin];
	else
		s = (s - fracao_baixo - fracao_esquerda - fracao_cima - fracao_dir_cima)/fracao_dir_baixo;
		resp = [xMax, yMin + 0.5*s*Ly];
	end

	
end