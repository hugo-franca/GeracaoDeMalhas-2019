clear;
close all;
clc;

% Escolher o exemplo
% exemplo = 'chevron';
% exemplo = 'swan';
exemplo = 'airfoil';

% Escolher qual metodo equacao eliptica vai resolver
metodo = 'ttm'; % TTM: resolve a equacao com as funcoes P e Q no rhs
% metodo = 'winslow';  % Winslow: resolve a equacao homogenea


% Parametros para serem usados no caso TTM (sao ignorados no caso winslow)
xi_i = [0.5];
eta_i = [0.99];
a_param = [10.0];
b_param = [10.0];
c_param = [10.0];
d_param = [10.0];


% Calculando uma condicao inicial por TFI
[X, Y, xi, eta] = build_tfi(50, 50, exemplo);

% tolerancia e maxIteracoes para os metodos iterativos
maxIteracoes = 5000;
tol = 1e-5;


[X_jacobi, Y_jacobi, err_jacobi] = resolve_equacoes(metodo, 'jacobi', tol, maxIteracoes, X, Y, xi, eta, ...
													xi_i, eta_i, a_param, b_param, c_param, d_param);

[X_gauss, Y_gauss, err_gauss] = resolve_equacoes(metodo, 'gauss_seidel', tol, maxIteracoes, X, Y, xi, eta, ...
												xi_i, eta_i, a_param, b_param, c_param, d_param);
	
[X_sor, Y_sor, err_sor] = resolve_equacoes(metodo, 'sor', tol, maxIteracoes, X, Y, xi, eta, ...
												xi_i, eta_i, a_param, b_param, c_param, d_param);





% Fazendo plots
fonteLabels = 18;
fonteTitulos = 20;


figure;
axis equal;
plot_grid(X, Y);
xlim( [ min(min(X)), max(max(X)) ] );
ylim( [ min(min(Y)), max(max(Y)) ] );
xlabel('Coordenada X', 'FontSize', fonteLabels)
ylabel('Coordenada Y', 'FontSize', fonteLabels)
title('Malha apenas com interpolacao TFI', 'FontSize', fonteTitulos);

figure
axis equal;
plot_grid(X_jacobi, Y_jacobi)
xlim( [ min(min(X_jacobi)), max(max(X_jacobi)) ] );
ylim( [ min(min(Y_jacobi)), max(max(Y_jacobi)) ] );
xlabel('Coordenada X', 'FontSize', fonteLabels)
ylabel('Coordenada Y', 'FontSize', fonteLabels)
title(['Malha com metodo ', upper(metodo), ' resolvido por Jacobi'], 'FontSize', fonteTitulos);

figure;
axis equal;
plot_grid(X_gauss, Y_gauss)
xlim( [ min(min(X_gauss)), max(max(X_gauss)) ] );
ylim( [ min(min(Y_gauss)), max(max(Y_gauss)) ] );
xlabel('Coordenada X', 'FontSize', fonteLabels)
ylabel('Coordenada Y', 'FontSize', fonteLabels)
title(['Malha com metodo ', upper(metodo), ' resolvido por Gauss-Seidel'], 'FontSize', fonteTitulos);

figure;
axis equal;
plot_grid(X_sor, Y_sor)
xlim( [ min(min(X_sor)), max(max(X_sor)) ] );
ylim( [ min(min(Y_sor)), max(max(Y_sor)) ] );
xlabel('Coordenada X', 'FontSize', fonteLabels)
ylabel('Coordenada Y', 'FontSize', fonteLabels)
title(['Malha com metodo ', upper(metodo), ' resolvido por SOR'], 'FontSize', fonteTitulos);

figure
hold on
espessura = 3;
plot(log10(err_jacobi), 'LineWidth', espessura)
plot(log10(err_gauss), 'LineWidth', espessura)
plot(log10(err_sor), 'LineWidth', espessura)
legend({'Jacobi', 'Gauss-Seidel', 'SOR \omega = 1.2'}, 'FontSize', 18)
xlabel('Iteracoes', 'FontSize', fonteLabels)
ylabel('log10(Erro)', 'FontSize', fonteLabels)
title('Convergencia de cada um dos metodos', 'FontSize', fonteTitulos)