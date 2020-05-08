Dr. Paul Siefert  
Bee Research Institute Oberursel  
Goethe-University Frankfurt  
siefert@uni-frankfurt.de  

Original research:  
Siefert, P.; Hota, R.; Ramesh, V.; Grünewald, B.  
Chronic within-hive video registrations detect altered nursing behaviour  
and retarded larval development of neonicotinoid treated honey bees.  
Scientific Reports 2020  

# FreeHandDraw - Program to draw lines of interest on Norpix sequences

This script sets the coordinates that can be used by Bresenhams line 
algorithm in order to create a space-time image (STI) from a Norpix
StreamPix sequence file. The saved text file will contain information 
needed in the "STI generation" script (STI_generation_parallel_ver5_SEQ.m).  

Associated files:  
- FreeHandDraw_9_SEQ.m - main code  

# STI_gneration - Program to create STI from Norpix sequences

This script uses line coordinates from FreeHandDraw to create a 
space-time image (STI) from a Norpix sequence. It uses Bresenhams 
algorithm and the parpool argument to use all avalable processor cores. 

Associated files:  
- STI_generation_parallel_ver5_SEQ.m- main code  
- structfind.m - By Dirk-Jan Kroon, also available on MATLAB FileExchange   
- bresenham.m - By Aaron Wetzler, also available on MATLAB FileExchange  
- parsave.m - Workaround to save .mat files while in parfor loop  
- ReadSEQIdxFrame.m - Usage of StreamPix .idx files for compressed sequences 

# Cell Visit Survey - Program for honey bee behavioural studies

This GUI detects cell visits (events) on a space-time image (STI) with a variety of filters. Manual and automated classifications, using VGG16 as convolutional neural network, are possible with option of viewing the corresponding AVI or SEQ file.  

Associated files:  
- CeViS_2_7_4.fig - MATLAB GUI figure file  
- CeViS_2_7_4.m - MATLAB code for figure  
- CeViS_User_Settings.mat - User settings for reload  
- xlswrite1.m - fast xlswrite function by Matt Swartz, also available on MATLAB FileExchange 

**Trained networks are available on request**  
- 4 Classes (Feeding, Building, Heating, Other):  
LW_TrainVgg16_BeeNet4_201807.mat - 489,115 KB  
- 2 Classes (Feeding, Other)  
LW_TrainVgg16Classify_20180625.mat - 488,469 KB  

Fundamental code components have been taken from  
MAGIC - MATLAB Generic Imaging Component by Mark Hayworth  
https://www.mathworks.com/matlabcentral/fileexchange/24224-magic-matlab-generic-imaging-component  
and fragments may appear throughout the script.  
