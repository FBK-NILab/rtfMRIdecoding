%% Preparation

SubjectID='Phantom'
%useasfV52;% CHECK FILE NAME !!!
%CHECK ACQUISITION ORDER !!!!!!!!!!!!!!!!!!!!!!!!!!!!
%% Making TRDs

makeTRD_perception_rt(SubjectID, 1);

makeTRD_imagery_rt(SubjectID, 2);

%Check run file - trd name and log name.


%% Run 1 Perception


cfg=[];

cfg.inputDir='C:\Documents\realtime\Run1';
cfg.output='C:\Documents\realtime';

cfg.NrOfVols=305;
cfg.TimeOut=15.0;
cfg.TR=2;

cfg.numDummy=5;
%%%%%%%%%%%% preprocessing options
cfg.smoothFWHM = 0;
cfg.correctMotion = 1;
cfg.normalize2EPI = 0;
cfg.correctSliceTime = 1;
%%%%%%%%%%%

poll_for_data_preproc(SubjectID, 1, 'Perc', cfg);
%Stimulation will run from the real session script



%% Run 2 Imagery

%Stimulation will run from the real session script

poll_for_data_preproc(SubjectID, 2, 'Im', cfg);




