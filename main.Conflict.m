function [imgs,params]=main(img,M,varargin)

addpath('../csmri/');
addpath('../libConfict/DLMRI_v6/');
addpath('../dmri');

if (nargin-length(varargin)) ~= 2
  error('Wrong number of required parameters');
end

num = 20;                       % number of iterations
n = 36;                         % number of patch pixels
K2 = n;                         % size of dictionary
N = 200 * K2;                   % size of training dataset
T0 = round((0.15)*n);           % sparsity level for patch
fidelityWeight = 140;           % weight of fidelity
KSVDopt = 1;                    % If set to 1, K-SVD learning is done with fixed sparsity
th=0.023;                       % Threshold used in sparse representation of patches after training
numiterateKSVD = 10;            % Number of iterations within the K-SVD algorithm
r = 1;                          % Overlap Stride
sigmai = 1;                     % Noise level (standard deviation of complex noise) in the DFT space of the peak-normalized input image.
sigma = 0;                      % simulated noise level (standard deviation of simulated complex noise - added in k-space during simulation)
glratio = 100;                  % the ratio between local sparsity and global sparsity

dlonly = '11';

randomFactor = [];[blocks,idx] = my_im2col(zeros(size(img)),[sqrt(n),sqrt(n)],r);N2=size(blocks,2);
for i = 1:num, randomFactor = [randomFactor;randperm(N2)];end

if (rem(length(varargin),2)==1)
  error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PATCHSIZE'
                n = varargin{i+1};
                K2 = n;
                N = 200 * K2;
                T0 = round((0.15)*n);
                randomFactor = [];[blocks,idx] = my_im2col(zeros(size(img)),[sqrt(n),sqrt(n)],r);N2=size(blocks,2);
                for i = 1:num, randomFactor = [randomFactor;randperm(N2)];end
            case 'DICTSIZE'
                K2 = varargin{i+1};
            case upper('fidelityWeight')
                fidelityWeight = varargin{i+1};
            case upper('glratio')
                glratio = varargin{i+1};
            case upper('randomFactor')
                randomFactor = varargin{i+1};
            case upper('r')
                r = varargin{i+1};
                randomFactor = [];[blocks,idx] = my_im2col(zeros(size(img)),[sqrt(n),sqrt(n)],r);N2=size(blocks,2);
                for i = 1:num, randomFactor = [randomFactor;randperm(N2)];end
            case upper('dlonly')
                dlonly = varargin{i+1};
                num = 20;
        end
    end
end

DLMRIparams.num = num;
DLMRIparams.n = n;
DLMRIparams.K2 = K2;
DLMRIparams.N = N;
DLMRIparams.T0 = T0;
DLMRIparams.Lambda = fidelityWeight;
DLMRIparams.KSVDopt = KSVDopt;
DLMRIparams.th=th;
DLMRIparams.numiterateKSVD = numiterateKSVD;
DLMRIparams.r = r;

DLMRIparams.CSopts.DLWeight = 1/fidelityWeight;
DLMRIparams.CSopts.DLbeta = ceil(DLMRIparams.n/(DLMRIparams.r^2));   % (sqrt(n)/r)*(sqrt(n)/r)
DLMRIparams.CSopts.xfmWeight = DLMRIparams.CSopts.DLWeight/glratio; %brain: DLMRIparams.CSopts.DLWeight/1000;phantom:DLMRIparams.CSopts.DLWeight*100

if ~xor(str2num(dlonly(1)),1)
    DLMRIparams.CSopts.psi = 'NULL'; %represent DLMRI
    [imgs.dl,params.param] = GLDLmixture(img,M,sigmai,sigma,DLMRIparams,randomFactor);
end

if ~xor(str2num(dlonly(2)),1)
    DLMRIparams.CSopts.psi = 'WAVE';%FWT2D(size(img), size(img), 'Daubechies', 4, 4);
    DLMRIparams.CSopts.TVWeight = 0;
    [imgs.gl_wave,params.param_wave] = GLDLmixture(img,M,sigmai,sigma,DLMRIparams,randomFactor);
end

%{
DLMRIparams.CSopts.psi = 'WAVE';
DLMRIparams.CSopts.TVWeight = DLMRIparams.CSopts.xfmWeight/10;
[imgs.gl_wavetv,params.param_wavetv] = GLDLmixture(img,M,sigmai,sigma,DLMRIparams,randomFactor);
%}
%{
DLMRIparams.CSopts.psi = 'SVD';
DLMRIparams.CSopts.TVWeight = 0;
[imgs.gl_svd,params.param_svd] = GLDLmixture(img,M,sigmai,sigma,DLMRIparams,randomFactor);
%}
%{
DLMRIparams.CSopts.psi = 'SVD';
DLMRIparams.CSopts.TVWeight = DLMRIparams.CSopts.xfmWeight/10;
[imgs.gl_svdtv,params.param_svdtv] = GLDLmixture(img,M,sigmai,sigma,DLMRIparams,randomFactor);
%}