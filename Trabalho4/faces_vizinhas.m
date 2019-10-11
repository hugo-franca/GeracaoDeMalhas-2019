function [f1, f2, f3] = faces_vizinhas(V_Corners, F_Corners, Corners, face)

	% Obtendo os tres corners desta face
	c1 = Corners{F_Corners(face, 1)};
	c2 = Corners{F_Corners(face, 2)};
	c3 = Corners{F_Corners(face, 3)};

	% Obtendo as faces de cada corner oposto
	f1 = Corners{c1.oposto}.tri;
	f2 = Corners{c2.oposto}.tri;
	f3 = Corners{c3.oposto}.tri;

end