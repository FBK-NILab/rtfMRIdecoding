function obtain_mask_spm_epi_test(SubjectID, cfg)
%SubjectID='GBTE';
% opts.tpm      = {'C:\Users\eust_abbondanza\Documents\MATLAB\spm8\tpm\grey.nii'
%                 'C:\Users\eust_abbondanza\Documents\MATLAB\spm8\tpm\white.nii'
%                 'C:\Users\eust_abbondanza\Documents\MATLAB\spm8\tpm\csf.nii'}; %n tissue probability images for each class % STRCAT ????
% opts.ngaus    = [2 
%                 2 
%                 2 
%                 4]; ;%number of Gaussians per class (n+1 classes)
% opts.warpreg  = 1; %- warping regularisation
% opts.warpco   =25; %- cutoff distance for DCT basis functions
% opts.biasreg  = 0.0001; %- regularisation for bias correction
% opts.biasfwhm = 60; %- FWHM of Gausian form for bias regularisation
% opts.regtype  = 'mni'; %- regularisation for affine part
%opts.fudge    - a fudge factor

% opts.cost_fun = 'nmi';
% opts.sep = [4 2];
% opts.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
% opts.fwhm = [7 7];
% opts.interp = 1;
% opts.wrap = [0 0 0];
% opts.mask = 0;
% opts.prefix = 'r';

% % FORMAT params = spm_normalise(VG,VF,matname,VWG,VWF,flags)
% %   VG        - template handle(s)
% %   VF        - handle of image to estimate params from
% %   matname   - name of file to store deformation definitions
% %   VWG       - template weighting image
% %   VWF       - source weighting image
% %   flags     - flags.  If any field is not passed, then defaults are assumed.
% %               (defaults values are defined in spm_defaults.m)
% %               smosrc - smoothing of source image (FWHM of Gaussian in mm).
% %               smoref - smoothing of template image (defaults to 0).
% %               regtype - regularisation type for affine registration
% %                         See spm_affreg.m
% %               cutoff  - Cutoff of the DCT bases.  Lower values mean more
% %                         basis functions are used
% %               nits    - number of nonlinear iterations
% %               reg     - amount of regularisation
% %         

if nargin==1
    cfg=[];
end

if ~isfield(cfg, 'maskpath')
cfg.maskpath='C:\Users\eust_abbondanza\Documents\MATLAB\attend';
end
if ~isfield(cfg, 'Path')
  cfg.Path = 'C:\Users\eust_abbondanza\Documents\';
end

if ~isfield(cfg, 'dataPath')
  cfg.dataPath = 'C:\Users\eust_abbondanza\Documents\ATTEND_DATA\RT\20150717ANSN\Ser0001\';
end
    
%anat_image=fullfile(cfg.Path, SubjectID, sprintf('%s_be_restore.nii', SubjectID));

maskvol_hdr=spm_vol(fullfile(cfg.dataPath, 'OSC.625.nii'));
maskvol_vol=spm_read_vols(maskvol_hdr);


%%%% here if we want to flip the mask and not the image %%%%%%%%%%%%%%%
% maskvol=flip(maskvol_vol, 2);
% V=spm_create_vol(maskvol_hdr);
% spm_write_vol(V, maskvol);
%%%%%%%%%%%%%%%%%%%%%

ref_image=fullfile(cfg.dataPath, 'mean.hdr');

%ref_image=fullfile(cfg.dataPath, 'Ser0001', 'prepScan_1.nii');
FuncFile = spm_vol(ref_image);
fname1=FuncFile.fname;
%mytemplate='C:\Users\eust_abbondanza\Documents\MATLAB\spm8\templates\EPI.nii';
%spm_segment(fname1, mytemplate);
%parameters=spm_normalise(mytemplate, ref_image);
%[mysn, myinvsn]=spm_prep2sn(parameters);
%Obtain parameters for projecting from mni to anatomical
results=spm_preproc(fname1); %(fname1, opts); % %
[mysn, myinvsn]=spm_prep2sn(results);
%params = spm_normalise(VG,VF,matname,VWG,VWF,flags)
%mask_name=fullfile(cfg.maskpath, 'OSC.625.nii');
fname   = fullfile(cfg.dataPath,[SubjectID '_seg_inv_sn.mat']);
%save(fname,myinvsn.VG, myinvsn.VF,  myinvsn.Tr, myinvsn.Affine,myinvsn.flags);
save(fname,'-struct', 'myinvsn');

%classical mask
mask_name=fullfile(cfg.maskpath, 'OSC.625.nii');

%%%various masks
%mask_name=fullfile(cfg.maskpath, 'MNI_Occipital_Mid_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'MNI_Occipital_Mid_L_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'MNI_Occipital_Inf_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'MNI_Occipital_Inf_L_roi.nii');

%mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Mid_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Mid_L_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Inf_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Inf_L_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Sup_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'MNI_Temporal_Sup_L_roi.nii');

%mask_name=fullfile(cfg.maskpath, 'MNI_Fusiform_R_roi.nii');
%mask_name=fullfile(cfg.maskpath, 'MNI_Fusiform_L_roi.nii');


%fname2=fullfile(cfg.dataPath, 'prepScan_6_seg_inv_sn.mat');
spm_write_sn(mask_name,fname, []); % This is to project the ROI to the subject's anatomical space


%res_anat=spm_coreg(ref_image,anat_image);
% spm_vol(ref_image);
% spm_vol(anat_image);
% spm_vol(anat_mask);

ref_image=fullfile(cfg.dataPath, 'mean.hdr');
anat_mask=fullfile(cfg.maskpath, 'wOSC.625.nii');

%anat_mask=fullfile(cfg.maskpath, 'wMNI_Occipital_Mid_R_roi.nii');
%anat_mask=fullfile(cfg.maskpath, 'wMNI_Occipital_Mid_L_roi.nii');
%anat_mask=fullfile(cfg.maskpath, 'wMNI_Occipital_Inf_R_roi.nii');
%anat_mask=fullfile(cfg.maskpath, 'wMNI_Occipital_Inf_L_roi.nii');

%anat_mask=fullfile(cfg.maskpath, 'wMNI_Temporal_Mid_R_roi.nii');
%anat_mask=fullfile(cfg.maskpath, 'wMNI_Temporal_Mid_L_roi.nii');
%anat_mask=fullfile(cfg.maskpath, 'wMNI_Temporal_Inf_R_roi.nii');
%anat_mask=fullfile(cfg.maskpath, 'wMNI_Temporal_Inf_L_roi.nii');
%anat_mask=fullfile(cfg.maskpath, 'wMNI_Temporal_Sup_R_roi.nii');
%anat_mask=fullfile(cfg.maskpath, 'wMNI_Temporal_Sup_L_roi.nii');

%anat_mask=fullfile(cfg.maskpath, 'wMNI_Fusiform_R_roi.nii');
%anat_mask=fullfile(cfg.maskpath, 'wMNI_Fusiform_L_roi.nii');

images={ref_image
       % anat_image
        anat_mask};
spm_reslice(images); %(images, opts);
% file_to_reorient=fullfile(cfg.maskpath, 'rwOSC.625.nii');
% reorient(file_to_reorient)
%     FORMAT VO = spm_segment(PF,PG,flags)
%   PF    - name(s) of image(s) to segment (must have same dimensions).
%   PG    - name(s) of template image(s) for realignment.
%         - or a 4x4 transformation matrix which maps from the image to
%           the set of templates.
%   flags - a structure normally based on defaults.segment
%   VO    - optional output volume

return 