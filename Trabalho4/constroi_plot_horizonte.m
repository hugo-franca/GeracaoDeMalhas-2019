function faces = constroi_plot_horizonte(V, arestas_horizonte, p)

	V(end+1, :) = p;
	indiceP = size(V, 1);

	% faces = [];

	

	for i=1:size(arestas_horizonte, 1)
		faces(end+1, :) = [arestas_horizonte(i, :), indiceP];
	end

	
end