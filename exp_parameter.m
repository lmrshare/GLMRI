function exp_parameter(patch_size,dict_size,fidelityWeight,glratio,r,r2)

addpath('../DLMRI_v6');
data=imread('../dataset/t2axialbrain.jpg');
data=double(data(:,:,1));
data=data/max(max(data));
img = data;

%-{
load 2Dmask/mask4.mat;
M = fftshift(mask4);
%}
%{
load ../csmri/paper2010/brain.mat
clear data
M = fftshift(mask50);
%}
%patch_size
%%%%%%%%%%%%%%%%%%%%%%%%%%
if patch_size
    %parameter: patch_size
    ps = [16,25,36,49,64];
    for i = 1:length(ps)
        [imgs,params]=main(data,M,'PATCHSIZE',ps(i));
        pspsnr{i} = params;
    end
    save D:\pspsnr pspsnr ps
end
%dict_size
%%%%%%%%%%%%%%%%%%%%%%%%%%5
if dict_size
    %parameter: patch_size
    ds = [36 72 108 144];
    
    randomFactor = [];[blocks,idx] = my_im2col(zeros(size(img)),[sqrt(36),sqrt(36)],1);N2=size(blocks,2);
    for i = 1:20, randomFactor = [randomFactor;randperm(N2)];end
    
    for i = 1:length(ds)
        [imgs,params]=main(data,M,'DICTSIZE',ds(i),upper('randomFactor'),randomFactor);
        dspsnr{i} = params;
    end
    save D:\dspsnr dspsnr ds
end

%lambda
%%%%%%%%%%%%%%%%%%%%%%%%%%5
if fidelityWeight
    %parameter: patch_size
    l = 100:100:800;
    
    randomFactor = [];[blocks,idx] = my_im2col(zeros(size(img)),[sqrt(36),sqrt(36)],1);N2=size(blocks,2);
    for i = 1:20, randomFactor = [randomFactor;randperm(N2)];end
    
    for i = 1:length(l)
        [imgs,params]=main(img,M,upper('fidelityWeight'),l(i),upper('randomFactor'),randomFactor);
        fidelityWeightpsnr{i} = params;
    end
    save D:\fidelityWeightpsnr fidelityWeightpsnr l
end
if glratio
    g = 110:10:120;g(1) = 1;g = [g,inf];
    randomFactor = [];[blocks,idx] = my_im2col(zeros(size(img)),[sqrt(36),sqrt(36)],1);N2=size(blocks,2);
    for i = 1:20, randomFactor = [randomFactor;randperm(N2)];end    
    
    for i = 1:length(g)
        [imgs,params]=main(data,M,upper('glratio'),g(i),upper('dlonly'),'11',upper('randomFactor'),randomFactor);
        glratiopsnr{i} = params;
    end    
    save D:\glratiopsnr glratiopsnr g
end
if r
    r = 1:6
    for i = 1:length(r)
        [imgs,params]=main(data,M,upper('r'),r(i));
        rpsnr{i} = params;
    end    
    save D:\rpsnr rpsnr r
end
if r2
    g = 0:10:100;g(1) = 1;g = [g,inf];    
    for i = 1:length(r2);
        R = r2(i);
        randomFactor = [];[blocks,idx] = my_im2col(zeros(size(img)),[sqrt(36),sqrt(36)],R);N2=size(blocks,2);
        for i = 1:20, randomFactor = [randomFactor;randperm(N2)];end
        for i = 1:length(g)
            [imgs,params]=main(data,M,'R',R,'GLRATIO',g(i),'RANDOMFACTOR',randomFactor);
            r2psnr{i} = params;
        end
        str = strcat('save E:\r2psnrR',num2str(R),' r2psnr');
        eval(str);
    end
end
