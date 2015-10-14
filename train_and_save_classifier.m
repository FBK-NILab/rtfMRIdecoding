function train_and_save_classifier(SubjectID, sessionN, cfg)

if cfg.multiSubj==1
    [training_data, training_labels]=train_multisubj_classifier(sessionN, cfg);
else
    [training_data, training_labels]=train_classifier(SubjectID, sessionN, cfg);
end

switch cfg.Classifier
    case 1
        training_labels=arrayfun(@num2str, training_labels, 'UniformOutput', false);
        A = dataset(training_data, training_labels);
        weights = nusvc(A); %svc(A, 'p', 2);
        fname=fullfile(cfg.output, sprintf('Classifier_%d.mat', cfg.Classifier));
        save(fname, 'weights'); 
        
        
    case 2
        [regr_model, coefs]=train_EN_logreg(training_data, training_labels');
        %cfs=train_EN_logreg(training_data, training_labels');
        
        fname=fullfile(cfg.output, sprintf('Classifier_%d.mat', cfg.Classifier));
        save(fname, 'regr_model', 'coefs'); 
        
        
    case 3
        
        %    training_labels=arrayfun(@num2str, training_labels, 'UniformOutput', false);
        libsvm_model = svmtrain(double(training_labels), double(training_data), '-s 1 -t  2 -c 1 -q'); % '-s 1 -t 0 -q'
        
        fname=fullfile(cfg.output, sprintf('Classifier_%d.mat', cfg.Classifier));
        save(fname, 'libsvm_model'); 
        
        
    case 4
        options.alpha =  0.9;
        regression_fit = cvglmnet(training_data, training_labels, 'binomial', options);
        
        fname=fullfile(cfg.output, sprintf('Classifier_%d.mat', cfg.Classifier));
        save(fname, 'regression_fit'); 
        
        
end