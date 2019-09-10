% Recebe um cubo (definido por dois pontos extremos)
% Retorna os 6 tetrahedros deste cubo de acordo com a triangulacao CFK
% CFK = Coxeter-Freudenthal-Kuhn

function tetrahedra = triangulacao_CFK(	v_esq_baixo_frente, v_dir_baixo_frente, v_dir_baixo_tras, v_esq_baixo_tras,	v_esq_cima_frente, v_dir_cima_frente, v_dir_cima_tras, v_esq_cima_tras)

	% Construindo cada um dos tetrahedros
	tetrahedra{1} = [v_esq_baixo_frente v_esq_cima_frente v_dir_cima_frente v_dir_cima_tras];
	tetrahedra{2} = [v_esq_baixo_frente v_esq_cima_frente v_esq_cima_tras v_dir_cima_tras];
	tetrahedra{3} = [v_esq_baixo_frente v_esq_baixo_tras v_esq_cima_tras v_dir_cima_tras];
	tetrahedra{4} = [v_esq_baixo_frente v_dir_baixo_frente v_dir_cima_frente v_dir_cima_tras];
	tetrahedra{5} = [v_esq_baixo_frente v_dir_baixo_frente v_dir_baixo_tras v_dir_cima_tras];
	tetrahedra{6} = [v_esq_baixo_frente v_esq_baixo_tras v_dir_baixo_tras v_dir_cima_tras];

end