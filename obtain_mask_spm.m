function obtain_mask_spm(SubjectID, Cfg)
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

opts.cost_fun = 'nmi';
opts.sep = [4 2];
opts.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
opts.fwhm = [7 7];
opts.interp = 1;
opts.wrap = [0 0 0];
opts.mask = 0;
opts.prefix = 'r';

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
  cfg.dataPath = 'C:\Documents\realtime\Run1\';
end
    
anat_image=fullfile(cfg.Path, SubjectID, sprintf('%s_be_restore.nii', SubjectID));
ref_image=fullfile(cfg.dataPath, 'prepScan_6.nii');
anat_mask=fullfile(cfg.maskpath, 'wOSC.625.nii');



AnatomyFile = spm_vol(anat_image);
fname=AnatomyFile.fname;

mask_name=fullfile(cfg.maskpath, 'OSC.625.nii');
%Obtain parameters for projecting from mni to anatomical
results=spm_preproc(fname);
[mysn, myinvsn]=spm_prep2sn(results);

fname   = fullfile(cfg.Path,[SubjectID '_seg_inv_sn.mat']);
%save(fname,myinvsn.VG, myinvsn.VF,  myinvsn.Tr, myinvsn.Affine,myinvsn.flags);
save(fname,'-struct', 'myinvsn');
spm_write_sn(mask_name,fname, []); % This is to project the ROI to the subject's anatomical space


%res_anat=spm_coreg(ref_image,anat_image);
% spm_vol(ref_image);
% spm_vol(anat_image);
% spm_vol(anat_mask);
images={ref_image
        anat_image
        anat_mask};
spm_reslice(images, opts);

%     FORMAT VO = spm_segment(PF,PG,flags)
%   PF    - name(s) of image(s) to segment (must have same dimensions).
%   PG    - name(s) of template image(s) for realignment.
%         - or a 4x4 transformation matrix which maps from the image to
%           the set of templates.
%   flags - a structure normally based on defaults.segment
%   VO    - optional output volume

return 