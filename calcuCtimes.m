%-load data----------------------------------
%CS datasets 
clear
dataset = 'brain';

%%
load 2Dmask/mask4.mat;


%%
%load ../csmri/paper2010/brain.mat
%clear data
phantom = phantom('Modified Shepp-Logan',512);
%truth = data;

%%
angio=imread('../dataset/COW0001.jpg');
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
    i = 4;%200(~2.5 fold), 140(~4 fold), 80(~6 fold), 50(~10 fold)
    index = num2str(i);
    str = strcat('M = fftshift(mask',index,');');
    eval(str);
    
    %compute GLMRI and DLMRI
    r1consume = tic;
    str = '01';
    [r1imgs,r1params]=main(data,M,'glratio',100,'r',1,'dlonly',str); 
    r1consume = toc(r1consume);
    r2consume = tic;
    [r2imgs,r2params]=main(data,M,'glratio',10,'r',2,'dlonly',str); 
    r2consume = toc(r2consume);
    save calcuCtimes r1imgs r1params r2imgs r2params r1consume r2consume

