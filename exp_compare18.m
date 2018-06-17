function exp_compare18(RF,cartesian,random,show)

addpath('../DLMRI_v6');

%{
load ../csmri/paper2010/brain.mat
clear data
%}
load 1Dmask/mask4 
M1 = fftshift(mask110);
load 2Dmask/mask4.mat;
M2 = fftshift(mask4);

data=imread('../dataset/t2axialbrain.jpg');
data=double(data(:,:,1));
data=data/max(max(data));
img = data;


if RF
    randomFactor = [];[blocks,idx] = my_im2col(zeros(size(img)),[sqrt(36),sqrt(36)],1);N2=size(blocks,2);
    for i = 1:20, randomFactor = [randomFactor;randperm(N2)];end
else
    load randomFactor
end


fidelityWeight4gl = 300;glratio = 100; %lambda_l = 1/300,lambda_l/lambda_g=100
fidelityWeight4dl = 140;

if cartesian
    %1D
    [glimgs41d,glparams41d]=main(img,M1,'DLONLY','01','FIDELITYWEIGHT',fidelityWeight4gl,'GLRATIO',glratio,'RANDOMFACTOR',randomFactor);
    [dlimgs41d,dlparams41d]=main(img,M1,'DLONLY','10','FIDELITYWEIGHT',fidelityWeight4dl,'RANDOMFACTOR',randomFactor);
    save compare41D glimgs41d glparams41d dlimgs41d dlparams41d
end
if random
    %2D
    [glimgs42d,glparams42d]=main(img,M2,'DLONLY','01','FIDELITYWEIGHT',fidelityWeight4gl,'GLRATIO',glratio,'RANDOMFACTOR',randomFactor);
    [dlimgs42d,dlparams42d]=main(img,M2,'DLONLY','10','FIDELITYWEIGHT',fidelityWeight4dl,'RANDOMFACTOR',randomFactor);
    save compare42D glimgs42d glparams42d dlimgs42d dlparams42d
end

if show
    %show figures
    
    load compare41D
    load compare42D
    index = '4';
    %  1D
    truth = img;
    f = figure;
    g = get(f,'position');
    g(1,[1 2]) = 0*g(1,[1 2]);
    g(1,[3 4]) = 2*g(1,[3 4]);
    set(f,'position',g);
    set(gcf,'color','w');
    left = 0.02;
    subplot('position',[0 ,0.5,0.3333,0.3333]);
    imshow(truth);title('Truth');colormap('gray');freezeColors
    subplot('position',[0.3333,0.5,0.3333,0.3333])
    imshow(dlimgs41d.dl);title('DLMRI');colormap('gray');freezeColors
    subplot('position',[0.3333*2 ,0.5,0.3333,0.3333])
    imshow(glimgs41d.gl_wave);title('GLMRI');colormap('gray');freezeColors
    
    subplot('position',[0.1-0.04,0.1,0.25,0.25]);
    plot(dlparams41d.param.PSNR, '.-')
    hold on
    plot(glparams41d.param_wave.PSNR, 'r.-')
    hold on
    %plot(params.param_wavetv.PSNR, 'g.-')
    %{
    le = legend(['DLMRI - ' num2str(size(data,1)/i,2) ' fold'], ...
        ['GLMRI(wavelet) - ' num2str(size(data,1)/i,2) ' fold'],...
        ['GLMRI(wavelet + TV) - ' num2str(size(data,1)/i,2) ' fold']);
    %}
    %-{
    le = legend(['DLMRI - ' index ' fold'], ...
        ['GLMRI - ' index ' fold']);
    %   ['GLMRI(wavelet + TV) - ' index ' fold']);
    %}
    set(le,'Location','SouthEast');
    set(le,'FontSize',7);
    legend('boxoff');
    xlabel('Iteration Number');ylabel('PSNR');
    subplot('position',[0.42-0.07-0.001,0.08,0.3333,0.3333]);
    imshow(10*abs(dlimgs41d.dl-truth))
    colormap('hot');
    colorbar();
    subplot('position',[0.753-0.07-0.001,0.08,0.3333,0.3333]);
    imshow(10*abs(glimgs41d.gl_wave-truth))
    colormap('hot');
    colorbar();
    %  2D
    f = figure;
    g = get(f,'position');
    g(1,[1 2]) = 0*g(1,[1 2]);
    g(1,[3 4]) = 2*g(1,[3 4]);
    set(f,'position',g);
    set(gcf,'color','w');
    left = 0.02;
    subplot('position',[0 ,0.5,0.3333,0.3333]);
    imshow(truth);title('Truth');colormap('gray');freezeColors
    subplot('position',[0.3333,0.5,0.3333,0.3333])
    imshow(dlimgs42d.dl);title('DLMRI');colormap('gray');freezeColors
    subplot('position',[0.3333*2 ,0.5,0.3333,0.3333])
    imshow(glimgs42d.gl_wave);title('GLMRI');colormap('gray');freezeColors
    
    subplot('position',[0.1-0.04,0.1,0.25,0.25]);
    plot(dlparams42d.param.PSNR, '.-')
    hold on
    plot(glparams42d.param_wave.PSNR, 'r.-')
    hold on
    %plot(params.param_wavetv.PSNR, 'g.-')
    %{
    le = legend(['DLMRI - ' num2str(size(data,1)/i,2) ' fold'], ...
        ['GLMRI(wavelet) - ' num2str(size(data,1)/i,2) ' fold'],...
        ['GLMRI(wavelet + TV) - ' num2str(size(data,1)/i,2) ' fold']);
    %}
    %-{
    le = legend(['DLMRI - ' index ' fold'], ...
        ['GLMRI - ' index ' fold']);
    %   ['GLMRI(wavelet + TV) - ' index ' fold']);
    %}
    set(le,'Location','SouthEast');
    set(le,'FontSize',7);
    legend('boxoff');
    xlabel('Iteration Number');ylabel('PSNR');
    subplot('position',[0.42-0.07-0.001,0.08,0.3333,0.3333]);
    imshow(10*abs(dlimgs42d.dl-truth))
    colormap('hot');
    colorbar();
    subplot('position',[0.753-0.07-0.001,0.08,0.3333,0.3333]);
    imshow(10*abs(glimgs42d.gl_wave-truth))
    colormap('hot');
    colorbar();
end
