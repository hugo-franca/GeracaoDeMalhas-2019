function resp = face_visivel(f, p)
	resp = det([[f(1, :), 1]; [f(2, :), 1]; [f(3, :), 1]; [p, 1]])>0;
end