
%dataset = {'Brain','Phantom','Spine','Angio'};
dataset = {'Brain'};
SMmode = 'RANDOM';%CARTESIAN  RANDOM
index = '4';
Phantom = phantom('Modified Shepp-Logan',512);
Angio=imread('../dataset/COW0001.jpg');
Brain=imread('../dataset/t2axialbrain.jpg');
Spine=imread('../dataset/herniateddisclspine.jpg');
for i = 1:size(dataset,2)
    clear imgs params
    str = horzcat('load all_datas_',SMmode,'/',dataset{i},'_',SMmode,'_',index);
    eval(str);
    str = strcat('data = ',dataset{i},';');eval(str);
    data=double(data(:,:,1));
    data=data/max(max(data));
    truth = data;
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
    imshow(imgs.dl);title('DLMRI');colormap('gray');freezeColors
    subplot('position',[0.3333*2 ,0.5,0.3333,0.3333])
    imshow(imgs.gl_wave);title('GLMRI');colormap('gray');freezeColors
    
    subplot('position',[0.1-0.04,0.1,0.25,0.25]);
    plot(params.param.PSNR, '.-')
    hold on
    plot(params.param_wave.PSNR, 'r.-')
    hold on
    %plot(params.param_wavetv.PSNR, 'g.-')
    %{
    le = legend(['DLMRI - ' num2str(size(data,1)/i,2) ' fold'], ...
        ['GLMRI(wavelet) - ' num2str(size(data,1)/i,2) ' fold'],...
        ['GLMRI(wavelet + TV) - ' num2str(size(data,1)/i,2) ' fold']);
    %}
    %-{
    le = legend(['DLMRI - ' index ' fold'], ...
        ['GLSMRI - ' index ' fold']);
    %   ['GLMRI(wavelet + TV) - ' index ' fold']);
    %}
    set(le,'Location','SouthEast');
    set(le,'FontSize',7+1);
    legend('boxoff');
    %xlabel('Iteration Number');ylabel('PSNR');
    xlabel('迭代次数');ylabel('PSNR');
    subplot('position',[0.42-0.07-0.001,0.08,0.3333,0.3333]);
    imshow(10*abs(imgs.dl-truth))
  %  colormap('hot');
    colorbar();
    subplot('position',[0.753-0.07-0.001,0.08,0.3333,0.3333]);
    imshow(10*abs(imgs.gl_wave-truth))
 %   colormap('hot');
    colorbar();
    if i == 1
        fontsize = 14;
        x = 150;y = 160;len = 100;
        %x = 196;y = 37;len = 100;
        ff = figure;
        g = get(ff,'position');
        set(gcf,'color','w');
        g(3) = g(3)/2;
        g(4) = g(4)/3;
        set(ff,'position',g)
        plot(0:len,truth(y:y+len,x),'g','LineWidth',1);
        hold on;
        plot(0:len,imgs.dl(y:y+len,x),'--b','LineWidth',1);
        hold on;
        plot(0:len,imgs.gl_wave(y:y+len,x),'--r','LineWidth',1);
        %-{
        le = legend(['Truth'], ...
            ['DLMRI'],...
            ['GLSMRI']);
        set(le,'Location','NorthEast');
        set(le,'FontSize',fontsize);
        set(le,'LineWidth',1);
        %}
        %xlabel('Position','FontSize',fontsize+1);
        xlabel('位置','FontSize',fontsize);
        %set(gca,'YScale','log')
        %ylabel('Intensity','FontSize',fontsize+1);
        ylabel('强度','FontSize',fontsize);
        %legend('boxoff');
    end
end


%{
left = 0.02;
    subplot('position',[0 + left,0.5,0.25,0.25]);
    imshow(truth);title('Truth');colormap('gray');freezeColors
    subplot('position',[0.25 + left,0.5,0.25,0.25])
    imshow(imgs.dl);title('DLMRI');colormap('gray');freezeColors
    subplot('position',[0.5 + left,0.5,0.25,0.25])
    imshow(imgs.gl_wave);title('GLMRI(wavelet)');colormap('gray');freezeColors
    subplot('position',[0.75 + left,0.5,0.25,0.25])
    imshow(imgs.gl_wavetv);title('GLMRI(wavelet+TV)');colormap('gray');freezeColors
    
    subplot('position',[0.08-0.04,0.1,0.24,0.24]);
    plot(params.param.PSNR, '.-')
    hold on
    plot(params.param_wave.PSNR, 'r.-')
    hold on
    plot(params.param_wavetv.PSNR, 'g.-')
%{
    le = legend(['DLMRI - ' num2str(size(data,1)/i,2) ' fold'], ...
        ['GLMRI(wavelet) - ' num2str(size(data,1)/i,2) ' fold'],...
        ['GLMRI(wavelet + TV) - ' num2str(size(data,1)/i,2) ' fold']);
%}
%{
    le = legend(['DLMRI - ' index ' fold'], ...
        ['GLMRI(wavelet) - ' index ' fold'],...
        ['GLMRI(wavelet + TV) - ' index ' fold']);
%}
    set(le,'Location','SouthEast');
    set(le,'FontSize',7);
    legend('boxoff');
    xlabel('Iteration Number');ylabel('PSNR');
    subplot('position',[0.35-0.06-0.001,0.08,0.25,0.25]);
    imshow(10*abs(imgs.dl-truth))
    colormap('hot');
    colorbar();
    subplot('position',[0.6-0.06-0.001,0.08,0.25,0.25]);
    imshow(10*abs(imgs.gl_wave-truth))
    colormap('hot');
    colorbar();
    subplot('position',[0.85-0.06-0.001,0.08,0.25,0.25]);
    imshow(10*abs(imgs.gl_wavetv-truth))
    colormap('hot');
    colorbar();
%}

