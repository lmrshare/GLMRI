function [I2,D] = patchUpdate(I11,DLMRIparams,de)

r=DLMRIparams.r; %Overlap Stride
n=DLMRIparams.n; %patch size
K2=DLMRIparams.K2; %number of dictionary atoms
N=DLMRIparams.N; %number of training signals
T0=DLMRIparams.T0; %sparsity levels
th=DLMRIparams.th; %error threshold for patches - allows error of (th^2)*n per patch during sparse coding.
op=DLMRIparams.KSVDopt;  %Type of K-SVD learning
numiterKSVD=DLMRIparams.numiterateKSVD; %number of K-SVD iterations

param.errorFlag=0;
param.L=T0;
param.K=K2;
param.numIteration=numiterKSVD;
param.preserveDCAtom=0;
param.InitializationMethod='GivenMatrix';param.displayProgress=0;
[aa,bb]=size(I11);

[blocks,idx] = my_im2col(I11,[sqrt(n),sqrt(n)],r); br=mean(blocks); %image patches
    br2 = (ones(n,1))*br;
    TE=blocks-br2;           %subtract means of patches
    [rows,cols] = ind2sub(size(I11)-sqrt(n)+1,idx);
    
    N2=size(blocks,2); %total number of overlapping image patches
    %de=randperm(N2);
    
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