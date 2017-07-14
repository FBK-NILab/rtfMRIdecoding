function just_classify(SubjectID, sessionN, expType, cfg)

% every 2 sec look for a file with a name template in a directory
% send New Data even to the listener 
%listener will print got it and the volume number

if nargin <4
    cfg=[];
    cfg.dataPath='C:\Documents\realtime\';
    cfg.protocolPath='C:\Documents\realtime\';
    cfg.maskPath='C:\Documents\realtime\';
    cfg.mask_name='OSC.625.nii';
    cfg.maskThreshold=0;
    cfg.NrOfVols=305;
    cfg.TimeOut=6.0;
    cfg.normalize2MNI = 1;
    cfg.Classifier=2;
    cfg.multiSubj=0;
    cfg.MultiSubjectID={'20150717IGDB', '20150717ANSN', '20150806PMMN'};
end
% Cfg.inputDir='C:\Documents\realtime\Run2';
% Cfg.NrOfVols=100;
% Cfg.TimeOut=6.0;
%Cfg.name_templates='prepScan_*.nii';
%files = dir(fullfile(Cfg.inputDir,Cfg.name_templates));
i=1;
waiting_time=0;
correct     = [];
predicted_labels1    = [];
predicted_labels2=[];

if cfg.multiSubj==1
    [training_data, training_labels]=train_multisubj_classifier(sessionN, cfg);
else
    [training_data, training_labels]=train_classifier(SubjectID, sessionN, cfg);
end

testLabels=load_session_labels(SubjectID, sessionN, expType, cfg);
classif_time=tic;
switch cfg.Classifier
    case 1
        training_labels=arrayfun(@num2str, training_labels, 'UniformOutput', false);
        A = dataset(training_data, training_labels);
        W = svc(A);
        fprintf('\nprSVM classifier trained in %d sec...\n', toc(classif_time));
    case 2
        [mdl, cfs]=train_EN_logreg(training_data, training_labels');
        %cfs=train_EN_logreg(training_data, training_labels');
        fprintf('\nElastic net classifier trained in %d sec...\n', toc(classif_time));
        
    case 3
        
        %    training_labels=arrayfun(@num2str, training_labels, 'UniformOutput', false);
        model = svmtrain(double(training_labels), double(training_data), '-s 1 -t  2 -c 0.1 -q'); % '-s 1 -t 0 -q'
        
        fprintf('\nlibSVM classifier trained in %d sec...\n', toc(classif_time));
        
        
    case 4
        options.alpha =  0.9;
        fit = cvglmnet(training_data, training_labels, 'binomial', options);
        
        
end




while 1 %length(files)
    
    tic
    pause(1.0);
    
    if cfg.normalize2MNI == 0;
        name_template=sprintf('prepScan_%i.nii', i);
        
    else
        if cfg.normalize2MNI == 1;
            
            name_template=sprintf('wprepScan_%i.nii', i);
            
        end
    end
    
    maskvol_hdr=spm_vol(cfg.mask_name);
    maskvol_vol=spm_read_vols(maskvol_hdr);
    %start timer
    
    %after 1.5 sec check if there is a volume with a number
    
    %close timer
    target=dir(fullfile(cfg.dataPath, sprintf('Ser000%d', sessionN), name_template));
    
    if isempty(target)
        fprintf('\nNo new data\n');
        time=toc
        waiting_time=waiting_time +time
        %         s==GetSecs;
        if waiting_time>cfg.TimeOut
            break
        end
    else
        %  notify(H, 'NewData');
        fprintf('\nAvailable volume %i\n', i)
        target_file=fullfile(cfg.dataPath, sprintf('Ser000%d', sessionN), name_template);
        spm_vol_hdr=spm_vol(target_file);
        spm_vol_vol=spm_read_vols(spm_vol_hdr);
        testSample=spm_vol_vol(maskvol_vol>cfg.maskThreshold);
        testSample=(scaledata(testSample, 0, 1))';
        %%%%%%%%%%% training classifier %%%%%%%%%%%%%%
        
        
       
        
        %%%%%%%%%%%%%% CLASSIFY %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        switch cfg.Classifier
            case 1
                B   = dataset(double(testSample));
                Bc  = B*W;
                estimate = labeld(Bc);
                predicted_labels1=vertcat(predicted_labels1, estimate);
                correct(end+1) = (str2double(estimate)==str2double(testLabels(i)));%str2num(testLabel)
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
                
                correct(end+1) = (estimate==str2double(testLabels(i)));
                %if test_label2>0.5
                %   estimate=1;
                % else
                %   estimate=0;
                %end
                predicted_labels1=vertcat(predicted_labels1, estimate);
                %correct(end+1) = (estimate==str2double(testLabels(numTotal)));
                
            case 3
                
                estimate = svmpredict(str2double(testLabels(i)), double(testSample), model); %double(0)
                predicted_labels1=vertcat(predicted_labels1, estimate);
                correct(end+1) = (estimate==str2double(testLabels(i)));
                
            case 4
                
                estimate=cvglmnetPredict(fit, testSample, 0.25, 'class');
                testLabels(i);
                predicted_labels1=vertcat(predicted_labels1, estimate);
                correct(end+1) = (estimate==str2double(testLabels(i)));
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
                correct(end+1) = (estimate==str2double(testLabels(i)));
                
                
        end
        if cfg.Classifier==1
            fprintf('label vol %d = %s \n', i, estimate); % %s for string labels
        else
            fprintf('label vol %d = %d \n', i, estimate); % %d for double labels
        end
      
    
    if i==cfg.NrOfVols
        
        fname_labels=fullfile(cfg.output, sprintf('pred_labels_%s_%s_%d.mat', SubjectID, expType, sessionN));
            save(fname_labels, 'predicted_labels1');
        
        break;
    else
        i=i+1;
    end
end
% time=toc;
%write event
%addlistener(input_dir_search,'NewVol',my_omri_pipeline) %the listener gets the signal and starts the preprocessing, event.listener

%read event and print data received
end

