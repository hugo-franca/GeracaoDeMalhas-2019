% Esta funcao encontra uma unica face visivel no objeto
% Esta face sera usada depois para iniciar o algoritmo que encontra as demais faces visiveis ao redor dela
function face = encontra_face_inicial(V, F, p)
	qtd_faces = size(F, 1);
	for i_face=1:qtd_faces

		% Obtendo os tres vertices desta face
		v1 = V(F(i_face, 1), :);
		v2 = V(F(i_face, 2), :);
		v3 = V(F(i_face, 3), :);

		if( face_visivel([v1; v2; v3], p) )
			face = i_face;
			return;
		end
	end
end