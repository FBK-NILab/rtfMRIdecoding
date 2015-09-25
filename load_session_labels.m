function vol_labels = load_session_labels(SubjectID, sessionN, expType, cfg)

if nargin==3
    cfg=[];
end
cfg.blockDurVol=8;
cfg.TRms=2000;
cfg.factorLevels=[16 2];
%cfg.NofVols=175;

n_vols=305;
%cfg.protocolpath='C:\Users\eust_abbondanza\Documents\ATTEND_DATA\IM\';
prname=sprintf('%s_%s-%i.trd', SubjectID, expType, sessionN);
fname = fullfile(cfg.protocolpath, prname);
fid = fopen(fname, 'rt');
counter = 0;
aline = fgetl(fid);
while ~feof(fid)
    aline = fgetl(fid);
    counter = counter + 1;
    numLine = str2num(aline);
    nElements = length(numLine);
    res(counter, 1:nElements) = numLine;
    
end
fclose(fid);
code = res(:, 1);
faccombination = ASF_decode(code, cfg.factorLevels);
%condVec=faccombination(:, 3);
labels=faccombination(:, 2);
%labels(condVec==-1)=-1;
labels=labels(labels>=0);
%labels=repmat(labels, 1, cfg.blockDurVol);
timings=round((res(:, 2)*1000)/cfg.TRms);
timings=timings-cfg.numDummy;
timings=timings(timings>=0);
timings=[timings' n_vols-cfg.numDummy]; %cfg.NofVols];
vol_labels=[];
for j=1:length(timings)
    if timings(j)==n_vols-cfg.numDummy %cfg.NofVols
        vol_labels(timings(j):timings(j)+1)=labels(j-1);
        break;
    else
    vol_labels(timings(j):timings(j+1))=labels(j);
    end
end
%timings=repmat(timings, 1, cfg.blockDurVol);
%labels=reshape(labels', 1, numel(labels));
%timings=reshape(timings', 1, (numel(timings)));
vol_labels=arrayfun(@num2str, vol_labels, 'UniformOutput', false);

return