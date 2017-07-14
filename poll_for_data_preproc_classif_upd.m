function poll_for_data_preproc_classif_upd(SubjectID, sessionN, expType, cfg)

% every 2 sec look for a file with a name template in a directory
% send New Data even to the listener
%listener will print got it and the volume number
% expType='Perc'; %'Im'
ft_defaults
%ft_hastoolbox('spm8', 1);
if nargin == 3
    cfg = [];
end
%cfg.inputDir='C:\Documents\realtime\Run2'; %'C:\Users\eust_abbondanza\Documents\realtime\20130429_19720216VLRZ\Ser0001\';

%cfg.output='C:\Documents\realtime'; %'C:\Documents\realtime\TEST\';
% % % cfg.maskpath='C:\Users\eust_abbondanza\Documents\MATLAB\attend'
% % % cfg.datapath='C:\Documents\realtime\';
% % % cfg.protocolpath='C:\Users\eust_abbondanza\Documents\MATLAB\';
%cfg.Classifier=2; %1 for SVM from PR tollbox, 2 for EN classifier
%cfg.blockDurVol=8;
%3; added more because of the block duraton, should do convolution and calculate the delay !!!!!!

%Cfg.name_templates='prepScan_*.nii';
%files = dir(fullfile(Cfg.inputDir,Cfg.name_templates));
%first non-dummy volume

% defaults.normalise.estimate.smosrc  = 8;
% defaults.normalise.estimate.smoref  = 0;
% defaults.normalise.estimate.regtype = 'mni';
% defaults.normalise.estimate.weight  = '';
% defaults.normalise.estimate.cutoff  = 25;
% defaults.normalise.estimate.nits    = 16;
% defaults.normalise.estimate.reg     = 1;
% defaults.normalise.estimate.wtsrc   = 0;
% defaults.normalise.write.preserve   = 0;
% defaults.normalise.write.bb         = [[-90 -126 -72];[90 90 108]]; % new in spm2
% defaults.normalise.write.vox        = [3 3 3];
% defaults.normalise.write.interp     = 1; % perhaps change this???
% defaults.normalise.write.wrap       = [0 0 0];




if ~isfield(cfg, 'numDummy')
    cfg.numDummy = 5;			% number of dummy scans to drop
end

if ~isfield(cfg, 'NrOfVols')
    cfg.NrOfVols=170;
end

if ~isfield(cfg, 'smoothFWHM')
    cfg.smoothFWHM = 0; %8;
end

if ~isfield(cfg, 'correctMotion')
    cfg.correctMotion = 1; %1;
end

if ~isfield(cfg, 'normalize2EPI')
    cfg.normalize2EPI = 0; %1;
end

if ~isfield(cfg, 'correctSliceTime')
    cfg.correctSliceTime = 1; %1;
end

if ~isfield(cfg, 'maskpath')
    cfg.maskpath='C:\Users\eust_abbondanza\Documents\MATLAB\attend';
end

if ~isfield(cfg, 'Classifier')
    cfg.Classifier=1; %1 for SVM from PR tollbox, 2 for EN classifier
end

if ~isfield(cfg, 'whichEcho')
    cfg.whichEcho = 1;
else
    if cfg.whichEcho < 1
        error '"whichEcho" configuration field must be >= 1';
    end
end
correct     = [];
predicted_labels1    = [];
predicted_labels2=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TODO LATER %%%%%%%%%%%%%%%%%
%Training data, all the data of the completed runs, added one by one, only volume 4 of each trial
%training_labels= %training labels, same, the labels for all completed runs
%mask_name=fullfile(cfg.maskpath, 'rwOSC.625.nii'); % mask is in the model folder

%various masks
%mask_name=fullfile(cfg.maskpath, 'rwMNI_Occipital_Mid_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'rwMNI_Occipital_Mid_L_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'rwMNI_Occipital_Inf_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'rwMNI_Occipital_Inf_L_roi.nii');

%mask_name=fullfile(cfg.maskpath, 'rwMNI_Temporal_Mid_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'rwMNI_Temporal_Mid_L_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'rwMNI_Temporal_Inf_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'rwMNI_Temporal_Inf_L_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'rwMNI_Temporal_Sup_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'rwMNI_Temporal_Sup_L_roi.nii');

%mask_name=fullfile(cfg.maskpath, 'rwMNI_Fusiform_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'rwMNI_Fusiform_L_roi.nii');

%param = spm_normalise(cfg.mytemplate, cfg.ref_image, cfg.matname, defaults.normalise.estimate.weight,'',defaults.normalise.estimate);


maskvol_hdr=spm_vol(cfg.mask_name);
maskvol_vol=spm_read_vols(maskvol_hdr);
if sessionN>1
    
    
    %%%   [training_data, training_labels]=train_classifier(SubjectID, sessionN, cfg);
    
    predicted_labels1 = [];
    predicted_labels2=[];
    
    switch cfg.ExpType
        case 'PercIm'
    testLabels=load_session_labels(SubjectID, sessionN, expType, cfg);
        case 'VS'
            
      testLabels=load_session_labels_vs(SubjectID, sessionN, expType, cfg);
        case 'MOPS'
            testLabels=load_session_labels_mops(SubjectID, sessionN, cfg);
    end
    
    
    classif_time=tic;
    
    
    classif_template=sprintf('Classifier_%d.mat', cfg.Classifier);
    target=dir(fullfile(cfg.output,classif_template));
    
    if isempty(target)
        fprintf('\nNo trained classifier found, will train one .. \n');
        
        
        
        if cfg.multiSubj==1
            [mymin, myrange, training_data, training_labels]=train_multisubj_classifier(sessionN, cfg);
        elseif strcmp(expType, 'MOPS')
        
             [mymin, myrange, training_data, training_labels]=train_classifier_mops(SubjectID, sessionN, cfg);
          %%%    [training_data, training_labels]=train_classifier_mops_corr(SubjectID, sessionN, cfg);
          %   [mymin, myrange, training_data, training_labels]=train_classifier_mops_corr(SubjectID, sessionN, cfg);
        else
            [mymin, myrange, training_data, training_labels]=train_classifier(SubjectID, sessionN, cfg);
            
        end
        switch cfg.Classifier
            case 1
                training_labels=arrayfun(@num2str, training_labels, 'UniformOutput', false);
                A = dataset(training_data, training_labels');
                %[W, kernel, nu] = rbsvc(A); %W=nusvc(A); %W=svc(A, 'p', 2);
                W=svc(A, 'p', 2);
                %   W=nusvc(A,'r',1);
                
                
                fprintf('\nprSVM classifier trained in %d sec...\n', toc(classif_time));
            case 2
                [mdl, cfs]=train_EN_logreg(training_data, training_labels');
                %cfs=train_EN_logreg(training_data, training_labels');
                fprintf('\nElastic net classifier trained in %d sec...\n', toc(classif_time));
                
            case 3
                
                %    training_labels=arrayfun(@num2str, training_labels, 'UniformOutput', false);
                [myc, myg]= libsvm_param_selection(training_data, training_labels);
                params=sprintf('-s 1 -t 0 -g %d -c %d -q', myg, myc);
                model = svmtrain(double(training_labels), double(training_data), params); %'-s 1 -t 2 -g myg -c myc -q'); % '-s 1 -t 0 -g 1 -c 10-q'
                
                fprintf('\nlibSVM classifier trained in %d sec...\n', toc(classif_time));
                
                
            case 4
                options.alpha =  0.9;
                fit = cvglmnet(training_data, training_labels, 'binomial', options);
                
        end
        
        
    else
        
        classif_file=fullfile(cfg.output,classif_template);
        load(classif_file);
        switch cfg.Classifier
            case 1
                
                W=weights;
                
            case 2
                
                mdl=regr_model;
                cfs=coefs;
                
            case 3
                
                model=libsvm_model;
                
            case 4
                
                fit=regression_fit;
        end
        
    end
 
    
end

hist_file=fullfile(cfg.output, sprintf('history_%s.mat', SubjectID));
if ~exist(hist_file, 'file')
    history = struct('S',[], 'RRM', [], 'motion', []);
else
    
    load(hist_file);
end

numTotal=cfg.numDummy+1;
numTrial = (cfg.NrOfVols-cfg.numDummy)*(sessionN-1);
numProper = 0;
motEst = [];


while 1 %length(files)
    waiting_time=0;
    
    GrabVol=tic;
    pause(0.25);
    %  for dicom distorion corrected
    %%%%%%%%% name_template=sprintf('f19881103CARV-0020-%05d*.hdr', numTotal); %% 10, 18 %% 7 12 16 20
    % name_template=sprintf('prepScan_%d.nii', numTotal);
    name_template=sprintf('Analyze%05d.hdr', numTotal);
    %start timer
    
    %after 1.5 sec check if there is a volume with a number
    
    %close timer
    target=dir(fullfile(cfg.inputDir,name_template));
    
    if isempty(target)
        fprintf('\nNo new data\n');
        time=toc(GrabVol);
        waiting_time=waiting_time +time;
        
        if waiting_time>cfg.TimeOut
            fname_hist=fullfile(cfg.output, sprintf('history_%s.mat', SubjectID));
            save(fname_hist, 'history');
            fname_labels=fullfile(cfg.output,sprintf('pred_labels_%s_%s_%d.mat', SubjectID, expType, sessionN));
            save(fname_labels, 'predicted_labels1', 'predicted_labels2');
            break
        end
    else
        %  notify(H, 'NewData');
        fprintf('\nAvailable volume %i\n', numTotal)
        filename1=fullfile(cfg.inputDir,target.name);
        %%%   filename1=fullfile(cfg.inputDir,name_template);
        vol_hdr=spm_vol(filename1);
        %         vol_vol=spm_read_vols(vol_hdr);
        %         dat=vol_vol(maskvol_vol>0);
        %  dat=spm_read_vols(vol_hdr);
        
        rawScan=spm_read_vols(vol_hdr);
        
        
        S=[];
        S.TR=cfg.TR;
        S.voxdim=double([3.0000 3.0000 3.600]); %vol_hdr.pixdim(1:3)
        S.voxels=vol_hdr.dim;
        S.mat0=vol_hdr.mat;
        S.numEchos=1;
        S.vx=vol_hdr.dim(1);
        S.vy=vol_hdr.dim(2);
        S.vz=vol_hdr.dim(3);
        inds=[(2:2:S.vz) (1:2:S.vz) ];
        S.deltaT = (0:(S.vz-1))*S.TR/S.vz;
        S.deltaT(inds) = S.deltaT;
        
        if isempty(S)
            warning('No protocol information found!')
            % restart loop
            pause(0.5);
            continue;
        end
        
        if cfg.whichEcho > S.numEchos
            warning('Selected echo number exceeds the number of echos in the protocol.');
            grabEcho = S.numEchos;
            fprintf(1,'Will grab echo #%i of %i\n', grabEcho, S.numEchos);
        else
            grabEcho = 1;
        end
        
        % Prepare smoothing kernels based on configuration and voxel size
        if cfg.smoothFWHM > 0
            [smKernX, smKernY, smKernZ, smOff] = ft_omri_smoothing_kernel(cfg.smoothFWHM, S.voxdim); %ft_omri_smoothing_kernel(cfg.smoothFWHM, S.voxdim);
            smKern = convn(smKernX'*smKernY, reshape(smKernZ, 1, 1, length(smKernZ)));
        else
            smKernX = [];
            smKernY = [];
            smKernZ = [];
            smKern  = [];
            smOff   = [0 0 0];
        end
        
        
        
        % store current info structure in history
        numTrial  = numTrial + 1;
        history(numTrial).S = S;
        disp(S)
        
        fprintf(1,'Starting to process\n');
        %  numTotal  = cfg.numDummy * S.numEchos;
        
        
        % Loop this as long as the experiment runs with the same protocol (= data keeps coming in)
        
        % determine number of samples available in buffer / wait for more than numTotal
        %    threshold.nsamples = numTotal + S.numEchos - 1;
        
        %CHECK FUNCTION !!!!!!!!!!!!!!!
        % % %             newNum = ft_poll_buffer(cfg.input, threshold, 500);
        % % %
        % % %             if newNum.nsamples < numTotal
        % % %                 % scanning seems to have stopped - re-read header to continue with next trial
        % % %                 break;
        % % %             end
        % % %             if newNum.nsamples < numTotal + S.numEchos
        % % %                 % timeout -- go back to start of (inner) loop
        % % %                 continue;
        % % %             end
        % % %
        % % %             % this is necessary for ft_read_data
        % % %             hdr.nSamples = newNum.nsamples;
        % % %
        index = (cfg.numDummy + numProper) * S.numEchos + grabEcho;
        fprintf('\nTrying to read %i. proper scan at sample index %d\n', numProper+1, index);
        GrabSampleT = tic;
        
        % % %             try
        % % %                 % read data from buffer (only the last scan)
        % % %                 dat = ft_read_data(cfg.input, 'header', hdr, 'begsample', index, 'endsample', index);
        % % %             catch
        % % %                 warning('Problems reading data - going back to poll operation...');
        % % %                 continue;
        % % %             end
        
        numProper = numProper + 1;
        
        
        %        rawScan = single(reshape(dat, S.voxels));
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % slice timing correction
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if cfg.correctSliceTime
            if numProper == 1
                fprintf(1,'Initialising slice-time correction model...\n');
                STM = ft_omri_slice_time_init(rawScan, S.TR, S.deltaT);
            else
                fprintf('%-30s','Slice time correction...');
                tic;
                [STM, procScan] = ft_omri_slice_time_apply(STM, rawScan);
                toc
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % motion correction
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if cfg.correctMotion
            doneHere = 0;
            hist_file=fullfile(cfg.dataPath, sprintf('history_%s.mat', SubjectID));
            if numProper == 1
                
                if ~exist(hist_file, 'file')
                    history = struct('S',[], 'RRM', [], 'motion', []);
                    RRM = [];
                else
                    
                    load(hist_file);
                    
                    
                    for i=1:length(history)
                        if isequal(history(i).S, S)
                            fprintf(1,'Will realign scans to reference model from trial %d session 1 ...\n', i);
                            % protocol the same => re-use realignment reference
                            RRM = history(i).RRM;
                            break;
                        end
                    end
                end
                % none found - setup new one
                if isempty(RRM)
                    flags = struct('mat', S.mat0);
                    fprintf(1,'Setting up first num-dummy scan as reference volume...\n');
                    RRM = ft_omri_align_init(rawScan, flags);
                    history(numTrial).RRM = RRM;
                    curSixDof = zeros(1,6);
                    motEst = zeros(1,6);
                    procScan = single(rawScan);
                    doneHere = 1;
                end
            end
            
            if ~doneHere
                fprintf('%-30s','Registration...');
                tic;
                [RRM, M, Mabs, procScan] = ft_omri_align_scan(RRM, rawScan);
                toc
                curSixDof = hom2six(M);
                motEst = [motEst; curSixDof.*[1 1 1 180/pi 180/pi 180/pi]];
            end
        else
            procScan = single(rawScan);
            motEst = [motEst; zeros(1,6)];
        end
        
        
        %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         % slice timing correction
        %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         if cfg.correctSliceTime
        %             if numProper == 1
        %                 fprintf(1,'Initialising slice-time correction model...\n');
        %                 STM = ft_omri_slice_time_init(procScan, S.TR, S.deltaT);
        %             else
        %                 fprintf('%-30s','Slice time correction...');
        %                 tic;
        %                 [STM, procScan] = ft_omri_slice_time_apply(STM, procScan);
        %                 toc
        %             end
        %         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % smoothing
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if cfg.smoothFWHM > 0
            fprintf('%-30s','Smoothing...');
            tic;
            % MATLAB convolution
            %Vsm = convn(procScan,smKern);
            %procScan = Vsm((1+smOff(1)):(end-smOff(1)), (1+smOff(2)):(end-smOff(2)), (1+smOff(3)):(end-smOff(3)));
            
            % specialised MEX file
            procScan = ft_omri_smooth_volume(single(procScan), smKernX, smKernY, smKernZ);
            
            toc
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % done with pre-processing, write output
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if cfg.correctMotion
            procSample = [single(procScan(:)) ; single(curSixDof')];
        else
            procSample = single(procScan(:));
            %     procSample = procScan(:);
        end
        %%%%%%%%%%%%%%for dicom no flipping !!!!!!!!!!!!
  % if  cfg.normalize2MNI==0
        procScan=flip(procScan, 2);
  % end
        filename=sprintf('prepScan_%i.nii', numProper);
        V=[];
        
        run_path=sprintf('%s\\Ser%04d', cfg.dataPath, sessionN);
        if ~exist(run_path, 'dir')
            mkdir(run_path)
        end
        
        %         if cfg.normalize2MNI==0
        %              procScan=flip(procScan, 2);
        %         end
        %
        
        
        V.fname=fullfile(run_path, filename);
        V.pixdim=S.voxdim;
        V.dt=[4 0];
        V.x=S.vx;
        V.y=S.vy;
        V.z=S.vz;
        V.mat=S.mat0;
        V.dim=S.voxels;
        %      V.size=S.size;
        %       V.numEchos=S.numEchos;
        V.TR=S.TR;
        %     V.deltaT=S.deltaT;
        V.n=[1 1];
        V.pinfo=[1  0 352]';
        V=spm_create_vol(V);
        spm_write_vol(V, procScan); %spm_create_vol
        
        
        %      filename1=fullfile(run_path, sprintf('wrprepScan_%i.nii', numProper);
        
        
        %  V=spm_vol(Analyze_file)
        %  V=spm_write_vol(V, procScan)
        
        
        %            ft_write_data(cfg.output1, procSample, 'header', hdrOut, 'append', true);
        
        
        %evr.sample = numProper;
        %ft_write_event(cfg.output, evr);
        
        fprintf('Done -- total time = %f\n', toc(GrabSampleT));
        
        
        
        if cfg.normalize2MNI==1
            param=load(cfg.matname);
            spm_write_sn(V.fname,param);
            procScan1_hdr=spm_vol(fullfile(run_path, sprintf('wprepScan_%d.nii', numProper)));
            procScan1=spm_read_vols(procScan1_hdr);
            
              testSample=procScan1(maskvol_vol>cfg.maskThreshold)';
         %   testSample=scaledata((procScan1(maskvol_vol>cfg.maskThreshold))', 0, 1);
          
         %%%%various ways of normalizing
     %%%%    testSample=(testSample-mean(testSample))/std(testSample);
     %%% scaling - find me
         %%%%  testSample=(testSample-mymin)/myrange; 
        else
            
            %       procScan=flip(procScan, 2);
        %    testSample=scaledata((procScan(maskvol_vol>cfg.maskThreshold))', 0, 1);
        testSample=procScan(maskvol_vol>cfg.maskThreshold)';
                
        %%%%various ways of normalizing
      %%%%   testSample=(testSample-mean(testSample))/std(testSample);
      
      %%% scaling - find me 
           testSample=(testSample-mymin)/myrange; 
        
        end
        
        % testSample=double(procScan);
        % testLabel=labels(numProper)
        %TODO later LR+EN
        %  predicted_label=simulate_response_model(classifier, testSample)
        
        %    if str2double(testLabel)>=0
        if sessionN>1
            switch cfg.Classifier
                case 1
                    B   = dataset(double(testSample));
                    Bc  = B*W;
                    estimate = labeld(Bc)
                    predicted_labels1=vertcat(predicted_labels1, estimate);
                    correct(end+1) = (str2double(estimate)==str2double(testLabels(numProper)));%str2num(testLabel)
                    %  correct(end+1) = (estimate==str2double(testLabels(numTotal)));%str2num(testLabel)
                case 2
                    test_label1 = predict(mdl,testSample);
                    %                     if test_label1>0.5
                    %                         estimate=1;
                    %                     else
                    %                         estimate=0;
                    %                     end
                    %                   predicted_labels1=vertcat(predicted_labels1, estimate);
                    %  test_label1=glmval(cfs, testSample, 'logit');
                    
                    if test_label1>0.5
                        estimate=1;
                    else
                        estimate=0;
                    end
                    
                    correct(end+1) = (estimate==str2double(testLabels(numProper)));
                    %if test_label2>0.5
                    %   estimate=1;
                    % else
                    %   estimate=0;
                    %end
                    predicted_labels1=vertcat(predicted_labels1, estimate);
                    %correct(end+1) = (estimate==str2double(testLabels(numTotal)));
                    
                case 3
                    
                    estimate = svmpredict(str2double(testLabels(numProper)), double(testSample), model); %double(0)
                    predicted_labels1=vertcat(predicted_labels1, estimate);
                    correct(end+1) = (estimate==str2double(testLabels(numProper)));
                    
                case 4
                    
                    estimate=cvglmnetPredict(fit, testSample, 0.25, 'class');
                    testLabels(numProper);
                    predicted_labels1=vertcat(predicted_labels1, estimate);
                    correct(end+1) = (estimate==str2double(testLabels(numProper)));
                    %                     estimate(1)
                    %                     estimate(100)
                    
                    
                case 5
                    
                    %  estimate = cosmo_classify_lda(training_data, training_labels, testSample);
                    %   estimate = cosmo_classify_nn(training_data, training_labels, testSample);
                    %   estimate = cosmo_classify_knn(training_data, training_labels, testSample);
                    %  estimate = cosmo_classify_svm(double(training_data), double(training_labels), double(testSample));
                    
                    estimate = cosmo_classify_naive_bayes(training_data, training_labels, testSample);
                    
                    %   estimate = cosmo_classify_selective_naive_bayes(training_data, training_labels, testSample);
                    
                    % estimate = cosmo_classify_matlabsvm(double(training_data), double(training_labels), double(testSample));
                    %  if matlabsvm is to be used libsvm should be removed from
                    %  matlab path
                    predicted_labels1=vertcat(predicted_labels1, estimate);
                    correct(end+1) = (estimate==str2double(testLabels(numProper)));
                    
                    
            end
            %       str2double(testLabels(numTotal))
            %for logistic regression
            
            %for svm
            %
            acc(numTotal)=round(mean(correct)*100);
            
            
            subplot(5,1,1);
        plot(motEst(:,1:3));
        subplot(5,1,2);
        plot(motEst(:,4:6));
        
        subplot(5,1,3);
        %  slcImg = reshape(dat, [S.vx	S.vy*S.vz]);
        slcImg = reshape(rawScan, [S.vx	S.vy*S.vz]);
        imagesc(slcImg);
        colormap(gray);
        
        subplot(5,1,4);
        slcImg = reshape(procScan, [S.vx	S.vy*S.vz]);
        imagesc(slcImg);
        colormap(gray);
        
        subplot(5,1,5);
        plot(1:numTotal, acc(1:numTotal))
        
        
        % force Matlab to update the figure
        drawnow
        
            
            fprintf('classification rate = %d%%\n', round(mean(correct)*100));
        end
        
        %CREATE SUBJ Folder AND WRITE  ATEXT FILE !
        if cfg.Feedback==1
            fname_classif=fullfile(cfg.FeedbackFolder, sprintf('pred_labels_%s_%s_%d.mat', SubjectID, expType, sessionN));
            save(fname_classif, 'predicted_labels1');
            %             if cfg.Classifier==1
            %                 estimate=str2double(estimate);
            %                 save(fname_classif, estimate)
            %             else
            %                 save(fname_classif, 'estimate')
            %             end
            %
        end
        fprintf('Volume processed in %f\n', toc(GrabVol));
        if numTotal==cfg.NrOfVols
            
            fname_hist=fullfile(cfg.dataPath, sprintf('history_%s.mat', SubjectID));
            save(fname_hist, 'history');
            fname_labels=fullfile(cfg.output, sprintf('pred_labels_%s_%s_%d.mat', SubjectID, expType, sessionN));
            save(fname_labels, 'predicted_labels1');
            
            break;
        else
            numTotal  = numTotal + S.numEchos;
            
        end
        
        % time=toc;
        %write event
        %addlistener(input_dir_search,'NewVol',my_omri_pipeline) %the listener gets the signal and starts the preprocessing, event.listener
        
        %read event and print data received
    end
end
