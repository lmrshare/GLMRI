classdef myFFT2D
    
    properties (SetAccess = private, GetAccess = public)
        adjoint;
        imSize;
    end % properties

    methods
        function obj = myFFT2D(imSize)
            obj.adjoint = 0;
            obj.imSize = imSize;

        end

        function this = ctranspose(this)
            this.adjoint = xor(this.adjoint,1);
        end

        function res = mtimes(this,b)            
            if this.adjoint
                b=reshape(b, this.imSize);
                %res = sqrt(length(b(:)))*ifft2(b);
                res = ifft2(b);
            else
                b=reshape(b, this.imSize);
                %res = 1/sqrt(length(b(:)))*fft2(b);
                res = fft2(b);
            end
        end

    end  % methods
end

