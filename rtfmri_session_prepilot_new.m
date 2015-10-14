%% Preparatory part

clear all
clear classes
SubjectID='CARV';

UseASFV52;% CHECK FILE NAME !!

%% create 4 trds 1 for each session - you can configure the number of sessions
%COPY THEM TO THE STIMULATION MACHINE

% makeTRD_perception_rt(SubjectID, 1);
% makeTRD_perception_rt(SubjectID, 2);
% makeTRD_imagery_rt(SubjectID, 3);
% makeTRD_imagery_rt(SubjectID, 4);


%% Functional perception run 1 + retrain classifier

%Analyze output and show accuracy
%CHECK FILENAME IN THE PREPROC_CLASSIF FILE !!
cfg=[];
session=1;
disk='C:\Documents\RealTime\';
accessN='201509301220'; 
subjectCode='20150930CARV'; 
%%%%%%%%%%% paths 1st Run rakes from input run 1 puts into data path run 1
cfg.inputDir=sprintf('%s%s\\Ser%04d', disk, accessN, session); %'C:\Documents\RealTime\201509301130\Ser0001'; %'C:\Documents\RealTime\20150930MCBL\DiCo_1\'% % DISK Z:\
cfg.output=sprintf('%s%s\\', disk, subjectCode); %'C:\Documents\RealTime\20150930MCBL\'; %DISK C:\ NO RUN FOLDERS, THIS IS WHERE HISTORY AND PREDICTIONS ARE SAVED
cfg.dataPath=sprintf('%s%s\\', disk, subjectCode); % DISK C:\ ETC THIS ONE SHOULD HAVE RUNS IN IT !!! where the classifier takes them to be trained

%%%%%%%%%%%%% general session options
cfg.NrOfVols=305;
cfg.TimeOut=15.0;
cfg.TR=2;
cfg.numDummy=5;
cfg.blockDur=9;
Cfg.feedbackOnPage=nan;

%%%%%%%%%%%% preprocessing options
cfg.smoothFWHM = 0;
cfg.correctMotion = 1;
cfg.normalize2MNI = 0;
cfg.correctSliceTime = 1;
%%%%%%%%%%%
poll_for_data_preproc(SubjectID, 1, cfg);
%poll_for_data_preproc_ses1_version1(SubjectID, 1, cfg);

%% MASK

SubjectID='CARV';
cfg=[];


session=1;
disk='C:\Documents\RealTime\';
accessN='201509301220'; 
subjectCode='20150930CARV'; 
%%%%%%%%%%% paths 1st Run rakes from input run 1 puts into data path run 1

cfg.output=sprintf('%s%s\\', disk, subjectCode); %'C:\Documents\RealTime\20150930MCBL\'; %DISK C:\ NO RUN FOLDERS, THIS IS WHERE HISTORY AND PREDICTIONS ARE SAVED
cfg.dataPath=sprintf('%s%s\\', disk, subjectCode); % DISK C:\ ETC THIS ONE SHOULD HAVE RUNS IN IT !!! where the classifier takes them to be trained
cfg.maskpath=sprintf('%s%s\\', disk, subjectCode); 
cfg.protocolpath=sprintf('%s%s\\', disk, subjectCode); %sprintf('%sPROTOCOLS\\'); 'C:\Documents\RealTime\20150930MCBL\';

cfg.numDummy=5;
cfg.TRtoTake= 3; 
%cfg.subjBirthdate='19881016';
%obtain_mask_spm_epi(SubjectID, cfg);


obtain_mask_spm_epi_test(SubjectID, cfg);
%obtain_mask_spm_epi_anat(SubjectID, cfg);

%if instead of mask we normalize
% 1 calculate mean image with Imcalc mean.hdr saved in the subj outputdir
% write data into matrix !!!!!!!!!
% normalize with est&write using mean as ref image

%TODO: online GLM and contrast analysis to identify voxels = mask

%here: 1) get onsets for each condition 2) run specify 1st level 3) results
%- estimate model - contrast threshold=0.03, voxels=30 save the file. but
%it is going to be saved in the session folder so in the mask path it is
%necessary to indicate the session folder no just the subject path

create_spm_design(SubjectID, 1, cfg);


%% Functional perception run 2 + retrain classifier
SubjectID='CARV';
cfg.MultiSubjectID={'20150717IGDB', '20150717ANSN', '20150806PMMN'}; %'20150806MCBL','20150717OIFR',
UseASFV52;

%%%%%General experiment options
cfg.multiSubj=0;
cfg.Feedback=0;
cfg.voxelSelection=1; %1 for group  maps, 2 for spm contrast clusters
%%%%%%%%%%%%% paths Run 2 rakes from input run 2 puts into data path run 2
session=2;
disk='C:\Documents\RealTime\';
accessN='201509301220'; 
subjectCode='20150930CARV'; 
%%%%%%%%%%% paths 1st Run rakes from input run 1 puts into data path run 1
cfg.inputDir=sprintf('%s%s\\Ser%04d', disk, accessN, session); %'C:\Documents\RealTime\201509301130\Ser0001'; %'C:\Documents\RealTime\20150930MCBL\DiCo_1\'% % DISK Z:\
cfg.output=sprintf('%s%s\\', disk, subjectCode); %'C:\Documents\RealTime\20150930MCBL\'; %DISK C:\ NO RUN FOLDERS, THIS IS WHERE HISTORY AND PREDICTIONS ARE SAVED
cfg.dataPath=sprintf('%s%s\\', disk, subjectCode); % DISK C:\ ETC THIS ONE SHOULD HAVE RUNS IN IT !!! where the classifier takes them to be trained
cfg.maskpath=sprintf('%s%s\\', disk, subjectCode); 
cfg.protocolpath=sprintf('%s%s\\', disk, subjectCode); %sprintf('%sPROTOCOLS\\'); 'C:\Documents\RealTime\20150930MCBL\';

if cfg.multiSubj==1;
    cfg.protocolpath='C:\Documents\RealTime\PROTOCOLS\'; % to put the current subject's protocols there too !!!!!!!!!
end
cfg.NrOfVols=305;
cfg.TimeOut=15.0;
cfg.TR=2;
cfg.numDummy=5;
cfg.blockDur=9;

if cfg.Feedback==1
    cfg.FeedbackFolder='C:\Users\tbv\Documents\TBVData\NeuroFeedbackData\ATTEND';
    mkdir(fullfile(cfg.FeedbackFolder, SubjectID));
    
else
    
    cfg.FeedbackFolder='C:\Documents\RealTime\PROTOCOLS\';
end
%%%%%%%%%%%%normalization options %%%%%%%
cfg.mytemplate='C:\Users\eust_abbondanza\Documents\MATLAB\spm8\templates\EPI.nii';
cfg.matname=fullfile(cfg.dataPath, 'mean_sn.mat');
cfg.ref_image=fullfile(cfg.dataPath, 'mean.hdr');
%%%%%%%%%%%

%%%%%%%%%%%% preprocessing options
cfg.smoothFWHM = 0;
cfg.correctMotion = 1;
cfg.normalize2MNI = 0;
cfg.correctSliceTime = 1;
if cfg.multiSubj==1; 
    cfg.normalize2MNI = 1;
    cfg.allSubjPath='C:\Documents\Realtime\';
    cfg.mask_name=fullfile(cfg.maskpath, 'OSC.625.nii');
end


if cfg.normalize2MNI == 1;
    cfg.mask_name=fullfile(cfg.maskpath, 'OSC.625.nii');
else
    
    switch cfg.voxelSelection
        case 1
            cfg.mask_name=fullfile(cfg.maskpath, 'rwOSC.625.nii');
            
        case 2
            cfg.mask_name=fullfile(cfg.maskpath, 'Ser0001', 'contrast_mask.hdr');
    end
end

cfg.maskThreshold= 0.01;

%%%%%%%%%%%%%%% classifier parameters
cfg.TRtoTake= 3; 
%rmpath('C:\Users\eust_abbondanza\Documents\MATLAB\prtools'); %FOR


%%%%%%%%%%%%CLASSIFIER OPTIONS
cfg.Classifier=4; %1 for prtoolbox svm, 2 for EN logistic regression, 3 for libsvm 4 for glmnet 5 for cosmomvpa classifiers
%lassoglm is in the stats toolbox that is in conflict with other svms, so
%to switch between the classifiers you needd to pay attention to whether
%stats toolbox is on the path or not
 %1 if you want to load a pre-trained classifier
if cfg.Classifier==2
    rmpath('C:\Users\eust_abbondanza\Documents\MATLAB\prtools');
    addpath('C:\Program Files (x86)\MATLAB\R2015a\toolbox\stats\stats');
else 
    addpath('C:\Users\eust_abbondanza\Documents\MATLAB\prtools');
    rmpath('C:\Program Files (x86)\MATLAB\R2015a\toolbox\stats\stats');
end

cfg.saveClassifier=1;
cfg.loadClassifier=1;

% if cfg.loadClassifier==1;
%     train_and_save_classifier(SubjectID, sessionN, cfg)
% end

%%%%%%%%%%%
%cfg.mask_name=fullfile(cfg.maskpath, 'OSC.625.nii');

%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Occipital_Inf.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Occipital_Mid.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Fusiform.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Inf.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Mid.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Sup.nii');

%cfg.mask_name=fullfile(cfg.maskpath, 'rwOSC.625.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'Ser0001', 'contrast_mask.hdr');
 %0.1; %0.001; %for native space to have more or less 1200 voxels

poll_for_data_preproc_classif(SubjectID, 2, 'Perc', cfg);

%just_classify(SubjectID, 2, 'Perc', cfg);
%poll_for_data_preproc_version1(SubjectID, 2, cfg)


%% Functional imagery run 1 + retrain classifier

%Analyze output and show accuracy
%%%%%%%%%%%%% paths Run 3 rakes from input run 3 puts into data path run 3

cfg.Classifier=1; %1 for prtoolbox svm, 2 for EN logistic regression, 3 for libsvm 4 for glmnet 5 for cosmomvpa classifiers
%lassoglm is in the stats toolbox that is in conflict with other svms, so
%to switch between the classifiers you needd to pay attention to whether
%stats toolbox is on the path or not
if cfg.Classifier==2
    rmpath('C:\Users\eust_abbondanza\Documents\MATLAB\prtools');
    addpath('C:\Program Files (x86)\MATLAB\R2015a\toolbox\stats\stats');
else 
    addpath('C:\Users\eust_abbondanza\Documents\MATLAB\prtools');
    rmpath('C:\Program Files (x86)\MATLAB\R2015a\toolbox\stats\stats');
end

session=3;
disk='C:\Documents\RealTime\';
accessN='201509301220'; 
subjectCode='20150930CARV'; 
%%%%%%%%%%% paths 1st Run rakes from input run 1 puts into data path run 1
cfg.inputDir=sprintf('%s%s\\Ser%04d', disk, accessN, session); %'C:\Documents\RealTime\201509301130\Ser0001'; %'C:\Documents\RealTime\20150930MCBL\DiCo_1\'% % DISK Z:\
cfg.output=sprintf('%s%s\\', disk, subjectCode); %'C:\Documents\RealTime\20150930MCBL\'; %DISK C:\ NO RUN FOLDERS, THIS IS WHERE HISTORY AND PREDICTIONS ARE SAVED
cfg.dataPath=sprintf('%s%s\\', disk, subjectCode); % DISK C:\ ETC THIS ONE SHOULD HAVE RUNS IN IT !!! where the classifier takes them to be trained

%%%%%%%%%%%
poll_for_data_preproc_classif(SubjectID, 3, 'Im', cfg);

%% Functional imagery run 2 + retrain classifier

%Analyze output and show accuracy
%%%%%%%%%%%%% paths Run 4 rakes from input run 4 puts into data path run 3
cfg.Classifier=1; %1 for prtoolbox svm, 2 for EN logistic regression, 3 for libsvm 4 for glmnet 5 for cosmomvpa classifiers
%lassoglm is in the stats toolbox that is in conflict with other svms, so
%to switch between the classifiers you needd to pay attention to whether
%stats toolbox is on the path or not
if cfg.Classifier==2
    rmpath('C:\Users\eust_abbondanza\Documents\MATLAB\prtools');
    addpath('C:\Program Files (x86)\MATLAB\R2015a\toolbox\stats\stats');
else 
    addpath('C:\Users\eust_abbondanza\Documents\MATLAB\prtools');
    rmpath('C:\Program Files (x86)\MATLAB\R2015a\toolbox\stats\stats');
end

session=4;
disk='C:\Documents\RealTime\';
accessN='201509301220'; 
subjectCode='20150930CARV'; 
%%%%%%%%%%% paths 1st Run rakes from input run 1 puts into data path run 1
cfg.inputDir=sprintf('%s%s\\Ser%04d', disk, accessN, session); %'C:\Documents\RealTime\201509301130\Ser0001'; %'C:\Documents\RealTime\20150930MCBL\DiCo_1\'% % DISK Z:\
cfg.output=sprintf('%s%s\\', disk, subjectCode); %'C:\Documents\RealTime\20150930MCBL\'; %DISK C:\ NO RUN FOLDERS, THIS IS WHERE HISTORY AND PREDICTIONS ARE SAVED
cfg.dataPath=sprintf('%s%s\\', disk, subjectCode); % DISK C:\ ETC THIS ONE SHOULD HAVE RUNS IN IT !!! where the classifier takes them to be trained

%%%%%%%%%%%
poll_for_data_preproc_classif(SubjectID, 4, 'Im', cfg);
%% ANALYZE ses 2

analyze_pred_labels(SubjectID, 2, 'Perc', cfg);


%% ANALYZE ses 3

analyze_pred_labels(SubjectID, 3, 'Im', cfg);

%% ANALYZE ses 4

analyze_pred_labels(SubjectID, 4, 'Im', cfg);


%% ANALYZE all subjects session 2
%cfg.MultiSubjectID={};
SubjGroup={'MCBL', 'CARV'};

analyze_all(SubjGroup, 2, 'Perc', cfg);


%% ANALYZE all subjects session 3

%cfg.MultiSubjectID={};
analyze_all(SubjGroup, 3, 'Im', cfg);

%% ANALYZE all subjects session 4

%cfg.MultiSubjectID={};
analyze_all(SubjGroup, 4, 'Im', cfg);






