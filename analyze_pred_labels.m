function analyze_pred_labels(SubjectID, sessionN, expType, cfg)


if ~isfield(cfg, 'blockDur')
    cfg.blockDur= 9;			% number of dummy scans to drop
end
%load onsets for subject for session

[sess_onsets, sess_labels]=create_training_ds(SubjectID, sessionN, cfg);

%load predicted labels for subject for session

labels_fname=fullfile(cfg.output, sprintf('pred_labels_%s_%s_%d.mat', SubjectID, expType, sessionN));
load(labels_fname, 'predicted_labels1');
pred_labels=predicted_labels1;
pred_labels=pred_labels';
%pred_labels=str2double(pred_labels);
%for each onset get predicted labels from onset + 9
%load test labels for subject for session; get from onset + 9

testLabels=load_session_labels(SubjectID, sessionN, expType, cfg);
testLabels=str2double(testLabels);
%calculate 1 as correct 0 as no correct for each position

trial_acc=[];
for onset=1:length(sess_onsets)
    myonset=sess_onsets(onset)-cfg.TRtoTake;
    trial=zeros(1, cfg.blockDur);
    if myonset+cfg.blockDur>cfg.NrOfVols-cfg.numDummy;
        testLabels_trial=testLabels(myonset:cfg.NrOfVols-cfg.numDummy);
        predLabels_trial=pred_labels(myonset:cfg.NrOfVols-cfg.numDummy);
        
    else
        testLabels_trial=testLabels(myonset:myonset+cfg.blockDur);
        predLabels_trial=pred_labels(myonset:myonset+cfg.blockDur);
        
    end
    
    for i=1:cfg.blockDur
        if length(testLabels_trial)<i
            testLabels_trial(i)=0;
        end
        
        if length(predLabels_trial)<i
            predLabels_trial(i)=1;
        end
        if cfg.Classifier==1
            if testLabels_trial(i)==str2double(predLabels_trial(i));  % %%predLabels_trial(i) %str2double(predLabels_trial(i))
                trial(i)=1;
            end
        else
            % test labels are double; classifier 1 string to double classifier 2 and 3 labels are double
            if testLabels_trial(i)==predLabels_trial(i);  % %%predLabels_trial(i) %str2double(predLabels_trial(i))
                trial(i)=1;
            end
        end
    end
    trial_acc=[trial_acc; trial];
    
end

%find the mean between trials
accuracy=mean(trial_acc,1);
acc_filename=fullfile(cfg.FeedbackFolder, sprintf('accs_%s_%s_ses%d_classif%d.mat', SubjectID, expType, sessionN, cfg.Classifier));
save(acc_filename, 'accuracy');
fig_filename=fullfile(cfg.output, sprintf('accs_%s_%s_ses%d_classif%d.jpg', SubjectID, expType, sessionN, cfg.Classifier));
h=plot(accuracy);
title(sprintf('Mean acc per vol in a trial ses %d subj %s experiment type %s', sessionN, SubjectID, expType));
xlabel('TR number'); % x-axis label
ylabel(sprintf('Accuracy Classifier %d', cfg.Classifier)); % y-axis label
saveas(h, fig_filename);






