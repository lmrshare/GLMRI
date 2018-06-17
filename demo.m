%-load data----------------------------------
%CS datasets 
clear
glratio = 1;
dataset = 'brain';

%%
load ../csmri/paper2010/brain.mat
clear data

%%
%load ../csmri/paper2010/brain.mat
%clear data
phantom = phantom('Modified Shepp-Logan',512);
%truth = data;

%%
angio=imread('../dataset/COW0001.jpg');
%data=double(data(:,:,1));
%data=data/max(max(data));
%truth = data;

brain=imread('../dataset/t2axialbrain.jpg');

spine=imread('../dataset/herniateddisclspine.jpg');

str = strcat('data = ',dataset,';');eval(str);
data=double(data(:,:,1));
data=data/max(max(data));
truth = data;

%%
%load ../csmri/paper2010/angio.mat
%truth = data;

%%
%load ../csmri/paper2010/brain.mat
%brain = data;clear data

%%
    i = 50;%200(~2.5 fold), 140(~4 fold), 80(~6 fold), 50(~10 fold)
    index = num2str(i);
    str = strcat('M = fftshift(mask',index,');');
    eval(str);
    [imgs,params]=main(data,M,'glratio',glratio);
%%
figure; set(gcf,'color','w');
subplot('position',[0.1,0.4,0.25,0.25]);
imshow(truth);title('Truth');colormap('gray');freezeColors
subplot('position',[0.35,0.4,0.25,0.25])
imshow(imgs.dl);title('DLMRI');colormap('gray');freezeColors
subplot('position',[0.6,0.4,0.25,0.25])
imshow(imgs.gl_wave);title('GLMRI');colormap('gray');freezeColors
subplot('position',[0.85,0.4,0.25,0.25])
imshow(imgs.gl_svd);title('GLMRI');colormap('gray');freezeColors

subplot('position',[0.1,0.1,0.25,0.25]);
plot(params.param.PSNR, '.-')
hold on
plot(params.param_wave.PSNR, 'r.-')
hold on
plot(params.param_svd.PSNR, 'g.-')
legend(['DLMRI - ' num2str(size(data,1)/i,2) ' fold'], ...
['GLMRI with wavelet - ' num2str(size(data,1)/i,2) ' fold'],...
['GLMRI with svd - ' num2str(size(data,1)/i,2) ' fold']);
xlabel('Iteration Number');ylabel('PSNR');
subplot('position',[0.4,0.1,0.25,0.25]);
imshow(10*abs(imgs.dl-truth))
colormap('hot');
colorbar();
subplot('position',[0.65,0.1,0.25,0.25]);
imshow(10*abs(imgs.gl_wave-truth))
colormap('hot');
colorbar();
subplot('position',[0.9,0.1,0.25,0.25]);
imshow(10*abs(imgs.gl_svd-truth))
colormap('hot');
colorbar();

%%
return