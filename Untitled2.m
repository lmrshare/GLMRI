load C:\Lin\ps\pspsnr16
s{1}=pspsnr{1}
load C:\Lin\ps\pspsnr25
s{2}=pspsnr{1}
load C:\Lin\ps\pspsnr36
s{3}=pspsnr{1}
load C:\Lin\ps\pspsnr49
s{4}=pspsnr{1}
load C:\Lin\ps\pspsnr64
s{5}=pspsnr{1}
clear pspsnr
pspsnr = s;
ps = [16 25 36 49 64];
save C:\Lin\ps\pspsnr pspsnr ps

clear
    fontsize = 15;
    load C:\Lin\ps\pspsnr
    PSNR_dl = [];
    PSNR_glwave = [];
    for i = 1:length(ps)
        PSNR_glwave = [PSNR_glwave,pspsnr{i}.param_wave.PSNR(end)];
    end
    
    f = figure;
    gg = get(f,'position');
    gg(3) = gg(3)*2;
    gg(4) = gg(4)/1.5;
    set(f,'position',gg)
    set(gcf,'color','w');
    
    plot(ps,PSNR_glwave, 'r.-')
    legend( ['GLMRI ']);
    set(gca,'XTick',ps); 
    xlabel('Patch Size','fontsize',fontsize);
    ylabel('PSNR','fontsize',fontsize);