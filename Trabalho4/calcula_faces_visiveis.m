function [faces_visiveis, horizonte] = calcula_faces_visiveis(V, F, V_Corners, F_Corners, Corners, p)
	

	% Encontra uma primeira (apenas uma) face visivel no objeto
	% A partir da face inicial, vamos encontrar as outras ao redor dela
	pilha = Pilha();
	pilha.push( encontra_face_inicial(V, F, p) );

	faces_status = zeros(size(F, 1));
	faces_visiveis = [];
	horizonte = [];

	iter = 0;
	while ~vazia(pilha)
		face = pilha.pop();

		% Verifa se esta face ja foi encontrada anteriormente. Ignora ela, neste caso
		if( faces_status(face) )
			continue;
		end

		% Verifica se esta face eh nao-visivel. Ignora ela neste caso
		% Se esta face nao for visivel, note que vai haver uma aresta de horizonte entre ela e a ultima face encontrada
		% Vou adicionar estas arestas de horizonte em uma lista pra poder fazer um plot do horizonte depois...
		if( ~face_visivel(V(F(face, :), :), p) )

			[f1, f2, f3] = faces_vizinhas(V_Corners, F_Corners, Corners, face);
			f = [f1 f2 f3];

			for i=1:3
				if( ~faces_status(f(i)) )
					continue;
				end

				corners_f1 = F_Corners(face, :);
				corners_f2 = F_Corners(f(i), :);

				vertices_f1 = [Corners{corners_f1(1)}.vert, Corners{corners_f1(2)}.vert, Corners{corners_f1(3)}.vert ];
				vertices_f2 = [Corners{corners_f2(1)}.vert, Corners{corners_f2(2)}.vert, Corners{corners_f2(3)}.vert ];

				v = [];
				v = [v, vertices_f1(find(vertices_f1==vertices_f2(1)))];
				v = [v, vertices_f1(find(vertices_f1==vertices_f2(2)))];
				v = [v, vertices_f1(find(vertices_f1==vertices_f2(3)))];
				if( length(v)==2 )
					horizonte(end+1, :) = v;
				end

			end

			continue;
		end

		iter = iter + 1;

		% Adiciona na lista de faces visiveis
		faces_visiveis(end+1) = face;
		faces_status(face) = 1;

		% Adicionando as tres vizinhas desta face na pilha
		[f1, f2, f3] = faces_vizinhas(V_Corners, F_Corners, Corners, face);
		pilha.push(f1);
		pilha.push(f2);
		pilha.push(f3);
	end

end