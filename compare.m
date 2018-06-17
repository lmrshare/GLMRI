%-load data----------------------------------
%CS datasets 
clear
glratio = 1;
dataset = 'phantom';

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
    
    %compare GLMRI and DLMRI
    if 0
        
        %[imgs,params]=main(data,M,'glratio',glratio); 
        [imgs,params]=main(data,M,'glratio',glratio,'r',10,'PATCHSIZE',100); 
        save compareGL_DL imgs params
    end
    if 1
        load compareGL_DL
    end
    gl = imgs.gl_wave;
    dl = imgs.dl;
    
    I1=double(data(:,:,1));
    I1=I1/(max(max(I1))); %Normalize input image - peak reconstruction pixel value restricted to 1 in this simulation.
   
    %compare CSMRI and DLMRI
    if 0
        %[imgs,params]=main(data,M,'glratio',glratio,'r',10,'PATCHSIZE',100,'dlonly',1);
        
        [aa,bb]=size(I1);     %Compute size of image
        foo=fft2(I1);          %FFT of input image
        DLMRIparams.CSopts.DLWeight = 0;
        DLMRIparams.CSopts.DLbeta = 0;   % (sqrt(n)/r)*(sqrt(n)/r)
        DLMRIparams.CSopts.xfmWeight = 0.05; %brain: DLMRIparams.CSopts.DLWeight/1000;phantom:DLMRIparams.CSopts.DLWeight*100
        cs = CSframe(FWT2D([aa,bb], [aa,bb], 'Daubechies', 4, 4), foo, M,zeros(aa,bb), DLMRIparams.CSopts);
        inn2= abs(cs)>1;cs(inn2)=1;cs = abs(cs);
        save compareCS_DL  cs
    end
    if 1
        load compareCS_DL
    end
    
    f = figure;
    g = get(f,'position');
    set(f,'position',[[0,0],g(4)*3,g(4)])
    set(gcf,'color','white');
    r = 136;c = 196;rows=100;columns=104;
    window = [r,c,rows,columns];
    hax = axes('Position', [0, 0, 0.33, 1]);
    imshow(I1);
    hax = axes('Position', [0+0.3333, 0, 0.33, 1]);
    imshow(cs);
    hax = axes('Position', [0+0.3333*2, 0, 0.33, 1]);
    imshow(dl);
    hax = axes('Position', [0, 0.062, 0.3333/3, 1/3]);
    imshow(I1(r:r+rows,c:c+columns));
    hax = axes('Position', [0+0.3333, 0.062, 0.3333/3, 1/3]);
    imshow(cs(r:r+rows,c:c+columns));
    hax = axes('Position', [0+0.3333*2, 0.06, 0.3333/3 1/3]);
    imshow(dl(r:r+rows,c:c+columns));
    
    f = figure;
    g = get(f,'position');
    set(f,'position',[[0,0],g(4)*3,g(4)])
    set(gcf,'color','white');
    r = 136;c = 196;rows=100;columns=104;
    window = [r,c,rows,columns];
    hax = axes('Position', [0, 0, 0.33, 1]);
    imshow(cs);
    hax = axes('Position', [0+0.3333, 0, 0.33, 1]);
    imshow(gl);
    hax = axes('Position', [0+0.3333*2, 0, 0.33, 1]);
    imshow(dl);
    hax = axes('Position', [0, 0.062, 0.3333/3, 1/3]);
    imshow(cs(r:r+rows,c:c+columns));
    hax = axes('Position', [0+0.3333, 0.062, 0.3333/3, 1/3]);
    imshow(gl(r:r+rows,c:c+columns));
    hax = axes('Position', [0+0.3333*2, 0.06, 0.3333/3 1/3]);
    imshow(dl(r:r+rows,c:c+columns));
    %CSMRI(PSNR:22.7281);DLMRI(PSNR:23.6983)
    %{
    subplot('position',[0.01,0.5,0.33,0.45]);imshow(I1);%title('Truth');
    subplot('position',[0.02+0.33,0.5,0.33,0.45]);imshow(cs);%title('CSMRI');
    subplot('position',[0.03+0.33*2,0.5,0.33,0.45]);imshow(dl);%title('DLMRI');
    subplot('position',[0.025,0.03,0.3,0.45]);imshow(I1(window(1):window(1)+window(3),window(2):window(2)+window(4)));
    subplot('position',[0.035+0.33,0.03,0.3,0.45]);imshow(cs(window(1):window(1)+window(3),window(2):window(2)+window(4)));
    subplot('position',[0.045+0.33*2,0.03,0.3,0.45]);imshow(dl(window(1):window(1)+window(3),window(2):window(2)+window(4)));
    %}
%%

%%
return