function jobr(glratio,dataset)
% dataset: Phantom,Angio,Brain,Spine
% glratio:    1     100   100   30

load ../csmri/paper2010/brain.mat
clear data

Phantom = phantom('Modified Shepp-Logan',512);
Angio=imread('../dataset/COW0001.jpg');
Brain=imread('../dataset/t2axialbrain.jpg');
Spine=imread('../dataset/herniateddisclspine.jpg');

str = strcat('data = ',dataset,';');eval(str);
data=double(data(:,:,1));
data=data/max(max(data));
truth = data;

%load 2Dmask/mask4.mat;
M = fftshift(mask50);
[imgs,params]=main(truth,M,'R',10,'PATCHSIZE',100,'glratio',glratio);
str = horzcat('save ',dataset,'_r1',' imgs params glratio');
eval(str);
