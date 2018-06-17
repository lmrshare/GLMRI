
% eg: opts.glratio = 100;opts.dataset = 'Brain';opts.SM = 50:30:170;opts.SMmode = 'CARTESIAN'
% eg: opts.glratio = 100;opts.dataset = 'Brain';opts.SM = [6 8 10];opts.SMmode = 'RANDOM'
function job(opts)

glratio = 100;
dataset = 'Brain';
SM = 4:10;
SMmode = 'CARTESIAN';

if isfield(opts, 'glratio'),     glratio = opts.glratio;         end
if isfield(opts, 'dataset'),     dataset = opts.dataset;         end
if isfield(opts, 'SM'),          SM = opts.SM;                   end
if isfield(opts, 'SMmode'),      SMmode = opts.SMmode;           end

switch SMmode
    case upper('Cartesian')
        for i = SM
            str = strcat('load 1Dmask-i/mask',num2str(i));
            eval(str);
        end
    case upper('Random')
        %{
        load ../DLMRI_v6/SamplingMasksDLMRI_TMI/Figure12/UndersamplingFactor6/Q1.mat
        mask6 = ifftshift(Q1);
        load ../DLMRI_v6/SamplingMasksDLMRI_TMI/Figure7/2Drandom/Q1.mat
        mask7 = ifftshift(Q1);
        load ../DLMRI_v6/SamplingMasksDLMRI_TMI/Figure12/UndersamplingFactor8/Q1.mat
        mask8 = ifftshift(Q1);
        load ../DLMRI_v6/SamplingMasksDLMRI_TMI/Figure12/UndersamplingFactor10/Q1.mat
        mask10 = ifftshift(Q1);
        clear Q1
        %}
        for i = SM
            str = strcat('load 2Dmask/mask',num2str(i));
            eval(str);
        end
end

Phantom = phantom('Modified Shepp-Logan',512);
Angio=imread('../dataset/COW0001.jpg');
Brain=imread('../dataset/t2axialbrain.jpg');
Spine=imread('../dataset/herniateddisclspine.jpg');

str = strcat('data = ',dataset,';');eval(str);
data=double(data(:,:,1));
data=data/max(max(data));
truth = data;

%%
for i = SM
    index = num2str(i);
    str = strcat('M = fftshift(mask',index,');');
    eval(str);
    [imgs,params]=main(data,M,'glratio',glratio);   
    str = horzcat('save ',dataset,'_',SMmode,'_',index,' imgs params');
    eval(str);
    clear imgs,params
end