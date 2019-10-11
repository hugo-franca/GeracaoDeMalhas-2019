function plot_objeto(V, F, tipo_plot, cor, alpha)
	% trimesh(F, V(:, 1), V(:, 2), V(:, 3))
	% trisurf(F, V(:, 1), V(:, 2), V(:, 3), 'edgecolor', 'none')

	trisurf(F, V(:, 1), V(:, 2), V(:, 3),'Facecolor','red','FaceAlpha',.1,'EdgeColor','none')

	axis equal;
	