clear
%L = sort(50:30:260,'descend');
if 1
    L = 4:10;
end
PSNR_dl=[];
PSNR_glwave=[];
PSNR_glwavetv=[];
SMmode = 'RANDOM';%'RANDOM''CARTESIAN'
dataset = {'Brain','Phantom','Spine','Angio'};
dataset = {'Spine'};
for j = 1:size(dataset,2)
    for i = L
        index = num2str(i);
        str = horzcat('load all_datas_',SMmode,'/',dataset{j},'_',SMmode,'_',index);
        eval(str);
        PSNR_dl = [PSNR_dl,params.param.PSNR(end)];
        PSNR_glwave = [PSNR_glwave,params.param_wave.PSNR(end)];
        %PSNR_glwavetv = [PSNR_glwavetv,params.param_wavetv.PSNR(end)];
    end
    %{
    switch SMmode
        case 'CARTESIAN'
            x = repmat(512,1,length(L))./L;              
        case 'RANDOM'
            x = L;             
    end
    %}
    x = L;
    f = figure;
    g = get(f,'position');
    set(f,'position',g/2.7)
    set(gcf,'color','w');
    plot(x,PSNR_dl, '.-','LineWidth',2)
    hold on
    plot(x,PSNR_glwave, 'r.-','LineWidth',2)
    le = legend(['DLMRI ' ], ...
        ['GLSMRI ']);
    %    ['GLMRI(wavelet + TV)']);
    set(le,'FontSize',8);
    legend('boxoff');
    xlabel('下采样因子','FontSize',8);
    ylabel('PSNR');
    xlim([floor(min(x)),ceil(max(x))]);
    ylim([floor(min(PSNR_dl)),ceil(max(PSNR_glwave))]);
    if strcmp(dataset{j},'Angio')
        dataset{j} = 'Vessel';
    end
    %title(dataset{j});
    PSNR_dl = [];
    PSNR_glwave = [];
    PSNR_glwavetv = [];
end
%{
    figure;set(gcf,'color','w');
    plot(x,PSNR_dl, '.-')
    hold on
    plot(x,PSNR_glwave, 'g.-')
    hold on
    plot(x,PSNR_glwavetv, 'r.-')
    legend(['DLMRI ' ], ...
        ['GLMRI(wavelet) '],...
        ['GLMRI(wavelet + TV)']);
    xlabel('Reduction Factor');
    ylabel('PSNR');
    xlim([floor(min(x)),ceil(max(x))]);
    ylim([floor(min(PSNR_dl)),ceil(max(PSNR_glwavetv))]);
    title(dataset{j});
    PSNR_dl = [];
    PSNR_glwave = [];
    PSNR_glwavetv = [];
%}