function poll_for_data_preproc(SubjectID, sessionN, cfg)

% every 2 sec look for a file with a name template in a directory
% send New Data even to the listener
%listener will print got it and the volume number
% SubjectID='Phantom';
% sessionN=3;
ft_defaults
%ft_hastoolbox('spm8', 1);
if nargin <= 2
    cfg = [];
end
% cfg.inputDir='C:\Users\eust_abbondanza\Documents\realtime\20130429_19720216VLRZ\Ser0003\';
% cfg.NrOfVols=50;
% cfg.TimeOut=6.0;
% cfg.output='C:\Documents\realtime\TEST\';
% % % cfg.maskpath='C:\Users\eust_abbondanza\Documents\MATLAB\attend'
% % % cfg.datapath='C:\Documents\realtime\';
% % % cfg.protocolpath='C:\Users\eust_abbondanza\Documents\MATLAB\';
%cfg.Classifier=2; %1 for SVM from PR tollbox, 2 for EN classifier
%cfg.blockDurVol=8;
%Cfg.name_templates='prepScan_*.nii';
%files = dir(fullfile(Cfg.inputDir,Cfg.name_templates));
%first non-dummy volume



%param = spm_normalise(cfg.mytemplate, cfg.ref_image, cfg.matname, defaults.normalise.estimate.weight,'',defaults.normalise.estimate);



if ~isfield(cfg, 'numDummy')
    cfg.numDummy = 5;			% number of dummy scans to drop
end

if ~isfield(cfg, 'NrOfVols')
    cfg.NrOfVols=170;
end

if ~isfield(cfg, 'smoothFWHM')
    cfg.smoothFWHM = 0; %8;
end

if ~isfield(cfg, 'correctMotion')
    cfg.correctMotion = 1; %1;
end

if ~isfield(cfg, 'normalize2EPI')
    cfg.normalize2EPI = 0; %1;
end

if ~isfield(cfg, 'correctSliceTime')
    cfg.correctSliceTime = 1; %1;
end

if ~isfield(cfg, 'maskpath')
    cfg.maskpath='C:\Users\eust_abbondanza\Documents\MATLAB\attend';
end

if ~isfield(cfg, 'Classifier')
    cfg.Classifier=2; %1 for SVM from PR tollbox, 2 for EN classifier
end

if ~isfield(cfg, 'whichEcho')
    cfg.whichEcho = 1;
else
    if cfg.whichEcho < 1
        error '"whichEcho" configuration field must be >= 1';
    end
end

hist_file=sprintf('history_%s.mat', SubjectID);
if ~exist(hist_file, 'file')
    history = struct('S',[], 'RRM', [], 'motion', []);
else
    
    load(hist_file);
end

numTotal=cfg.numDummy+1;
numTrial = cfg.NrOfVols*(sessionN-1);
numProper = 0;
motEst = [];
waiting_time=0;
while 1 %length(files)
        
    GrabVol=tic;
    pause(0.2);
 name_template=sprintf('Analyze%05d.hdr', numTotal);
%%%for distortion corrected

%%%%%%%%%name_template=sprintf('f19881016MCBL-0005-%05d*.hdr', numTotal);


    %start timer
    
    %after 1.5 sec check if there is a volume with a number
    
    %close timer
    target=dir(fullfile(cfg.inputDir,name_template));
    
    if isempty(target)
        fprintf('\nNo new data\n');
        time=toc(GrabVol);
        waiting_time=waiting_time +time
        
        if waiting_time>cfg.TimeOut
            break
        end
    else
        %  notify(H, 'NewData');
        fprintf('\nAvailable volume %i\n', numTotal)
        
   %%%     fname=fullfile(cfg.inputDir,name_template);
        
        fname=fullfile(cfg.inputDir,target.name);
        vol_hdr=spm_vol(fname);
        %         vol_vol=spm_read_vols(vol_hdr);
        %         dat=vol_vol(maskvol_vol>0);
        dat=spm_read_vols(vol_hdr);
        
        S=[];
        S.TR=cfg.TR;
        S.voxels=vol_hdr.dim;
        S.voxdim=[3.0000 3.0000 3.600]; %vol_hdr.pixdim(1:3)
        S.mat0=vol_hdr.mat;
        S.numEchos=1;
        S.vx=vol_hdr.dim(1);
        S.vy=vol_hdr.dim(2);
        S.vz=vol_hdr.dim(3);
        inds=[(1:2:S.vz) (2:2:S.vz)];
        S.deltaT = (0:(S.vz-1))*S.TR/S.vz;
        S.deltaT(inds) = S.deltaT;
        
        if isempty(S)
            warning('No protocol information found!')
            % restart loop
            pause(0.5);
            continue;
        end
        
        if cfg.whichEcho > S.numEchos
            warning('Selected echo number exceeds the number of echos in the protocol.');
            grabEcho = S.numEchos;
            fprintf(1,'Will grab echo #%i of %i\n', grabEcho, S.numEchos);
        else
            grabEcho = 1;
        end
        
        % Prepare smoothing kernels based on configuration and voxel size
        if cfg.smoothFWHM > 0
            [smKernX, smKernY, smKernZ, smOff] = ft_omri_smoothing_kernel(cfg.smoothFWHM, S.voxdim);%ft_omri_smoothing_kernel(cfg.smoothFWHM, S.voxdim);
            smKern = convn(smKernX'*smKernY, reshape(smKernZ, 1, 1, length(smKernZ)));
        else
            smKernX = [];
            smKernY = [];
            smKernZ = [];
            smKern  = [];
            smOff   = [0 0 0];
        end
        
    
        
        % store current info structure in history
        numTrial  = numTrial + 1;
        history(numTrial).S = S;
        disp(S)
        
        fprintf(1,'Starting to process\n');
      %  numTotal  = cfg.numDummy * S.numEchos;
      
        
        % Loop this as long as the experiment runs with the same protocol (= data keeps coming in)
        
        % determine number of samples available in buffer / wait for more than numTotal
    %    threshold.nsamples = numTotal + S.numEchos - 1;
        
        %CHECK FUNCTION !!!!!!!!!!!!!!!
        % % %             newNum = ft_poll_buffer(cfg.input, threshold, 500);
        % % %
        % % %             if newNum.nsamples < numTotal
        % % %                 % scanning seems to have stopped - re-read header to continue with next trial
        % % %                 break;
        % % %             end
        % % %             if newNum.nsamples < numTotal + S.numEchos
        % % %                 % timeout -- go back to start of (inner) loop
        % % %                 continue;
        % % %             end
        % % %
        % % %             % this is necessary for ft_read_data
        % % %             hdr.nSamples = newNum.nsamples;
        % % %
        index = (cfg.numDummy + numProper) * S.numEchos + grabEcho;
        fprintf('\nTrying to read %i. proper scan at sample index %d\n', numProper+1, index);
        GrabSampleT = tic;
        
        % % %             try
        % % %                 % read data from buffer (only the last scan)
        % % %                 dat = ft_read_data(cfg.input, 'header', hdr, 'begsample', index, 'endsample', index);
        % % %             catch
        % % %                 warning('Problems reading data - going back to poll operation...');
        % % %                 continue;
        % % %             end
        
        numProper = numProper + 1;
        
        
        rawScan = single(reshape(dat, S.voxels));
        
        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % slice timing correction
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if cfg.correctSliceTime
            if numProper == 1
                fprintf(1,'Initialising slice-time correction model...\n');
                STM = ft_omri_slice_time_init(rawScan, S.TR, S.deltaT);
            else
                fprintf('%-30s','Slice time correction...');
                tic;
                [STM, procScan] = ft_omri_slice_time_apply(STM, rawScan);
                toc
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % motion correction
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if cfg.correctMotion
            doneHere = 0;
            if numProper == 1
                RRM=[];
                for i=1:length(history)
                    if isequal(history(i).S, S)
                        fprintf(1,'Will realign scans to reference model from trial %i session ...\n', i);
                        % protocol the same => re-use realignment reference
                        RRM = history(i).RRM;
                        break;
                    end
                end
                
                % none found - setup new one
                if isempty(RRM)

                  flags = struct('mat', S.mat0);
                    fprintf(1,'Setting up first num-dummy scan as reference volume...\n');
              
                        RRM = ft_omri_align_init(rawScan, flags);  %RRM = ft_omri_align_init(rawScan, flags);
                        motEst = zeros(1,6);
                        curSixDof = zeros(1,6);
    
                    history(numTrial).RRM = RRM;
  
                    procScan = single(rawScan);  % procScan = single(rawScan);
                    doneHere = 1;
                end
            end
            
            if ~doneHere
                fprintf('%-30s','Registration...');
                tic;
                [RRM, M, Mabs, procScan] = ft_omri_align_scan(RRM, procScan);   %  [RRM, M, Mabs, procScan] = ft_omri_align_scan(RRM, rawScan);
                toc
                curSixDof = hom2six(M);
                motEst = [motEst; curSixDof.*[1 1 1 180/pi 180/pi 180/pi]];
            end
        else
            procScan = single(procScan);   %   procScan = single(rawScan);
            motEst = [motEst; zeros(1,6)];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % slice timing correction
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         if cfg.correctSliceTime
%             if numProper == 1
%                 fprintf(1,'Initialising slice-time correction model...\n');
%                 STM = ft_omri_slice_time_init(procScan, S.TR, S.deltaT);
%             else
%                 fprintf('%-30s','Slice time correction...');
%                 tic;
%                 [STM, procScan] = ft_omri_slice_time_apply(STM, procScan);
%                 toc
%             end
%         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % smoothing
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if cfg.smoothFWHM > 0
            fprintf('%-30s','Smoothing...');
            tic;
            % MATLAB convolution
            %Vsm = convn(procScan,smKern);
            %procScan = Vsm((1+smOff(1)):(end-smOff(1)), (1+smOff(2)):(end-smOff(2)), (1+smOff(3)):(end-smOff(3)));
            
            % specialised MEX file
            procScan = ft_omri_smooth_volume(single(procScan), smKernX, smKernY, smKernZ);
            
            toc
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % done with pre-processing, write output
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if cfg.correctMotion
            procSample = [single(procScan(:)) ; single(curSixDof')];
        else
            procSample = single(procScan(:));
            %     procSample = procScan(:);
        end
        
    %%%%%%%for dicom no flipping !!!!!!!!!    
     procScan=flip(procScan, 2);
       % procScan=spm_write_sn(procScan,param,defaults.normalise.write);
        
        filename=sprintf('prepScan_%i.nii', numProper);
        V=[];
        run_path=sprintf('%s\\Ser%04d', cfg.dataPath, sessionN);
        if ~exist(run_path, 'dir')
            mkdir(run_path)
        end
        
%         if cfg.normalize2MNI==0
%              procScan=flip(procScan, 2);
%         end
        
        V.fname=fullfile(run_path, filename);
        V.pixdim=S.voxdim;
        V.dt=[4 0];
        V.x=S.vx;
        V.y=S.vy;
        V.z=S.vz;
        V.mat=S.mat0;
        V.dim=S.voxels;
        %      V.size=S.size;
        %       V.numEchos=S.numEchos;
        V.TR=S.TR;
        %     V.deltaT=S.deltaT;
        V.n=[1 1];
        V.pinfo=[1  0 352]';
        V=spm_create_vol(V);
        spm_write_vol(V, procScan); %spm_create_vol
        %  V=spm_vol(Analyze_file)
        %  V=spm_write_vol(V, procScan)
        
      
        %            ft_write_data(cfg.output1, procSample, 'header', hdrOut, 'append', true);
        
        
        %evr.sample = numProper;
        %ft_write_event(cfg.output, evr);
        
        fprintf('Done -- total time = %f\n', toc(GrabSampleT));
        fprintf('Volume processed in %f\n', toc(GrabVol));
        subplot(4,1,1);
        plot(motEst(:,1:3));
        subplot(4,1,2);
        plot(motEst(:,4:6));
        
        subplot(4,1,3);
        slcImg = reshape(dat, [S.vx	S.vy*S.vz]);
        imagesc(slcImg);
        colormap(gray);
        
        subplot(4,1,4);
        slcImg = reshape(procScan, [S.vx	S.vy*S.vz]);
        imagesc(slcImg);
        colormap(gray);
        
        % force Matlab to update the figure
        drawnow
        
        
        if numTotal==cfg.NrOfVols
%             save('mot_corr_params.mat', 'RRM');
%             save('motEstim.mat', 'motEst');
%             save('SixDof.mat', 'curSixDof');
            fname_hist=fullfile(cfg.output, sprintf('history_%s.mat', SubjectID));
            save(fname_hist, 'history');
            break;
         else
           numTotal  = numTotal + S.numEchos;
         end
        % time=toc;
        %write event
        %addlistener(input_dir_search,'NewVol',my_omri_pipeline) %the listener gets the signal and starts the preprocessing, event.listener
        
        %read event and print data received
    end
end
