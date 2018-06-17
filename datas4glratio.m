addpath('../csmri/');
addpath('../DLMRI_v6/');
addpath('../dmri');

load parameter\glratiopsnr

prev = glratiopsnr(1:11)
prevg = g(1:11)

load all_datas_RANDOM/Brain_RANDOM_4
tmp = prev{11};
tmp.param_wave.PSNR(end) = params.param.PSNR(end);
prev{12} = tmp;

%-{
addpath('../DLMRI_v6');
data=imread('../dataset/t2axialbrain.jpg');
data=double(data(:,:,1));
data=data/max(max(data));
img = data;

load 2Dmask/mask4.mat;
M = fftshift(mask4);
[aa,bb] = size(M);
foo=fft2(img);
DLMRIparams.CSopts.DLWeight = 0;
DLMRIparams.CSopts.DLbeta = 0;
DLMRIparams.CSopts.xfmWeight = 0.05;
cs = CSframe(FWT2D([aa,bb], [aa,bb], 'Daubechies', 4, 4), foo, M,zeros(aa,bb), DLMRIparams.CSopts);
inn2= abs(cs)>1;cs(inn2)=1;cs = abs(cs);
CSPSNR = PSNR(img,cs);
%}
tmp = prev{11};
tmp.param_wave.PSNR(end) = CSPSNR;
glratiopsnr = [];
g = [];
glratiopsnr{1} = tmp;
glratiopsnr{2:13} = prev;
g = [0,prevg,inf];
save glratiopsnr glratiopsnr g

