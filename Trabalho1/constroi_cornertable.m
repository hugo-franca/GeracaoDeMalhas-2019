% Parametros: uma triangulacao no formato shared vertex
% 	V: matriz com os vertices
% 	F: matriz com as faces

% Retorna a triangulacao no formato corner table 
% 	V: matriz com os vertices. Cada linha contem os corners de cada vertice
% 	

function [V_corners, C] = constroi_cornertable(V, F)

	% Numero de faces e de vertices
	n_faces = size(F, 1);
	n_vertices = size(V, 1);

	% Contador de corners
	i_corner = 1;

	% Inicializando o cell_array
	V_corners = cell(n_vertices, 1);

	textprogressbar('Construindo corner table: ');

	% Percorrendo cada face
	for i=1:n_faces

		textprogressbar( 100*i/n_faces );

		% Armazenando a face e vertices em variaveis separadas, soh pra ficar mais facil de entender
		face = F(i, :);
		v1 = face(1);
		v2 = face(2);
		v3 = face(3);

		% Para cada face, vamos criar tres novos corners (um para cada vertice)
		corner1.tri = i;
		corner1.vert = v1;
		corner1.prox = i_corner+1;

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

		i_corner = i_corner + 3;
		
	end

	textprogressbar(100);
	textprogressbar('');

end