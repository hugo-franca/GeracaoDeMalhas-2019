function [f, intervalo_x, intervalo_y, intervalo_z] = exemplos(nome_exemplo, t)

	if( strcmp(nome_exemplo, 'esfera') )
		intervalo_x = [-2 2];
		intervalo_y = [-2 2];
		intervalo_z = [-2 2];
		f = @(x, y, z)( x.^2 + y.^2 + z.^2 - 1);
	elseif( strcmp(nome_exemplo, 'torus') )
		R = 40; % distancia do centro do tubo ao centro do torus
		a = 15; % raio do tubo
		intervalo_x = [-65 65];
		intervalo_y = [-65 65];
		intervalo_z = [-65 65];
		f = @(x, y, z)( (x.^2 + y.^2 + z.^2 + R^2 - a^2).^2 - 4*R*R*(x.^2 + y.^2) );
	elseif( strcmp(nome_exemplo, 'genus-2') )
		intervalo_x = [-2 2];
		intervalo_y = [-2 2];
		intervalo_z = [-2 2];
		f = @(x, y, z)( 2*y.*(y.^2 - 3*x.^2).*(1 - z.^2) + (x.^2 + y.^2).^2 - (9*z.^2 - 1).*(1 - z.^2) );
	elseif( strcmp(nome_exemplo, 'triple-torus') )
		R = 1; % distancia do centro do tubo ao centro do torus
		a = 0.2; % raio do tubo
		r = 0.01;
		intervalo_x = [-1.5 1.5];
		intervalo_y = [-1.5 1.5];
		intervalo_z = [-1.5 1.5];
		f1 = @(x, y, z)( (x.^2 + y.^2 + z.^2 + R^2 - a^2).^2 - 4*R*R*(x.^2 + y.^2) );
		f2 = @(x, y, z)( (x.^2 + y.^2 + z.^2 + R^2 - a^2).^2 - 4*R*R*(x.^2 + z.^2) );
		f3 = @(x, y, z)( (x.^2 + y.^2 + z.^2 + R^2 - a^2).^2 - 4*R*R*(y.^2 + z.^2) );
		f = @(x, y, z)( f1(x, y, z).*f2(x, y, z).*f3(x, y, z) - r );
	elseif( strcmp(nome_exemplo, 'calice-vinho') )
		intervalo_x = [-3 3];
		intervalo_y = [-3 3];
		intervalo_z = [-3 7];
		f = @(x, y, z)(x.^2 + y.^2 - log(z + 3.2).^2 - 0.02);
	elseif( strcmp(nome_exemplo, 'interlocked-torus') )
		intervalo_x = [-5 5];
		intervalo_y = [-5 5];
		intervalo_z = [-2 2];
        f = @(x, y, z)( funcao_interlocked_torus(x, y, z) );
	elseif( strcmp(nome_exemplo, 'falling-drop') )
		intervalo_x = [-20 20];
		intervalo_y = [-20 20];
		intervalo_z = [-1 50];
		f = @(x, y, z)( ((z-6*(1-cos(sqrt(x.^2+y.^2)-t*2*pi))./sqrt(x.^2+y.^2+4)).*(2*(x.^2+y.^2)+(z-40*sin((t+0.19)*pi)+1).^2-10)-1000) );
	end

	

	return;
end

function resp = funcao_interlocked_torus(x, y, z)	
    resp = funcao_helix(sqrt(x.*x + y.*y)-3, 2*atan2(y,x), z);
end

function helix = funcao_helix(x, y, z)

	A=4;
	B=1;
	C=0.5;
	D=1;
	E=1;
	% F=1;
	% G=30;

	r = sqrt(x.*x + z.*z);
    x( find( x==0 & z==0 ) ) = 0.001;
    th_0 = atan2(z, x);
    th_1 = mod( (th_0*A + y*B*A), (2*pi));
    th_1( find(th_1<0) ) = th_1(find(th_1<0)) + 2*pi;
    z=(th_1-pi)/E/(B*A);
    x = r - D;

    % if( ~(F==1|G==0) )
    % 	z = x*sin(G*pi/180)+z*cos(G*pi/180);
    % end

    % if( ~(F==1|G==0) )
    % 	x = x*cos(G*pi/180) - z*sin(G*pi/180);
    % end

    % r2 = z;
    % if( F==1 )
    	r2 = sqrt( x.*x + z.*z );
    % elseif( F~=0 )
    % 	r2 = ( (abs(x).^(2/F)) + (abs(z).^(2/F)) ).^(F*0.5);
    % else
    % 	indices = find( abs(x)>abs(z) );
    % 	r2( indices ) = abs(x(indices));
    % end

    r3 = r2;
    indices = find( (D+r)<r2 );
    r3( indices ) = D + r(indices);
    helix = -C + r3;
end