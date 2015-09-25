function [training_data, training_labels]=train_classifier(subjectID, rN, cfg)
if nargin<3
    cfg=[];
    
end
if ~isfield(cfg, 'maskpath')
    cfg.maskpath='C:\Users\eust_abbondanza\Documents\MATLAB\attend';
end
if ~isfield(cfg, 'dataPath')
    cfg.dataPath='C:\Documents\realtime\';
end
if ~isfield(cfg, 'protocolpath')
    cfg.protocolpath='C:\Users\eust_abbondanza\Documents\ATTEND_DATA\IM\';
end

%mask_name=fullfile(cfg.maskpath, 'rwOSC.625.nii'); % mask is in the model folder

%%%various masks

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


maskvol_hdr=spm_vol(cfg.mask_name);
maskvol_vol=spm_read_vols(maskvol_hdr);
%size(maskvol_vol)
% training_labels=[];
% training_data=[];
%%%%%%%%%%%%%%%
%debug_number=10;

%%%%%%%%%%%%%%%%%
for session=rN-1 %1:rN-1 %1:rN-1
    run_path=sprintf('%sSer%04d', cfg.dataPath, session);
    [myonsets, training_labels]=create_training_ds(subjectID, session, cfg);
    
    %debug
    %%%%%%%%%% run_path=sprintf('%sRun%i', cfg.dataPath, session);
    %%%%%%%%%%%%%%%
    %  sess_labels=sess_labels(1:debug_number)';
  %%%  training_labels=sess_labels';
    %%%%%%%%%%%%%%%%%%
    %%%   training_labels=vertcat(training_labels, sess_labels');
    
    %%%%%%%%%%%%%%%% for training on more than 1 session %%%%%%%%%%%%%%%
%     if session == 1
%         training_labels=sess_labels';
%     else
%         training_labels=vertcat(training_labels, sess_labels');
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% if we want to use more than 1 volume for training
    %%%%%%%%% %%%%%%%%%%%%%%
    %  training_labels=repmat(training_labels, 1, cfg.TRtoTake+1);
    %  training_labels=(reshape(training_labels', 1, numel(training_labels)))';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%
    for n=1:length(myonsets) %debug_number %
        clear vol_vol
        %myfile=sprintf('Analyze%05d.hdr', onsets(n));
        %     scans_to_take = [onsets(n):onsets(n)+cfg.TRtoTake];
        %      for num=1:length(scans_to_take)
        if cfg.normalize2MNI==1
            %   myfile=sprintf('wprepScan_%i.nii', scans_to_take(num));
            myfile=sprintf('wprepScan_%i.nii', myonsets(n));
        else
            %   myfile=sprintf('prepScan_%i.nii', scans_to_take(num));
            myfile=sprintf('prepScan_%i.nii', myonsets(n));
            
        end
        fname=fullfile(run_path, myfile);
        vol_hdr=spm_vol(fname);
        vol_vol=spm_read_vols(vol_hdr);
        
        %%%%%%%%%%%%%%%%%%%%%%%% BIG %%%%%%%%%%%%% DEBUG %%%%%
        % %
        % %             S=[];
        % %         S.TR=cfg.TR;
        % %         S.voxdim=double([3.0000 3.0000 3.600]); %vol_hdr.pixdim(1:3)
        % %         S.voxels=vol_hdr.dim;
        % %         S.mat0=vol_hdr.mat;
        % %         S.numEchos=1;
        % %         S.vx=vol_hdr.dim(1);
        % %         S.vy=vol_hdr.dim(2);
        % %         S.vz=vol_hdr.dim(3);
        % %         inds=[(1:2:S.vz) (2:2:S.vz)];
        % %         S.deltaT = (0:(S.vz-1))*S.TR/S.vz;
        % %         S.deltaT(inds) = S.deltaT;
        % %
        % %
        % %             %         if cfg.normalize2MNI==0
        % %             %             vol_vol=flip(vol_vol, 2);
        % %             %         end
        % %
        % %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%DEBUG%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % %
        % %             indices_1=find(maskvol_vol>=cfg.maskThreshold);
        % %             indices_0=find(maskvol_vol<cfg.maskThreshold);
        % %             vol_vol1=vol_vol;
        % %             vol_vol0=vol_vol;
        % %             vol_vol1(indices_1)=1;
        % %             vol_test1=vol_vol1;
        % %             vol_vol0(indices_0)=0;
        % %             vol_test0=vol_vol0;
        % %
        % %             vol_test1=reshape(vol_test1, 64, 64, 29);
        % %             vol_test0=reshape(vol_test0, 64, 64, 29);
        % %             filename1='TESTScan1.nii';
        % %             filename0='TESTScan0.nii';
        % %
        % %
        % %         run_path=sprintf('%s\\Ser%04d', cfg.dataPath, 1);
        % %         if ~exist(run_path, 'dir')
        % %             mkdir(run_path)
        % %         end
        % %
        % %         %         if cfg.normalize2MNI==0
        % %         %              procScan=flip(procScan, 2);
        % %         %         end
        % %         %
        % %
        % %         V=[];
        % %         V.fname=fullfile(run_path, filename1);
        % %         V.pixdim=S.voxdim;
        % %         V.dt=[4 0];
        % %         V.x=S.vx;
        % %         V.y=S.vy;
        % %         V.z=S.vz;
        % %         V.mat=S.mat0;
        % %         V.dim=S.voxels;
        % %         %      V.size=S.size;
        % %         %       V.numEchos=S.numEchos;
        % %         V.TR=S.TR;
        % %         %     V.deltaT=S.deltaT;
        % %         V.n=[1 1];
        % %         V.pinfo=[1  0 352]';
        % %         V=spm_create_vol(V);
        % %         spm_write_vol(V, vol_test1);
        % %
        % %         V=[];
        % %         V.fname=fullfile(run_path, filename0);
        % %         V.pixdim=S.voxdim;
        % %         V.dt=[4 0];
        % %         V.x=S.vx;
        % %         V.y=S.vy;
        % %         V.z=S.vz;
        % %         V.mat=S.mat0;
        % %         V.dim=S.voxels;
        % %         %      V.size=S.size;
        % %         %       V.numEchos=S.numEchos;
        % %         V.TR=S.TR;
        % %         %     V.deltaT=S.deltaT;
        % %         V.n=[1 1];
        % %         V.pinfo=[1  0 352]';
        % %         V=spm_create_vol(V);
        % %         spm_write_vol(V, vol_test0);
        % %
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DEBUG%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
                
        vol_vol=vol_vol(maskvol_vol>=cfg.maskThreshold);%reshape(vol_vol, 1, numel(vol_vol));
        %             n
        %              plot(scaledata(vol_vol(200:250), 0, 1))
        %              hold on
        %
        %     size(vol_vol)
        sess_data(n, :)=vol_vol;%vertcat(training_data, vol_vol');
        
        %             plot(training_data(n, 200:250))
        %             hold on
    end
    
    %%%%%%%%%%%%%%%% for training on more than 1 session %%%%%%%%%%%%%%%
%     if session == 1
%         training_data=sess_data;
%     else
%         training_data=vertcat(training_data, sess_data);
%     end
    
    
    
end
% training_data(1:32, 150)
% training_data(1:32, 250)
% training_data(1:32, 350)
% plot(training_data(1:32, 150))
% hold on
% plot(training_data(1:32, 250))
% hold on
% plot(training_data(1:32, 320))
% hold on
training_data=scaledata(sess_data, 0, 1);
% training_data(1:32, 150)
% training_data(1:32, 250)
% training_data(1:32, 350)
return