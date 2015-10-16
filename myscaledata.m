function [min_tr, range_tr, dataout] = myscaledata(datain,minval,maxval)
%
% Program to scale the values of a matrix from a user specified minimum to a user specified maximum
%
% Usage:
% outputData = scaleData(inputData,minVal,maxVal);
%
% Example:
% a = [1 2 3 4 5];
% a_out = scaledata(a,0,1);
% 
% Output obtained: 
%            0    0.1111    0.2222    0.3333    0.4444
%       0.5556    0.6667    0.7778    0.8889    1.0000
%
% Program written by:
% Aniruddha Kembhavi, July 11, 2007
min_tr=min(min(datain(:)));
dataout = datain - min_tr;
range_tr=range(dataout(:));
dataout = (dataout/range_tr)*(maxval-minval);
dataout = dataout + minval;

return