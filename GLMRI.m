function [Iout1,param1] = GLMRI(I1,Q1,sigmai,sigma,DLMRIparams)

%This code takes a real-valued (non-negative) image as input, and then tries to reconstruct it from simulated noisy undersampled k-space data.

%Note that all input parameters need to be set prior to simulation. We provide some example settings for the input parameters below. However, the user is
%advised to choose optimal values for the parameters depending on the specific data or task at hand.


% Inputs -
%       1. I1 : Input MR Image (real valued, non-negative).
%       2. Q1 : Sampling Mask for 2D DFT data (Center of k-space corresponds to corners of mask Q1) with zeros at non-sampled locations and ones at sampled locations.
%       3. sigmai : Noise level (standard deviation of complex noise) in the DFT space of the peak-normalized input image.
%                   To be set to 0 if input image data is assumed noiseless.
%       4. sigma : simulated noise level (standard deviation of simulated complex noise - added in k-space during simulation).
%       5. DLMRIparams: Structure that contains the parameters of the DLMRI algorithm. The various fields are as follows - 
%                   - num: Number of iterations of the DLMRI algorithm (Example: about 15)
%                   - n: Patch size, i.e., Total # of pixels in square patch (e.g., n=36, n=64)
%                   - K2: Number of dictionary atoms (e.g., K2=n)
%                   - N: Number of signals used for training (e.g., N=200*K2)
%                   - T0: Sparsity settings of patch (e.g., T0=round((0.15)*n) )
%                   - Lambda: Sets the weight \nu in the algorithm (e.g., Lambda=140)
%                   - KSVDopt: If set to 1, K-SVD learning is done with fixed sparsity. For any other setting, K-SVD learning is done
%                              employing both sparsity level and an error threshold (faster). (e.g., KSVDopt=1)
%                   - th: Threshold used in sparse representation of patches after training. To use threshold during training, set 
%                         KSVDopt appropriately. (e.g., th=0.023)
%                   - numiterateKSVD: Number of iterations within the K-SVD algorithm. (e.g., numiterateKSVD = 20, 10)
%                   - r: Overlap Stride (e.g., r=1)
%
%    K-SVD algorithm is initialized as mentioned in our IEEE TMI paper.
%
% Outputs -
%       1. Iout1 - Image reconstructed with DLMRI algorithm from undersampled data.
%       3. param1 - Structure containing various performance metrics, etc. from simulation for DLMRI.
%                 - InputPSNR : PSNR of fully sampled noisy reconstruction after adding simulated noise.
%                 - PSNR0 : PSNR of normalized zero-filled reconstruction
%                 - PSNR : PSNR of the reconstruction at each iteration of the DLMRI algorithm
%                 - HFEN : HFEN of the reconstruction at each iteration of the DLMRI algorithm
%                 - itererror : norm of the difference between the reconstructions at successive iterations
%                 - Dictionary : Final DLMRI dictionary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%DLMRI Parameters initialization

sigma2=sqrt((sigmai^2)+(sigma^2));  %Effective k-space noise level. 
%If sigma2 is very small (sigma2<1e-10), then the sampled k-space locations are filled back without averaging in the reconstruction update step 
%of our algorithm.

num=DLMRIparams.num;  %DLMRI algorithm iteration count

Lambda=DLMRIparams.Lambda; %Lambda parameter
La2=(Lambda)/(sigma2); % \nu weighting of paper

r=DLMRIparams.r; %Overlap Stride
n=DLMRIparams.n; %patch size
K2=DLMRIparams.K2; %number of dictionary atoms
N=DLMRIparams.N; %number of training signals
T0=DLMRIparams.T0; %sparsity levels
th=DLMRIparams.th; %error threshold for patches - allows error of (th^2)*n per patch during sparse coding.
op=DLMRIparams.KSVDopt;  %Type of K-SVD learning
numiterKSVD=DLMRIparams.numiterateKSVD; %number of K-SVD iterations


%other parameters of K-SVD algorithm
param.errorFlag=0;
param.L=T0;
param.K=K2;
param.numIteration=numiterKSVD;
param.preserveDCAtom=0;
param.InitializationMethod='GivenMatrix';param.displayProgress=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%MAIN SIMULATION CODE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

I1=double(I1(:,:,1));
I1=I1/(max(max(I1))); %Normalize input image - peak reconstruction pixel value restricted to 1 in this simulation.
[aa,bb]=size(I1);     %Compute size of image

DZ=((sigma/sqrt(2))*(randn(aa,bb)+(0+1i)*randn(aa,bb)));  %simulating noise
I5=fft2(I1);          %FFT of input image
%I5=I5+DZ;             %add measurement noise in k-space (simulated noise)

%Compute Input PSNR after adding simulated noise
IG=abs(ifft2(I5));
InputPSNR=20*log10((sqrt(aa*bb))/norm(double(abs(IG))-double(I1),'fro'));
param1.InputPSNR=InputPSNR;

index=find(Q1==1); %Index the sampled locations in sampling mask

I2=(double(I5)).*(Q1);  %Apply mask in DFT domain
I11=ifft2(I2);          % Inverse FFT - gives zero-filled result

%initializing simulation metrics
itererror=zeros(num,1);highfritererror=zeros(num,1);PSNR1=zeros(num,1);

I11=I11/(max(max(abs(I11))));  %image normalization

PSNR0=20*log10(sqrt(aa*bb)/norm(double(abs(I11))-double(I1),'fro')); %PSNR of normalized zero-filled reconstruction
param1.PSNR0=PSNR0;

h = waitbar(0,'Please wait...', 'Name', 'GLMRI');

%DLMRI iterations
for kp=1:num
    waitbar(kp/num, h, ['Iteration ' num2str(kp) ' of ' num2str(num)]);
    
    I11=abs(I11); % I11=I11/(max(max(I11)));
    Iiter=I11;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Creating image patches
    
    [blocks,idx] = my_im2col(I11,[sqrt(n),sqrt(n)],r); br=mean(blocks); %image patches
    br2 = (ones(n,1))*br;
    TE=blocks-br2;           %subtract means of patches
    [rows,cols] = ind2sub(size(I11)-sqrt(n)+1,idx);
    
    N2=size(blocks,2); %total number of overlapping image patches
    de=randperm(N2);
    
    %Check if specified number of training signals is less or greater than the available number of patches.
    if(N2>N)
        N4=N;
    else
        N4=N2;
    end
    
    YH=TE(:,de(1:N4));   %Training data - using random selection/subset of patches
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %dictionary initialization : PCA + random training patches
    [UU,SS,VV]=svd(YH*YH');
    D0=zeros(n,K2);
    [hh,jj]=size(UU);
    D0(:,1:jj)=UU;
    p1=randperm(N4);
    for py=jj+1:K2
        D0(:,py)=YH(:,p1(py-jj));
    end
    param.initialDictionary=D0;   %initial dictionary for K-SVD algorithm
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %K-SVD algorithm - two versions below
    
    if(op==1)
    [D,output] = KSVD(YH,param);    %K-SVD algorithm with sparsity only
    else
    [D,output] = KSVDC2(YH,param,th);  %K-SVD algorithm with both sparsity and error threshold (FASTER!)
    end
    
    %DLerror=(norm(YH -(D*output.CoefMatrix),'fro'))^2  %dictionary fitting error - uncomment to monitor.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Computing sparse representations of all patches and summing up the patch approximations
    Weight= zeros(aa,bb);
    IMout = zeros(aa,bb); bbb=sqrt(n);
    for jj = 1:10000:size(blocks,2)
        jumpSize = min(jj+10000-1,size(blocks,2)); ZZ=TE(:,jj:jumpSize);
        Coefs = OMPerrn(D,ZZ,th,2*param.L);   %sparse coding of patches
        ZZ= D*Coefs + (ones(size(blocks,1),1) * br(jj:jumpSize)); %sparse approximations of patches
        
        %summing up patch approximations
        for i  = jj:jumpSize
            col = cols(i); row = rows(i);
            block =reshape(ZZ(:,i-jj+1),[bbb,bbb]);
            IMout(row:row+bbb-1,col:col+bbb-1)=IMout(row:row+bbb-1,col:col+bbb-1)+block;
            Weight(row:row+bbb-1,col:col+bbb-1)=Weight(row:row+bbb-1,col:col+bbb-1)+ones(bbb);
        end;
    end
    
    I3n=IMout./Weight;  %patch-averaged result
    inn= abs(I3n)>1;I3n(inn)=1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    I2=fft2(I3n);  %Move from image domain to k-space
    
    %K-space update formula
    %-{
        I11 = CSframe(DLMRIparams.CSopts.psi, I5, Q1,ifft2(I2), DLMRIparams.CSopts);
        I11 = reshape(I11, size(I1));
%        index = find(Q1 == 1);foo = fft2(I11);foo(index) = I5(index);I11 = ifft2(foo);
    %}
    
    inn2= abs(I11)>1;I11(inn2)=1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Compute various performance metrics
    itererror(kp)= norm(abs(Iiter) - abs(I11),'fro');
    highfritererror(kp)=norm(imfilter(abs(I11),fspecial('log',15,1.5)) - imfilter(I1,fspecial('log',15,1.5)),'fro');
    PSNR1(kp)=20*log10(sqrt(aa*bb)/norm(double(abs(I11))-double(I1),'fro'));
    
    
end

close(h);
Iout1=abs(I11);
param1.PSNR=PSNR1;
param1.HFEN=highfritererror;
param1.itererror=itererror;
param1.Dictionary=D;
