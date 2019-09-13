function plot_objeto(V, F)
	trimesh(F, V(:, 1), V(:, 2), V(:, 3))
	% trisurf(F, V(:, 1), V(:, 2), V(:, 3), 'edgecolor', 'none')

	axis equal;
	