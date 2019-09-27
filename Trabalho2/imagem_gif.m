function imagem_gif(filename, h)

	persistent gif_iniciado;

	frame = getframe(h); 
	im = frame2im(frame); 
	[imind,cm] = rgb2ind(im, 256); 

	% Write to the GIF File 
	if( isempty(gif_iniciado) )
		imwrite(imind,cm, filename,'gif', 'DelayTime', 0.25, 'Loopcount',inf); 
		gif_iniciado = true;
	else 
		imwrite(imind,cm, filename,'gif', 'DelayTime', 0.25, 'WriteMode','append'); 
	end 

end