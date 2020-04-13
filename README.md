# Cell Visit Survey - Program for honey bee behavioural studies

Dr. Paul Siefert
Bee Research Institute Oberursel
Goethe-University Frankfurt
siefert@uni-frankfurt.de

%
% Original research: 
% Siefert, P.; Hota, R.; Ramesh, V.; Grünewald, B. 
% Chronic within-hive video registrations detect altered nursing behaviour 
% and retarded larval development of neonicotinoid treated honey bees. 
% Scientific Reports 2020
%
% This GUI detects cell visits (events) on a space-time image (STI) with a 
% variety of filters. Manual and automated classifications, using VGG16 as 
% convolutional neural network, are possible with option of viewing the
% corresponding AVI or SEQ file.
%
% Associated files:
% * CeViS_2_7_4.fig - MATLAB GUI figure file
% * CeViS_2_7_4.m - MATLAB code for figure
% * CeViS_User_Settings.mat - User settings for reload
% * xlswrite1.m - fast xlswrite function by Matt Swartz available on 
%   https://de.mathworks.com/matlabcentral/fileexchange/10465-xlswrite1
% Trained networks are available on request
% 4 Classes (Feeding, Building, Heating, Other): 
% * LW_TrainVgg16_BeeNet4_201807.mat - 489,115 KB
% 2 Classes (Feeding, Other)
% *LW_TrainVgg16Classify_20180625.mat - 488,469 KB
%
% Fundamental code components have been taken from
% MAGIC - MATLAB Generic Imaging Component by Mark Hayworth 
% https://www.mathworks.com/matlabcentral/fileexchange/24224-magic-matlab-generic-imaging-component
% and fragments may appear throughout the script.
