function makeTRD_perception_rt(subjectID, sessionNumber)
%function makeTRDoldNew4(outputName)
%
%%CREATES THE  FILE outputName.trd FOR AN EXPERIMENT IN WHICH
%%ALL PICTURES ARE SHOWN, ONE FOURTH OF THE PICTURES IS REPEATED ONCE
%%PARTICIPANT RESPONDS:
%"NEW"->LEFT MOUSE BUTTON
%"OLD"->RIGHT MOUSE BUTTON
%
%%EXAMPLE CALL:
%makeTRDoldNew4('oldNewRandomizedRepeat.trd')

%DURATIONS
%PLAY WITH DURATIONS
info.TR                         =   2;
info.refreshHz                  =   60;
info.leadInTimeSec              =   1; %6*info.TR;
info.leadOutTimeSec             =   12;
info.trialOnsetAsynchronySec    =   4*info.TR;


%1. Trial structure: blocks, 5 types including fixation
%2. block sequences, odd and even runs
%3. Sound
%4. Imagery cues/instructions


%info.nRuns=4;

info.cueType = [1 2]; %Car or Person
info.nCueTypes = length(info.cueType); %=the number of conditions

info.nRepeat=16;
info.nPictures=20; %the number of stimuli in each condition type, e.g. 10 people and 10 cars
%info.trialType = [1, 2]; %Perception vs. Imagery
%info.nTrialTypes = length(info.trialType);
info.perceptionPeople = 1:info.nPictures*info.nRepeat; %people pictures, condition 1
info.perceptionCars = 1+info.nPictures*info.nRepeat:info.nPictures*info.nRepeat*info.nCueTypes; %car pictures, condition 2
info.Pictures=[info.perceptionPeople; info.perceptionCars]; %the number of images in perception trials
info.AllPictures=numel(info.Pictures);

%info.Stop = 3;
info.emptyPicture = info.AllPictures+1;
info.fixationPicture = info.AllPictures+2;
info.cuePerson = info.AllPictures+3;
info.cueCar = info.AllPictures+4;
info.cuePictures=[info.cuePerson info.cueCar];

%for the even runs

idx1=[1 2 3 4; 3 1 4 2; 2 4 1 3; 4 3 2 1; 1 2 3 4; 3 1 4 2; 2 4 1 3; 4 3 2 1];
idx2=[2 4 1 3; 4 3 2 1; 1 2 3 4; 3 1 4 2; 2 4 1 3; 4 3 2 1; 1 2 3 4; 3 1 4 2];
if mod(sessionNumber,2) == 0
  info.blockIdx=idx2;
else
   info.blockIdx=idx1;
end 

%for the odd runs
%info.blockIdx=[2 4 1 3; 4 3 2 1; 1 2 3 4; 3 1 4 2];

% info.pictureDuration = [6, 48];
% info.emptyDuration=[30, 90];
% info.fixDuration=[30, 90];

info.fixDuration = 42;
info.cueDuration=120;
info.pictureDuration = 21;
info.emptyDuration = 21;
info.emptyScreenDuration = 210;
%info.LastEmptyDuration=120;
info.factorialStructure = [info.nRepeat  info.nCueTypes]; %prime(l, n, r), soa(50, 100), mask(l, r)
info.factorNames = [' NumberOfRepetitions ', ' ConditionTypes '];
%HOW MANY TRIALS PER DESIGN CELL DO YOU WANT TO RUN?
%TrialDefinitions = makeTrialDefinitions(info);
TrialDefinitions = makeTrialDefinitions(info);
writeTrialDefinitions(TrialDefinitions, info, subjectID, sessionNumber)

%--------------------------------------------------------------------------
%SPLIT UP TRIALS IN 4 SETS
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  MOPS %%%%%%%%%%%%

%function TrialDefinitions  = makeTrialDefinitions(info)
%        picNum(counter) = ASF_encode([iWorm, iMirror], [info.nShapeLevels, info.nMirrorLevels]);

%info.factorialStructure = [...
%   info.nShapeLevels,...
%   info.nStimRotationLevels,...
%   info.nTaskRotationLevels,...
%   info.nTaskRotationDirectionLevels,...
%   info.nTargetDifferentLevels];
    function TrialDefinitions  = makeTrialDefinitions(info)
        TrialDefinitionsTemp=[];
        for iRepeat = 1:info.nRepeat
            %sprintf('Repeat=%d', iRepeat)
%             idxrand=randperm(length(info.blockIdx(:, 1)));
%             info.blockIdx=info.blockIdx(:, idxrand);
            target=1+info.nPictures*(iRepeat-1):(info.nPictures*iRepeat);
            targetPictures=[info.perceptionPeople(target); info.perceptionCars(target)];
%           idxtemp=info.blockIdx(iRepeat, :);
                       
            
            for iCondition=1:info.nCueTypes
                %sprintf('carorperson=%d', iCondition*iRepeat)
                
                            
                            
                            ThisTrial.code = ASF_encode( [iRepeat-1 iCondition-1], info.factorialStructure);
                            %sprintf('TrialType=%d', iTrialType)
                            ThisTrial.tOnset = 0;
                            ThisTrial.userDefined = 0;
                            
                            
                            indexindex=randperm(18);
                            repeat1=randi(18, 1, 1);
                            repeat2=randi(18, 1, 1);
                            counter=1;
                            for ind =1:length(indexindex)
                                if indexindex(ind)==repeat1
                                    trialindex(counter)=repeat1;
                                    trialindex(counter+1)=repeat1;
                                    counter=counter+2;
                                    
                                    
                                elseif indexindex(ind)==repeat2
                                    trialindex(counter)=repeat2;
                                    trialindex(counter+1)=repeat2;
                                    counter=counter+2;
                                    
                                    
                                else
                                    
                                    trialindex(counter)=indexindex(ind);
                                    counter=counter+1;
                                end
                                
                            end
                            
                             pages = [];
                             durations=[];
                            for p = 1:info.nPictures
                                
                                
                                pages=[pages, info.emptyPicture, targetPictures(iCondition, trialindex(p))];
                                durations=[durations, info.emptyDuration, info.pictureDuration];
                            end
                            pages = [pages, info.emptyPicture,info.fixationPicture];
                            durations=[durations, info.emptyDuration,info.emptyScreenDuration];
                            ThisTrial.pictures = pages;
                            ThisTrial.nPages = length(ThisTrial.pictures);
                            ThisTrial.durations=durations;
                            ThisTrial.startRTonPage = 2;
                            ThisTrial.endRTonPage = ThisTrial.nPages;
                            ThisTrial.correctResponse = 1;
                            %sprintf('addtoblock=%d', iTrial)
                            TrialDefinitionsTemp=[TrialDefinitionsTemp, ThisTrial];                        
                            
                        
                    
                    
                    
                    
                end
                
            end
            
            % sprintf('Blocklength=%d', length(BlockTemp))
            
%             BlockTemp=BlockTemp(idxtemp);
%             
%             LastTrial.code = 0;
%             LastTrial.tOnset = 0;
%             LastTrial.userDefined = 0;
%             pages = [info.fixationPicture];
%             durations=[info.fixDuration];
%             for p = 1:info.nPictures
%                 
%                 
%                 pages=[pages, info.fixationPicture, info.fixationPicture];
%                 durations=[durations, info.emptyDuration, info.pictureDuration];
%                 
%             end
%             
%             LastTrial.pictures = pages;
%             LastTrial.nPages = length(ThisTrial.pictures);
%             LastTrial.durations=durations;
%             LastTrial.startRTonPage = 2;
%             LastTrial.endRTonPage = ThisTrial.nPages;
%             LastTrial.correctResponse = 0;
%             %sprintf('addtoblock=%d', iTrial)
%             BlockTemp = [BlockTemp, LastTrial];
%             
             
%             
%        


%%%%%Randomiza trials
nTrials=length(TrialDefinitionsTemp);
TrialDefinitions(1).code=0;
TrialDefinitions(1).tOnset=0; %TrialDef(nTrials).tOnset+nTrials*info.leadInTimeSec;
TrialDefinitions(1).userDefined=0;
TrialDefinitions(1).pictures=[];
TrialDefinitions(1).nPages = length(TrialDefinitionsTemp(nTrials).pictures);
TrialDefinitions(1).pictures=repmat(info.fixationPicture, 1, TrialDefinitions(1).nPages);
TrialDefinitions(1).durations=repmat(14, 1, TrialDefinitions(1).nPages);
TrialDefinitions(1).startRTonPage = 2;
TrialDefinitions(1).endRTonPage = TrialDefinitions(1).nPages-1;
TrialDefinitions(1).correctResponse = 0;
%Randomize trials

trial_index=randperm(length(TrialDefinitionsTemp));
TrialDefinitionsTemp=TrialDefinitionsTemp(trial_index);
for trial = 1:nTrials
    TrialDefinitions(trial+1)=TrialDefinitionsTemp(trial);
end
%         nTrials = length(TrialDefinitions);
%         TrialDefinitions(nTrials+1).code=0;
%         TrialDefinitions(nTrials+1).tOnset=0; %TrialDef(nTrials).tOnset+nTrials*info.leadInTimeSec;
%         TrialDefinitions(nTrials+1).pictures=TrialDefinitions(1).pictures;
%         TrialDefinitions(nTrials+1).durations=TrialDefinitions(1).durations;
%         %TrialDefinitions(nTrials+1).userDefined=0;
%         TrialDefinitions(nTrials+1).nPages = length(TrialDefinitions(nTrials+1).pictures);
%         TrialDefinitions(nTrials+1).startRTonPage = 2;
%         TrialDefinitions(nTrials+1).endRTonPage = TrialDefinitions(nTrials+1).nPages-1;
%         TrialDefinitions(nTrials+1).correctResponse = 0;

trialDuration=0;
for i = 1:length(TrialDefinitions)
    if i==1
        TrialDefinitions(i).tOnset = trialDuration + info.leadInTimeSec;
    else
        trialDuration=trialDuration+sum(TrialDefinitions(i-1).durations);
        %TrialDefinitions(i).tOnset = (i-1)*16 + info.leadInTimeSec;
        TrialDefinitions(i).tOnset = round(trialDuration/info.refreshHz) + (i-1)*info.leadInTimeSec;
    end
end
   
% %--------------------------------------------------------------------------
% %function writeTrialDefinitions(TrialDefinitions, info, fileName)
% %WRITES FACTORIAL INFO AND ARRAY OF TRIAL DEFINITIONS TO A FILE
% %IF YOU DO NOT USE USER-SUPPLIED TRD-COLUMNS, THIS WORKS FOR ALL
% %EXPERIMENTS AND DOES NOT NEED TO BE CHANGED
% %--------------------------------------------------------------------------
% function writeTrialDefinitions(TrialDefinitions, info, fileName, Cfg)
% if isempty(fileName)
%     fid = 1;
% else
%     %THIS OPENS A TEXT FILE FOR WRITING
%     fid = fopen(fileName, 'w');
%     fprintf(1, 'Creating file %s ...', fileName);
% end
%
% %WRITE DESIGN INFO
% fprintf(fid, '%4d', info.factorialStructure );
%
% nTrials = length(TrialDefinitions);
% for iTrial = 1:nTrials
%     nPages = length(TrialDefinitions(iTrial).pictures);
%
%     %STORE TRIALDEFINITION IN FILE
%     fprintf(fid, '\n'); %New line for new trial
%     fprintf(fid, '%4d', TrialDefinitions(iTrial).code);
%     fprintf(fid, '\t%7.3f', TrialDefinitions(iTrial).tOnset);
%
%     fprintf(fid, '\t');
%     fprintf(fid, '%4d ', TrialDefinitions(iTrial).userDefined);
%     fprintf(fid, '\t');
%
%     for iPage = 1:nPages
%         %TWO ENTRIES PER PAGE: 1) Picture, 2) Duration
%         fprintf(fid, '\t%4d %4d', TrialDefinitions(iTrial).pictures(iPage), TrialDefinitions(iTrial).durations(iPage));
%     end
%     fprintf(fid, '\t%4d', TrialDefinitions(iTrial).startRTonPage);
%     fprintf(fid, ' %4d', TrialDefinitions(iTrial).endRTonPage);
%     fprintf(fid, '\t%4d', TrialDefinitions(iTrial).correctResponse);
%     %ADD A SECONDARY TASK
%     if Cfg.addSecondaryTask
%         writeSecondaryTask(Cfg, fid, TrialDefinitions(iTrial).tOnset, length(TrialDefinitions(iTrial).userDefined))
%     end
%
% end
% if fid > 1
%     fclose(fid);
% end
%
% fprintf(1, '\nDONE\n'); %JUST FOR THE COMMAND WINDOW
%
%
% %
% %
% % TrialDef = [TrialDef, TrialDefRepeat];
% % nTrials = length(TrialDef);
% %
% %
% % %RANDOMIZE HERE
% % idx = randperm(nTrials);
% % TrialDef = TrialDef(idx);
% %
% %
% % %NOW CHECK WHO HAS BEEN REPEATED
% % hasBeenShownAlready = zeros(nTrials, 1);
% % for iTrial = 1:nTrials
% %     if(hasBeenShownAlready(TrialDef(iTrial).code))
% %         TrialDef(iTrial).code = ASF_encode( [1, TrialDef(iTrial).code-1], Design.factorLevels);
% %         TrialDef(iTrial).correctResponse = 3;
% %     end
% %     hasBeenShownAlready(TrialDef(iTrial).code) = 1;
% % end

function writeTrialDefinitions(TrialDefinitions, info, subjectID, sessionNumber)
trdName = sprintf('%s_Perc-%d.trd', subjectID, sessionNumber);
%THIS OPENS A TEXT FILE FOR WRITING
fid = fopen(trdName, 'w');
%DESIGN
fprintf(fid, '%3d ', info.factorialStructure);
fprintf(fid, '%s ', info.factorNames(:));
for iTrial = 1:length(TrialDefinitions)
    %STORE TRIALDEFINITION IN FILE
    fprintf(fid, '\n'); %New line for new trial
    fprintf(fid, '%4d', TrialDefinitions(iTrial).code);
    fprintf(fid, '\t%4d', TrialDefinitions(iTrial).tOnset);
    fprintf(fid, '\t%4d', TrialDefinitions(iTrial).userDefined);
    
    for iPage = 1:TrialDefinitions(iTrial).nPages
        %TWO ENTRIES PER PAGE: 1) Picture, 2) Duration
        fprintf(fid, '\t%4d %4d', TrialDefinitions(iTrial).pictures(iPage), TrialDefinitions(iTrial).durations(iPage));
    end
    %ADD A DUMMY EMPTY PICTURE WITH DURATION OF 1 FRAME
    
    fprintf(fid, '\t%4d %4d', info.emptyPicture, 1);
    
    
    fprintf(fid, '\t%4d', TrialDefinitions(iTrial).startRTonPage);
    fprintf(fid, '\t%4d', TrialDefinitions(iTrial).endRTonPage);
    fprintf(fid, '\t%4d', TrialDefinitions(iTrial).correctResponse);
end
if fid > 1
    fclose(fid);
end
fprintf(1, '\n'); %JUST FOR THE COMMAND WINDOW


%faccombination = ASF_decode([TrialDefinitions.code], info.factorialStructure);


