function [mdl, cfs]=train_EN_logreg(training_data, training_labels); % [mdl, cfs]=train_EN_logreg(training_data, training_labels);


% deBettencourt used just L2 with alpha=1
[B,FitInfo] = lassoglm(training_data,training_labels','binomial','NumLambda',100, 'Alpha',1.0, 'LambdaRatio',1e-4,'CV', 10, 'Standardize',false); %(training_data,training_labels','binomial','NumLambda',100, 'Alpha',0.9,'LambdaRatio',1e-4,'CV', 10); %, 'Standardize',false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lassoPlot(B,FitInfo,'PlotType','CV');
lassoPlot(B,FitInfo,'PlotType','Lambda','XScale','log');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

indx = FitInfo.Index1SE;
B0 = B(:,indx);
%nonzeros = sum(B0 ~= 0);

cnst = FitInfo.Intercept(indx);
cfs = [cnst;B0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preds = glmval(cfs,training_data,'logit');
histogram(training_labels' - preds); % plot residuals
title('Residuals from lassoglm model')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

predictors = find(B0); % indices of nonzero predictors
mdl = fitglm(training_data,training_labels,'linear',...
    'Distribution','binomial','PredictorVars',predictors);

return;