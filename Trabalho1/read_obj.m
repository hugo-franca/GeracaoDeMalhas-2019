function [V,F] = read_obj(filename)
  % function [V,F] = read_obj(filename) 
  % Reads a .obj mesh file and outputs the vertex and face list
  % assumes a 3D triangle mesh and ignores everything but:
  % v x y z and f i j k lines
  % Input:
  %  filename  string of obj file's path
  %
  % Output:
  %  V  number of vertices x 3 array of vertex positions
  %  F  number of faces x 3 array of face indices
  % 
  %ref: http://www.alecjacobson.com/weblog/?p=917
  
  fid = fopen(filename);

  V = [];
  F = [];
  while 1    
    tline = fgetl(fid);
    if ~ischar(tline)
      break
    end  % exit at end of file 
    ln = sscanf(tline,'%s',1); % line type 

    switch ln
        case 'v'   % mesh vertices
            V = [V; sscanf(tline(2:end),'%f')'];
        case 'f'   % face definition
            fv = []; fvt = []; fvn = [];
            str = textscan(tline(2:end),'%s'); str = str{1};
       
            nf = length(findstr(str{1},'/')); % number of fields with this face vertices
            [tok str] = strtok(str,'//');     % vertex only
            for k = 1:length(tok) fv = [fv str2num(tok{k})]; end
           
            if (nf > 0) 
              [tok str] = strtok(str,'//');   % add texture coordinates (estou jogando fora isso)
              for k = 1:length(tok) fvt = [fvt str2num(tok{k})]; end
            end
            if (nf > 1) 
              [tok str] = strtok(str,'//');   % add normal coordinates (estou jogando fora isso)
              for k = 1:length(tok) fvn = [fvn str2num(tok{k})]; end
            end
            F = [F; fv];
    end
  end
end

%% test:
%[V,F] = read_obj('path/to/your/mesh.obj');
%trisurf(F,V(:,1),V(:,2),V(:,3),'FaceColor',[0.26,0.33,1.0 ]);
%light('Position',[-1.0,-1.0,100.0],'Style','infinite');
%lighting phong;
