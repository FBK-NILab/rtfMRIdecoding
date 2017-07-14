function poll_for_data_test(Cfg)

% every 2 sec look for a file with a name template in a directory
% send New Data even to the listener 
%listener will print got it and the volume number
Cfg=[];
Cfg.inputDir='C:\Documents\RealTime\201507171040\Ser0001\';
%'C:\Users\eust_abbondanza\Documents\realtime\20130429_19720216VLRZ\nii_files\'; 
%'C:\Users\eust_abbondanza\Documents\realtime\20130429_19720216VLRZ\Ser0001\';
Cfg.NrOfVols=100;
Cfg.TimeOut=6.0;
Cfg.maskThreshold=0.1;
Cfg.mask_name='C:\Documents\RealTime\20150717IGDB\rwOSC.625.nii';
maskvol_hdr=spm_vol(Cfg.mask_name);
maskvol_vol=spm_read_vols(maskvol_hdr);
%Cfg.name_templates='prepScan_*.nii';
%files = dir(fullfile(Cfg.inputDir,Cfg.name_templates));
i=6;
waiting_time=0;
while 1 %length(files)
    
    tic
    pause(1.0);
    name_template=sprintf('Analyze%05i.hdr', i); %sprintf('rf_multiscan_run1_%04i.hdr', i);%sprintf('Analyze%05i.hdr', i);
    %start timer
    
    %after 1.5 sec check if there is a volume with a number
    
    %close timer
    target=dir(fullfile(Cfg.inputDir,name_template));
    
    if isempty(target)
        fprintf('\nNo new data\n');
        time=toc
        waiting_time=waiting_time +time

         if waiting_time>Cfg.TimeOut
             break
         end
    else 
      %  notify(H, 'NewData');
      fprintf('\nAvailable volume %i\n', i)
      clear vol_vol
      filename1=fullfile(Cfg.inputDir,name_template);
      vol_hdr=spm_vol(filename1);
      %         vol_vol=spm_read_vols(vol_hdr);
      %         dat=vol_vol(maskvol_vol>0);
      %  dat=spm_read_vols(vol_hdr);
      
      rawScan=spm_read_vols(vol_hdr);
      vol_vol=rawScan(maskvol_vol>=Cfg.maskThreshold);%reshape(vol_vol, 1, numel(vol_vol));
    %%%%%%%%%%  vol_vol=reshape(rawScan, 1, numel(rawScan));
      vol_vol=scaledata(vol_vol, 0, 1);
      plot(vol_vol(200:250))
      hold on
      
       
      if i==Cfg.NrOfVols
          break;
      else
         i=i+1;
      end
    end
   % time=toc;
    %write event
%addlistener(input_dir_search,'NewVol',my_omri_pipeline) %the listener gets the signal and starts the preprocessing, event.listener

%read event and print data received
end