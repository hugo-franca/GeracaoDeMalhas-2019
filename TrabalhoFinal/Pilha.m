classdef Pilha < handle

   properties
      v
   end

   methods
      function obj = Pilha()
         obj.v = [];
      end

      function push(obj, valor)
         obj.v(end+1) = valor;
      end

      function resp = pop(obj)
         resp = obj.v(end);
         obj.v = obj.v(1:end-1);
      end

      function resp = vazia(obj)
         resp = isempty(obj.v);
      end
   end

end