function [tOn, stim_cat] = create_training_ds_vs(subjectID, rN, cfg)
% subjectID='GBTE';
% expType='Im';
% rN=3;
% cfg.protocolpath= 'C:\Users\eust_abbondanza\Documents\MATLAB\stimulation\';
if nargin <3
    cfg=[];
end

%%%%%% to be always here
cfg.inputType = 'TRD';
cfg.TRms = 2000;
%cfg.stimDur = 4000;
%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%just for debug purposes
% cfg.numDummy=5;
% cfg.TRtoTake=5; % TOACCOUNT FOR BLOCKS AND FOR THE FACT THA IMAGERY IS VISIBLE AFTER 10 SEC !
% %Cfg.ResolutionOfTime = 'volumes'; %'msec' or 'volumes'
% 
% %cfg.datapath='C:\Windows\Documents\realtime\';
% cfg.protocolpath='C:\Users\eust_abbondanza\Documents\MATLAB\full_session_300915\';
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if cfg.ExpType=='PercIm'
    cfg.factorLevels=[16 2];
end


if cfg.ExpType=='VS'
    switch rN
        case 1
            
            cfg.factorLevels=[2 2 2 5];
        case 2
            
            cfg.factorLevels=[2 2 2 6];
        case 3
            
            cfg.factorLevels=[2 2 2 7];
        case 4
            
            cfg.factorLevels=[2 2 2 8];
            
    end
end
%[4 2 2];
counter = 0;
%prname=sprintf('%s_%s-%i.trd', subjectID, expType, rN);
%fname = fullfile(cfg.protocolpath, prname);
searchStr = [cfg.protocolpath, subjectID, '_', '*', num2str(rN), '.trd'];
d = dir(searchStr);
fname=fullfile(cfg.protocolpath, d.name);
fid = fopen(fname, 'rt');
aline = fgetl(fid);
while ~feof(fid)
    aline = fgetl(fid);
    counter = counter + 1;
    numLine = str2num(aline);
    nElements = length(numLine);
    res(counter, 1:nElements) = numLine;
  %  res(counter, 1:nElements) = aline;
end
fclose(fid);
code = res(:, 1);
faccombination = ASF_decode(code, cfg.factorLevels);
%condVec=faccombination(:, 2);
switch cfg.ExpType
    case 'PercIm'
        stim_cat=single(faccombination(:, 2));
    case 'VS'
        stim_cat=single(faccombination(:, 4));
end
tOn = round((res(:, 2)*1000)/cfg.TRms)-cfg.numDummy;
tOn=tOn(stim_cat~=-1);
stim_cat=stim_cat(stim_cat~=-1);
%tOn(condVec==-1)=[];
%stim_cat=single(faccombination(:, 2));
%stim_cat(condVec==-1)=[];

%GET ONSET TIMES
%stim_cat = strread(num2str(stim_cat),'%s\n');
%stim_cat = num2str(stim_cat);
%stim_cat=strtrim(cellstr(num2str(stim_cat'))')
%stim_cat=arrayfun(@num2str, stim_cat, 'UniformOutput', false);
%length(stim_cat)
%stim_cat=cellstr(stim_cat);
tOn=tOn+cfg.TRtoTake;
%tOn = tOn - Cfg.skipVolumes*Cfg.TRms;
%length(tOn)
return










