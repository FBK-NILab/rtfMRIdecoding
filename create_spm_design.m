function create_spm_design(subjectID, rN, cfg)

for session=rN %1:rN-1
    run_path=sprintf('%sSer%04d', cfg.dataPath, session);
    [myonsets, sess_labels]=create_training_ds(subjectID, session, cfg);
    names={'person', 'car'};
    onsets0=myonsets(sess_labels==0);
    onsets1=myonsets(sess_labels==1);
    onsets={onsets0', onsets1'};
    durations={9, 9};
    fname_design=fullfile(cfg.output, sprintf('design_%d_%s.mat', session, subjectID));
    save(fname_design, 'names', 'onsets', 'durations');
end