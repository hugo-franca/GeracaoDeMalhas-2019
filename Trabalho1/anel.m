function vertices = anel(indice_v, V, V_corners, Corner_table)
	vertices = [];

	corners = V_corners{indice_v}; % Pega todos os corners deste vertice
	for i_corner=1:length(corners) % Percorre cada um dos corners
		corner = Corner_table{ corners(i_corner) }; % Obtem a estrutura  deste corner na table 
		prox_corner = Corner_table{ corner.prox }; % Obtem a estrutura do proximo coner na table
		i_v = prox_corner.vert; % Indice do vertice do prox corner
		vertices(end+1, :) = V(i_v, :); % Adiciona o vertice na lista do anel
	end
end