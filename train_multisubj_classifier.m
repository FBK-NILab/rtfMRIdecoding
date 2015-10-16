function [min, range, training_data, training_labels]=train_multisubj_classifier(runN, cfg)

if nargin<2
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

if ~isfield(cfg, 'allSubjPath')
    cfg.allSubjPath='C:\Documents\Realtime\';
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
training_labels=[];
sess_data=[];
%%%%%%%%%%%%%%%
%debug_number=10;
for subj=1:length(cfg.MultiSubjectID)
    %%%%%%%%%%%%%%%%%
    subject=cfg.MultiSubjectID{subj};
    subjectID=subject(9:12);
    subjectPath=fullfile(cfg.allSubjPath, subject);
    for session=runN-1 %1:rN-1
        [onsets, sess_labels]=create_training_ds(subjectID, session, cfg);
        run_path=sprintf('%s\\Ser%04d', subjectPath, session);%debug
        %%%%%%%%%% run_path=sprintf('%sRun%i', cfg.dataPath, session);
        %%%%%%%%%%%%%%%
        %  sess_labels=sess_labels(1:debug_number)';
        sess_labels=sess_labels';
        %%%%%%%%%%%%%%%%%%
        training_labels=vertcat(training_labels, sess_labels');
        %%%%%%%%%
        for n=1:length(onsets) %debug_number %
            %myfile=sprintf('Analyze%05d.hdr', onsets(n));
            
            
            myfile=sprintf('wprepScan_%i.nii', onsets(n));
            
            
            
            fname=fullfile(run_path, myfile);
            vol_hdr=spm_vol(fname);
            vol_vol=spm_read_vols(vol_hdr);
            
            vol_vol=vol_vol(maskvol_vol>cfg.maskThreshold);%reshape(vol_vol, 1, numel(vol_vol));
            %     size(vol_vol)
            sess_data=vertcat(sess_data, vol_vol');
     %       training_data=scaledata(training_data, 0, 1);
        end
        
    end
end

%size(training_labels)
%size(training_data)

[min, range, training_data]=myscaledata(sess_data, 0, 1);

%  training_data(1:28, 150)
%  training_data(1:28, 250)
%  training_data(1:28, 350)

% if cfg.saveClassifier==1
%     save_classifier(training_data, training_labels, cfg);
% end



return