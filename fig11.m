
if 0
    clear
    fontsize = 15;
    load parameter\pspsnr
    PSNR_dl = [];
    PSNR_glwave = [];
    for i = 1:length(ps)
        PSNR_dl = [PSNR_dl,pspsnr{i}.param.PSNR(end)];
        PSNR_glwave = [PSNR_glwave,pspsnr{i}.param_wave.PSNR(end)];
    end
    
    f = figure;
    gg = get(f,'position');
    gg(3) = gg(3)*2;
    gg(4) = gg(4)/1.5;
    set(f,'position',gg)
    set(gcf,'color','w');
    
    plot(ps,PSNR_dl, '.-')
    hold on
    plot(ps,PSNR_glwave, 'r.-')
    legend(['DLMRI ' ], ...
        ['GLSMRI ']);
    set(gca,'XTick',ps);
    xlabel('Patch Size','fontsize',fontsize);
    ylabel('PSNR','fontsize',fontsize);
    %title('(a)');
    %{
    set(gca,'XTick',x);
    set(gca,'XTickLabel',{'0','1','10','20','30','40','50','60','70','80','90','100',''});
        legend(['GLSMRI'],['DLMRI ' ]);
    text(198,31.8,'+\infty','FontSize',15);
    xlabel('\lambda_L/\lambda_G','fontsize',fontsize);
    ylabel('PSNR','fontsize',fontsize);
    %}
end
if 0
    clear
    load parameter\dspsnr
    PSNR_dl = [];
    PSNR_glwave = [];
    for i = 1:length(ds)
        PSNR_dl = [PSNR_dl,dspsnr{i}.param.PSNR(end)];
        PSNR_glwave = [PSNR_glwave,dspsnr{i}.param_wave.PSNR(end)];
    end
    
    f = figure;
    g = get(f,'position');
    set(f,'position',g/2.1)
    set(gcf,'color','w');
    
    plot(ds,PSNR_dl, '.-')
    hold on
    plot(ds,PSNR_glwave, 'r.-')
    legend(['DLMRI ' ], ...
        ['GLSMRI(wavelet) ']);
    xlabel('Dictionary Size');
    ylabel('PSNR');
    title('(b)');
end
if 1
    clear
    fontsize = 8;
    fontsize2 = 8;
    fontsize3 = 8;
    %width = 1.5;
    width = 1;
    load parameter/fidelityWeightpsnr
    PSNR_glwave = [];
    for i = 1:length(l)
        PSNR_glwave = [PSNR_glwave,fidelityWeightpsnr{i}.param_wave.PSNR(end)];
    end
    
    l = 1./l;l = flipdim(l,2);
    %l = l([4 5 7 8]);
    PSNR_glwave = flipdim(PSNR_glwave,2);
    %PSNR_glwave = PSNR_glwave([4 5 7 8]);
    
    f = figure;
    g = get(f,'position');
    %g(3) = g(3)*2;
    g(3) = g(3)*2/3;
    g(4) = g(4)/3;
    set(f,'position',g)
    set(gcf,'color','w');
    
    p = plot(l,PSNR_glwave, 'b.-','LineWidth',width);
    set(p,'Color','black','LineWidth',width);
    set(gca,'XTick',l([1:2:end,8]));
    set(gca,'XTickLabel',{'1/800','1/600','1/400','1/200','1/100'});
    %set(gca,'XTickLabel',{'A','B','C','D','E'});
    le = legend(['GLSMRI ']);
    set(le,'Location','NorthEast');
set(le,'FontSize',fontsize2);
set(gca,'FontSize',fontsize);
legend('boxoff');
xlabel('\lambda_L   ','fontsize',fontsize3);
set(gca,'XScale','log')
ylabel('PSNR','fontsize',fontsize3);
    
end
if 1
    clear
fontsize = 6;
fontsize2 = 8;
fontsize3 = 8;
%width = 1.5;
width = 1;
    load parameter\glratiopsnr
    PSNR_glwave = [];
    %PSNR_dl = [];
    for i = 1:length(g)
        PSNR_glwave = [PSNR_glwave,glratiopsnr{i}.param_wave.PSNR(end)];
        %PSNR_dl = [PSNR_dl,glratiopsnr{i}.param.PSNR(end)];
    end
    
    %g = (1./g)*(0.007);g = flipdim(g,2);
    %PSNR_glwave = flipdim(PSNR_glwave,2);
    
    f = figure;
    gg = get(f,'position');
    gg(3) = gg(3)*2/3;
    gg(4) = gg(4)/3;
    set(f,'position',gg)
    set(gcf,'color','w');
    
    
    x = g;x(2) = 3;x(end)=200;
    p = plot(x,PSNR_glwave, '.-','LineWidth',width);
    set(p,'Color','black','LineWidth',width);
    % hold on
    % plot(g(1:end-1),PSNR_dl(1:end-1),'b.-');
    set(gca,'XTick',x);
    set(gca,'XTickLabel',{'0','1','10','20','30','40','50','60','70','80','90','100',''});
    le = legend(['GLSMRI'],['DLMRI ' ]);
set(le,'FontSize',fontsize2);
set(gca,'FontSize',fontsize);
    legend('boxoff');
    text(190,29,'+\infty','FontSize',fontsize3);
xlabel('\lambda_L/\lambda_G','fontsize',fontsize3);
ylabel('PSNR','fontsize',fontsize3);
    
end
if 1
    clear
fontsize = 6;
fontsize2 = 8;
fontsize3 = 8;
%width = 1.5;
width = 1;
    load parameter\rpsnr
    
    PSNR_glwave = [];
    PSNR_dl =[];
    for i = 1:length(r)
        PSNR_glwave = [PSNR_glwave,rpsnr{i}.param_wave.PSNR(end)];
        %PSNR_dl = [PSNR_dl,rpsnr{i}.param.PSNR(end)];
    end
    
    f = figure;
    g = get(f,'position');
    g(3) = g(3)*2/3;
    g(4) = g(4)/3;
    set(f,'position',g)
    set(gcf,'color','w');
    
    p = plot(r,PSNR_glwave, 'b.-','LineWidth',width);
    set(p,'Color','black','LineWidth',width);
    %hold on
    %plot(r,PSNR_dl,'b.-');
    set(gca,'XTick',r);
    le = legend(['GLSMRI']);
set(le,'FontSize',fontsize2);
set(gca,'FontSize',fontsize);
    legend('boxoff');
xlabel('r','fontsize',fontsize3);
ylabel('PSNR','fontsize',fontsize3);
    
end
if 0
    clear
    fontsize = 15;
    GLPSNR = [];
    load E:\gridSearch\r2psnrR1
    line = zeros(1,size(r2psnr));
    for i = 1:length(r2psnr),line(i) = r2psnr{i}.param_wave.PSNR(20);end
    GLPSNR = [GLPSNR;line];
    load E:\gridSearch\r2psnrR2
    line = zeros(1,size(r2psnr));
    for i = 1:length(r2psnr),line(i) = r2psnr{i}.param_wave.PSNR(20);end
    GLPSNR = [GLPSNR;line];
    load E:\gridSearch\r2psnrR3
    line = zeros(1,size(r2psnr));
    for i = 1:length(r2psnr),line(i) = r2psnr{i}.param_wave.PSNR(20);end
    GLPSNR = [GLPSNR;line];
    load E:\gridSearch\r2psnrR4
    line = zeros(1,size(r2psnr));
    for i = 1:length(r2psnr),line(i) = r2psnr{i}.param_wave.PSNR(20);end
    GLPSNR = [GLPSNR;line];
    load E:\gridSearch\r2psnrR5
    line = zeros(1,size(r2psnr));
    for i = 1:length(r2psnr),line(i) = r2psnr{i}.param_wave.PSNR(20);end
    GLPSNR = [GLPSNR;line];
    load E:\gridSearch\r2psnrR6
    line = zeros(1,size(r2psnr));
    for i = 1:length(r2psnr),line(i) = r2psnr{i}.param_wave.PSNR(20);end
    GLPSNR = [GLPSNR;line];
    
    g = 0:10:100;g(1) = 1;%g = [g,inf];g = 1./g;g = flipdim(g,2);
    r = 1:6;
    [X,Y] = meshgrid(g, r);
    figure;
    set(gcf,'color','w');
    mesh(X,Y,GLPSNR(:,1:end-1));
    
    hold on;index = 1;plot3(g,repmat(r(index),1,length(g)),GLPSNR(index,1:end-1),'k.-');
    hold on;index = 2;plot3(g,repmat(r(index),1,length(g)),GLPSNR(index,1:end-1),'m.-');
    hold on;index = 3;plot3(g,repmat(r(index),1,length(g)),GLPSNR(index,1:end-1),'c.-');
    hold on;index = 4;plot3(g,repmat(r(index),1,length(g)),GLPSNR(index,1:end-1),'r.-');
    hold on;index = 5;plot3(g,repmat(r(index),1,length(g)),GLPSNR(index,1:end-1),'g.-');
    hold on;index = 6;plot3(g,repmat(r(index),1,length(g)),GLPSNR(index,1:end-1),'b.-');
    
    
    set(gca,'XTick',g);
    set(gca,'XTickLabel',{'1','10','20','30','40','50','60','70','80','90','100'});
    set(gca,'YTick',r);
    set(gca,'YTickLabel',{'1','2','3','4','5','6'});
    xlabel('\lambda_L/\lambda_G','fontsize',fontsize);
    ylabel('r','fontsize',fontsize);
    zlabel('PSNR','fontsize',fontsize);
end