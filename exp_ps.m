function exp_ps(ps,mixture)

addpath('../DLMRI_v6');
data=imread('../dataset/t2axialbrain.jpg');
data=double(data(:,:,1));
data=data/max(max(data));
img = data;

load 2Dmask/mask4.mat;
M = fftshift(mask4);

%parameter: patch_size
%ps = [16,25,36,49,64];
if mixture
    for i = 1:length(ps)
        [imgs,params]=main(data,M,'PATCHSIZE',ps(i));
        pspsnr{i} = params;
    end
    str = strcat('save pspsnr',num2str(ps(1)),' pspsnr');
    eval(str);
end

if 0
    for i = 1:length(ps)
        DLMRIparams.num = 20;                       % number of iterations
        DLMRIparams.n = ps;                         % number of patch pixels
        DLMRIparams.K2 = DLMRIparams.n;                         % size of dictionary
        DLMRIparams.N = 200 * DLMRIparams.K2;                   % size of training dataset
        DLMRIparams.T0 = round((0.15)*DLMRIparams.n);           % sparsity level for patch
        DLMRIparams.Lambda = 1/140;                 % weight of fidelity
        DLMRIparams.KSVDopt = 1;                    % If set to 1, K-SVD learning is done with fixed sparsity
        DLMRIparams.th=0.023;                       % Threshold used in sparse representation of patches after training
        DLMRIparams.numiterateKSVD = 10;            % Number of iterations within the K-SVD algorithm
        DLMRIparams.r = 1;                          % Overlap Stride
        sigmai = 1;                                 % Noise level (standard deviation of complex noise) in the DFT space of the peak-normalized input image.
        sigma = 0;                                  % simulated noise level (standard deviation of simulated complex noise - added in k-space during simulation)
        [img11,param11] = DLMRIDemoReal(data,M,sigmai,sigma,DLMRIparams)
        pspsnr11{i} = param11;
    end
    str = strcat('save pspsnr11_',num2str(ps(1)),' pspsnr11');
    eval(str);
end