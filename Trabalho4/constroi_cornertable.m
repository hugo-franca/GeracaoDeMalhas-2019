% Parametros: uma triangulacao no formato shared vertex
% 	V: matriz com os vertices
% 	F: matriz com as faces

% Retorna a triangulacao no formato corner table 
% 	V_corners: matriz associada aos vertices. Cada linha contem os corners de cada vertice
% 	F_corners: matriz associada as faces. Cada linha contem os tres corners de cada face
%   C: corner table

function [V_corners, F_corners, C] = constroi_cornertable(V, F)

	% Numero de faces e de vertices
	n_faces = size(F, 1);
	n_vertices = size(V, 1);

	% Contador de corners
	i_corner = 1;

	% Inicializando o cell_array
	V_corners = cell(n_vertices, 1);
	F_corners = zeros(n_faces, 3);

	textprogressbar('Construindo corner table: ');

	% Percorrendo cada face
	for i=1:n_faces

		textprogressbar( 50*i/n_faces );

		% Armazenando a face e vertices em variaveis separadas, soh pra ficar mais facil de entender
		face = F(i, :);
		v1 = face(1);
		v2 = face(2);
		v3 = face(3);

		% Para cada face, vamos criar tres novos corners (um para cada vertice)
		corner1.tri = i;
		corner1.vert = v1;
		corner1.prox = i_corner+1;
		% O corner anterior eh o prox do prox, entao nao precisa armazenar ele

		corner2.tri = i;
		corner2.vert = v2;
		corner2.prox = i_corner+2;

		corner3.tri = i;
		corner3.vert = v3;
		corner3.prox = i_corner;

		% Adicionando estes corners na tabela de corners
		C{i_corner} = corner1;
		C{i_corner+1} = corner2;
		C{i_corner+2} = corner3;

		% Adicionando estes corners na lista de corners dos seus respectivos vertices
		V_corners{v1}(end+1) = i_corner;
		V_corners{v2}(end+1) = i_corner+1;
		V_corners{v3}(end+1) = i_corner+2;

		F_corners(i, :) = [i_corner, i_corner+1, i_corner+2];

		i_corner = i_corner + 3;
		
	end



	% Percorrendo cada um dos corners para encontrar qual o corner oposto a ele
	qtdCorners = length(C);
	for i = 1:qtdCorners
		textprogressbar( 50 + (50*i/qtdCorners) );

		corner = C{i};
		i_corner_prox = corner.prox;
		i_corner_ant = C{corner.prox}.prox;

		vertice_ant = C{i_corner_ant}.vert;

		% Corners do vertice prox
		corners_prox_vert = V_corners{C{i_corner_prox}.vert};
		for i_corner2 = corners_prox_vert

			corner2 = C{i_corner2};
			corner2_prox = C{corner2.prox};
			corner2_ant = C{corner2_prox.prox};

			if( i_corner2==i_corner_prox )
				continue;
			end

			if( corner2_prox.vert==vertice_ant )
				corner_oposto = corner2_prox.prox;
				C{i}.oposto = corner_oposto;
			elseif( corner2_ant.vert==vertice_ant )
				corner_oposto = corner2.prox;
				C{i}.oposto = corner_oposto;
			end
		end
		
	end

	textprogressbar(100);
	textprogressbar('');

end