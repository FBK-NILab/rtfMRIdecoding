%% Preparatory part

clear all
SubjectID='FATR';

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
%%%%%%%%%%% paths 1st Run rakes from input run 1 puts into data path run 1
cfg.inputDir='C:\Documents\RealTime\201507141030\Ser0001'; % DISK Z:\
cfg.output='C:\Documents\RealTime\20150714FATR\'; %DISK C:\ NO RUN FOLDERS, THIS IS WHERE HISTORY AND PREDICTIONS ARE SAVED
cfg.dataPath='C:\Documents\RealTime\20150714FATR\';% DISK C:\ ETC THIS ONE SHOULD HAVE RUNS IN IT !!! where the classifier takes them to be trained
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

%%TODO If the images have to be normalized the normalization should be run
%%right after mean calculation and before mask operations because mask
%%reprojection does a strange thing to the mean image so that it comes out
%%turned back again !!! :(

SubjectID='FATR';
cfg.maskpath='C:\Documents\RealTime\20150714FATR\';
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

%create_spm_design(SubjectID, 1, cfg);


%% Functional perception run 2 + retrain classifier
SubjectID='FATR';
cfg.MultiSubjectID={'20150717IGDB', '20150717ANSN', '20150806PMMN'}; %'20150806MCBL','20150717OIFR',
UseASFV52;

cfg.multiSubj=0; 
%%%%%%%%%%%%% paths Run 2 rakes from input run 2 puts into data path run 2
cfg.inputDir='C:\Documents\RealTime\201507141030\Ser0001\'; % DISK Z:\
cfg.output='C:\Documents\RealTime\20150714FATR\'; %DISK C:\ NO RUN FOLDERS, THIS IS WHERE HISTORY AND PREDICTIONS ARE SAVED
cfg.dataPath='C:\Documents\RealTime\20150714FATR\';% DISK C:\ ETC THIS ONE SHOULD HAVE RUNS IN IT !!! where the classifier takes them to be trained
%%%%%%%%%%%mask, protocol and classifier training data
%Masks should be in the subject output folder,  protocols should be in Matlab current folder
cfg.maskpath='C:\Documents\RealTime\20150714FATR\';
cfg.protocolpath='C:\Documents\RealTime\20150714FATR\'; %'R:\ATTEND'='E:\Experiments\Jens\rt_share\ATTEND' or 'Y:\ATTEND' ='C:\Users\tbv\Documents\TBVData\NeuroFeedbackData\ATTEND'
if cfg.multiSubj==1;
    cfg.protocolpath='C:\Documents\RealTime\PROTOCOLS\'; % to put the current subject's protocols there too !!!!!!!!!
end
cfg.NrOfVols=305;
cfg.TimeOut=15.0;
cfg.TR=2;
cfg.numDummy=5;
cfg.blockDur=9;
cfg.Feedback=0;
if cfg.Feedback==1
    cfg.FeedbackFolder='C:\Users\tbv\Documents\TBVData\NeuroFeedbackData\ATTEND';
    mkdir(fullfile(cfg.FeedbackFolder, SubjectID));
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
end
%%%%%%%%%%%%%%% classifier parameters
cfg.TRtoTake= 4; 
%rmpath('C:\Users\eust_abbondanza\Documents\MATLAB\prtools'); %FOR
%CLASSIFIER 2
cfg.Classifier=2; %1 for prtoolbox svm, 2 for EN logistic regression, 3 for libsvm 4 for glmnet 5 for cosmomvpa classifiers
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

%%%%%%%%%%%
%cfg.mask_name=fullfile(cfg.maskpath, 'OSC.625.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Occipital_Inf.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Occipital_Mid.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Fusiform.nii');

%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Inf.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Mid.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Sup.nii');

cfg.mask_name=fullfile(cfg.maskpath, 'rwOSC.625.nii');
%cfg.mask_name=fullfile(cfg.maskpath, 'Ser0001', 'contrast_mask.hdr');
cfg.maskThreshold= 0.1; %0.1; %0.001; %for native space to have more or less 1200 voxels

%poll_for_data_preproc_classif(SubjectID, 2, 'Perc', cfg);

%just_classify(SubjectID, 2, 'Perc', cfg);
%poll_for_data_preproc_version1(SubjectID, 2, cfg)


%% Functional imagery run 1 + retrain classifier

%Analyze output and show accuracy
%%%%%%%%%%%%% paths Run 3 rakes from input run 3 puts into data path run 3
cfg.inputDir='C:\Documents\RealTime\201507141030\Ser0003'; % DISK Z:\
cfg.output='C:\Documents\RealTime\20150714FATR\'; %DISK C:\ NO RUN FOLDERS, THIS IS WHERE HISTORY AND PREDICTIONS ARE SAVED
cfg.dataPath='C:\Documents\RealTime\20150714FATR\';% DISK C:\ ETC THIS ONE SHOULD HAVE RUNS IN IT !!! where the classifier takes them to be trained

%%%%%%%%%%%
poll_for_data_preproc_classif(SubjectID, 3, 'Im', cfg);

%% Functional imagery run 2 + retrain classifier

%Analyze output and show accuracy
%%%%%%%%%%%%% paths Run 4 rakes from input run 4 puts into data path run 3
cfg.inputDir='C:\Documents\RealTime\201507141030\Ser0004'; % DISK Z:\
cfg.output='C:\Documents\RealTime\20150714FATR\'; %DISK C:\ NO RUN FOLDERS, THIS IS WHERE HISTORY AND PREDICTIONS ARE SAVED
cfg.dataPath='C:\Documents\RealTime\20150714FATR\';% DISK C:\ ETC THIS ONE SHOULD HAVE RUNS IN IT !!! where the classifier takes them to be trained
%%%%%%%%%%%
poll_for_data_preproc_classif(SubjectID, 4, 'Im', cfg);
%% ANALYZE ses 2

analyze_pred_labels(SubjectID, 2, 'Perc', cfg);


%% ANALYZE ses 3

analyze_pred_labels(SubjectID, 3, 'Im', cfg);

%% ANALYZE ses 4

analyze_pred_labels(SubjectID, 4, 'Im', cfg);




