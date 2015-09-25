function prediction = test_ENClassifier
tic;
subjectID='GBTE'; 
rN=4;
factorLevels=[4 2 2];
datapath='C:\Documents\realtime\Run3';
maskpath='C:\Users\eust_abbondanza\Documents\MATLAB\attend';
protocolpath='C:\Users\eust_abbondanza\Documents\MATLAB\';
inputDir='C:\Documents\realtime\Run4';
mask_name=fullfile(maskpath, 'rwOSC.625.nii'); % mask is in the model folder
maskvol_hdr=spm_vol(mask_name);
maskvol_vol=spm_read_vols(maskvol_hdr);
[onsets, training_labels]=create_training_ds(subjectID, rN-1);
%training_labels=training_labels';
for n=1:length(onsets)
    myfile=sprintf('prepScan_%i.nii', onsets(n));
    fname=fullfile(datapath, myfile);
    vol_hdr=spm_vol(fname);
    vol_vol=spm_read_vols(vol_hdr);
    vol_vol=vol_vol(maskvol_vol>0);%reshape(vol_vol, 1, numel(vol_vol));
    training_data(n, :)=vol_vol;
end


% prname=sprintf('%s-%i.trd', subjectID, rN);
% fname = fullfile(protocolpath, prname);
% fid = fopen(fname, 'rt');
% counter = 0;
% aline = fgetl(fid);
% while ~feof(fid)
%     aline = fgetl(fid);
%     counter = counter + 1;
%     numLine = str2num(aline);
%     nElements = length(numLine);
%     res(counter, 1:nElements) = numLine;
%     
% end
% fclose(fid);
% code = res(:, 1);
% faccombination = ASF_decode(code, factorLevels);
% condVec=faccombination(:, 3);
% labels=faccombination(:, 2);
% labels(condVec==-1)=-1;
% labels=repmat(labels, 1, cfg.blockDurVol);
% timings=round((res(:, 2)*1000)/cfg.TRms)-cfg.numDummy;
% timings=repmat(timings, 1, cfg.blockDurVol);
% labels=reshape(labels', 1, numel(labels));
% timings=reshape(timings', 1, (numel(timings)));
% labels=arrayfun(@num2str, labels, 'UniformOutput', false);



%load the data
% load ionosphere
% Ybool = strcmp(Y,'g');
% X = X(:,3:end);
%X should be the data matrix, y the labels=response
%rng('default') % for reproducibility
%[B,FitInfo] = lassoglm(X,Ybool,'binomial',...
%    'NumLambda',25,'CV',10);
%[B,FitInfo] = lassoglm(X,y,'binomial','NumLambda',100, ...
 % 'Alpha',0.9,'LambdaRatio',1e-4,'CV',10,'Options',opt);

%[z, mu, sigma]=zscore(double(training_data));

[B,FitInfo] = lassoglm(training_data,training_labels,'binomial','NumLambda',100, 'Alpha',0.9,'LambdaRatio',1e-4,'CV', 10); %, 'Standardize',false);

%[B,FitInfo] = lassoglm(training_data, training_labels,'binomial');


%

% lassoPlot(B,FitInfo,'PlotType','CV');
% lassoPlot(B,FitInfo,'PlotType','Lambda','XScale','log');

indx = FitInfo.Index1SE;
B0 = B(:,indx);
nonzeros = sum(B0 ~= 0);

cnst = FitInfo.Intercept(indx);
B1 = [cnst;B0];

%preds = glmval(B1,training_data,'logit');
% histogram(training_labels - preds); % plot residuals
% title('Residuals from lassoglm model')

predictors = find(B0); % indices of nonzero predictors
mdl = fitglm(training_data,training_labels,'linear',...
    'Distribution','binomial','PredictorVars',predictors);
time=toc
predicted_label1=zeros(1, 57);
predicted_label2=zeros(1, 57);
for i=1:170
    
     name_template=sprintf('prepScan_%i.nii', i);
    %start timer
    
    %after 1.5 sec check if there is a volume with a number
    
    %close timer
    fnametest=fullfile(inputDir,name_template);
    test_vol=spm_vol(fnametest);
    test_sample=spm_read_vols(test_vol);
    test_sample=test_sample(maskvol_vol>0)';

test_label1 = predict(mdl,test_sample)
if test_label1>0.5
    predicted_label1(i)=1;
else
    predicted_label1(i)=0;
end
    
test_label2=glmval(B1, test_sample, 'logit')

if test_label2>0.5
    predicted_label2(i)=1;
else
    predicted_label2(i)=0;
end

end
predicted_label1;
predicted_label2;

%This function should return model mdl and B1
