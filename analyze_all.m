
function analyze_all(Subjects, sessionN, expType, cfg)

for n=1:length(Subjects)
    SubjectID=Subjects{n};
    acc_filename=fullfile(cfg.FeedbackFolder, sprintf('accs_%s_%s_ses%d_classif%d.mat', SubjectID, expType, sessionN, cfg.Classifier));
    load(acc_filename, 'accuracy');
    if n==1
        accuracy_all=accuracy;
    else
        accuracy_all=vertcat(accuracy_all, accuracy);
    end
  
end

mean_acc_all=mean(accuracy_all,1);

fig_filename=fullfile(cfg.FeedbackFolder, sprintf('accs_NofSubj_%d_%s_ses_%d_classif_%d.jpg', length(Subjects), expType, sessionN, cfg.Classifier));
h=plot(mean_acc_all);
title(sprintf('Mean acc per vol in a trial ses %d Nsubj %d experiment type %s', sessionN, length(Subjects), expType));
xlabel('TR number'); % x-axis label
ylabel(sprintf('Accuracy Classifier %d', cfg.Classifier)); % y-axis label
saveas(h, fig_filename);
