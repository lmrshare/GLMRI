function xhat=CSframe(psi, y, M, zdl, opts)

if nargin < 5
    opts=[];
end

maxIt     = 2;
xfmWeight = 0.05;
TVWeight  = 0;
DLWeight = 1;
DLbeta = 36;

if isfield(opts, 'maxIt'),     maxIt = opts.maxIt;         end
if isfield(opts, 'xfmWeight'), xfmWeight = opts.xfmWeight; end
if isfield(opts, 'TVWeight'),  TVWeight=opts.TVWeight;     end
if isfield(opts, 'DLWeight'),  DLWeight=opts.DLWeight;     end
if isfield(opts, 'DLbeta'),  DLbeta=opts.DLbeta;     end

idx=find(M==1);
Mx=@(z) z(idx);
Mxt=@(z) subsasgn(zeros(size(M)), substruct('()', {idx}), z);
phi = myFFT2D(size(M));                   % modifying

problem.A=ComposeA(Mx, Mxt, phi, psi);        % modifying
problem.y=Mx(y);
problem.TV=TV1D();
problem.zdl=zdl(:);

problem.xfmWeight = xfmWeight;       % L1 penalty
problem.TVWeight = TVWeight;         % TV penalty
problem.DLWeight = DLWeight;         % DL penalty
problem.DLbeta = DLbeta;             % repeat times

% Parameters being fed into the Non-Linear CG
params.Itnlim = 8;
params.gradToll = 1e-30;
params.l1Smooth = 1e-15;
params.pNorm = 1;

% and line search parameters
params.lineSearchItnlim = 150;
params.lineSearchAlpha = 0.01;
params.lineSearchBeta = 0.8;
params.lineSearchT0 = 1 ;

% Kick it off
xhat=problem.A.psi*zdl;
%xhat=zeros(size(M));

xhat=xhat(:);
for inner=1:maxIt
    xhat=myfnlCg(xhat, problem, params);
end
xhat=psi'*xhat;
%xhat = ifft2(ifftshift(fft2(xhat)));
