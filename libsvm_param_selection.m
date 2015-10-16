function [bestc, bestg]=libsvm_param_selection(data, labels)


bestcv = 0;
for log2c = -2:5, %-1:3
  for log2g = -7:2, %-4:1
    cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
    cv = svmtrain(double(labels), double(data), cmd);
    if (cv >= bestcv),
      bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
      
    end
    
  end
end
fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
return