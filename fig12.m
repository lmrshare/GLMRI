clear
%L = sort(50:30:260,'descend');
if 1
    L = 4;
end
PSNR_dl=[];
PSNR_glwave=[];
PSNR_glwavetv=[];
SMmode = 'RANDOM';%'RANDOM''CARTESIAN'
dataset = {'Brain','Phantom','Spine','Angio'};
Phantom = phantom('Modified Shepp-Logan',512);
Angio=imread('../dataset/COW0001.jpg');
Brain=imread('../dataset/t2axialbrain.jpg');
Spine=imread('../dataset/herniateddisclspine.jpg');
for j = 1:size(dataset,2)
        index = num2str(L);
        str = horzcat('load parameter\',dataset{j},'_r1');
        eval(str);
        str = strcat('data = ',dataset{j},';');eval(str);
        data=double(data(:,:,1));
        data=data/max(max(data));
        truth = data;
        gl = imgs.gl_wave;
        dl = imgs.dl;
        glPSNR = params.param_wave.PSNR(20);
        dlPSNR = params.param.PSNR(20);
        
        f = figure;
        g = get(f,'position');
        set(f,'position',[[0,0],g(4)*3,g(4)])
        set(gcf,'color','white');
        r = 136;c = 196;rows=100;columns=104;
        window = [r,c,rows,columns];
        hax = axes('Position', [0, 0, 0.33, 1]);
        imshow(truth);
        hax = axes('Position', [0+0.3333, 0, 0.33, 1]);
        imshow(gl);
        hax = axes('Position', [0+0.3333*2, 0, 0.33, 1]);
        imshow(dl);
        hax = axes('Position', [0, 0.062, 0.3333/3, 1/3]);
        imshow(truth(r:r+rows,c:c+columns));
        hax = axes('Position', [0+0.3333, 0.062, 0.3333/3, 1/3]);
        imshow(gl(r:r+rows,c:c+columns));
        hax = axes('Position', [0+0.3333*2, 0.06, 0.3333/3 1/3]);
        imshow(dl(r:r+rows,c:c+columns));
      
        %{
        f = figure;
        g = get(f,'position');
        set(f,'position',[[0,0],g(3)*2,g(4)*1.8])
        set(gcf,'color','white');
        r = 136;c = 196;rows=100;columns=104;
        window = [r,c,rows,columns];
        subplot('position',[0.01,0.5,0.25,0.45]);imshow(truth);str=strcat('glratio: ',num2str(glratio));title(str)%title('Truth');
        subplot('position',[0.02+0.25,0.5,0.25,0.45]);imshow(gl);title(num2str(glPSNR))%title('CSMRI');
        subplot('position',[0.03+0.25*2,0.5,0.25,0.45]);imshow(dl);title(num2str(dlPSNR));%title('DLMRI');
        subplot('position',[0.01,0.05,0.25,0.45]);imshow(truth(window(1):window(1)+window(3),window(2):window(2)+window(4)));
        subplot('position',[0.02+0.25,0.05,0.25,0.45]);imshow(gl(window(1):window(1)+window(3),window(2):window(2)+window(4)));
        subplot('position',[0.03+0.25*2,0.05,0.25,0.45]);imshow(dl(window(1):window(1)+window(3),window(2):window(2)+window(4)));
        %}
end