% -------------------------------------------------------------------------
% STI_gneration - Program to create STI from Norpix sequences
% Dr. Paul Siefert
% Bee Research Institute Oberursel
% Goethe-University Frankfurt
% siefert@uni-frankfurt.de
%
% Original research: 
% Siefert, P.; Hota, R.; Ramesh, V.; Grünewald, B. 
% Chronic within-hive video registrations detect altered nursing behaviour 
% and retarded larval development of neonicotinoid treated honey bees. 
% Scientific Reports 2020
%
% This script uses line coordinates from FreeHandDraw to create a 
% space-time image (STI) from a Norpix sequence. It uses Bresenhams 
% algorithm and the parpool argument to use all avalable processor cores. 
%
% Code evolved from Rudra Hotas original script, former member of the Ramesh
% workgroup. See publication for affiliation details.
% -------------------------------------------------------------------------

clc;
close all;
clear all;

% Paths ----------------------------------
Projectname = 'BOB-15\';
SEQPfad = 'T:\BOB-15\';
LinienPfad = ['D:\CeViS\02_Linien\' Projectname];
STIPfad = ['D:\CeViS\03_STI\' Projectname];
fileList = dir([SEQPfad '*.seq']);
AmountOfVideos = length(fileList);
if ~exist(STIPfad, 'dir')
    mkdir(STIPfad);
end

% Variables -----------------------------
jpgmax = 65499;
FirstPart = 1;
endianType = 'ieee-le';
StartFileNr = 1;
EndFileNr = AmountOfVideos;
if isempty(dir('Temp\*.jpg')) ~= 0
    delete 'Temp\*.jpg'
end

for i = StartFileNr:EndFileNr
    
    fileName = strcat(SEQPfad, fileList(i).name);
    [pathstr,Videoname,ext] = fileparts(fileName);
    
    fid = fopen(fileName,'r','b'); % open the sequence
    fseek(fid,572, 'bof');
    NoOfFramesinVid = fread(fid, 1, 'ulong', endianType);
    fprintf(['Starting SEQ ' num2str(i) ' of ' num2str(EndFileNr) ': ' Videoname ' at time %s\n'], datestr(now,'HH:MM:SS.FFF'))
    
    idxName = [fileName '.idx'];
    fidIdx = fopen(idxName,'r','b');
    if fidIdx < 0
        error('Could not open index file');
    else
        disp('Index loaded');
    end
    
    %% Read Sample Frame for Indexing
    
    disp('Loading sample frame for indexing');
    SampleFrame = ReadSEQIdxFrame(fid, fidIdx, 1, 0);
    fclose(fid);
    fclose(fidIdx);
    
    %% Read Lines from txt file
    % Line amount does not matter in script speed
    disp(['Reading Lines: ' LinienPfad Videoname '_Lines.txt']);
    LineList = dir([LinienPfad '*.txt']);
    LinePosition = structfind(LineList,'name',[Videoname '_Linien.txt']);
    if isempty(LinePosition)
        disp('No Lines found, continuing...');
        continue
    end
    FirstLine = strcat(LinienPfad, LineList(LinePosition).name);
    define_line_points=load(FirstLine);
    noofLines = size(define_line_points,1);
    StartLinie = 1;
    EndLinie = noofLines;
    stiImage_Idx = cell(1,noofLines);
    
    %% Creating Variables
    if ~mod(NoOfFramesinVid,jpgmax)
        AmountOfParts = (NoOfFramesinVid/jpgmax);
    else
        AmountOfParts = ceil(NoOfFramesinVid/jpgmax);
    end
    image_in_black = zeros(2048,420);
    image_in_white = image_in_black;
    image_in_white(:,:) = 255;
    
    %% Creating indices
    disp('Creating Indicies');
    for LineNr = StartLinie:EndLinie
        [x,y] = bresenham(define_line_points(LineNr,2),define_line_points(LineNr,1),define_line_points(LineNr,4),define_line_points(LineNr,3));
        stiImage_Idx{LineNr} = sub2ind(size(SampleFrame),x,y);
    end
    
    %% STI generation
    disp(['Writing STI of ' num2str(noofLines) ' Lines in ' num2str(NoOfFramesinVid) ' frames (' num2str(AmountOfParts) ' parts)']);
    p = gcp('nocreate'); % If no pool, do not create new one.
    if isempty(p)
        poolsize = 8;
    else
        poolsize = p.NumWorkers;
    end
    %parpool(8);
    parfor PartCounter = FirstPart:AmountOfParts % usage of all processor units
        tic
        fid = fopen(fileName,'r','b');
        fidIdx = fopen(idxName,'r','b');
        worker = getCurrentWorker;
        disp(['Starting with Part ' num2str(PartCounter)]);
        stiImage = cell(1,noofLines);
        
        PartStartTime = ((PartCounter-1)*jpgmax)+1;
        if PartCounter*jpgmax >= NoOfFramesinVid
            PartEndTime = NoOfFramesinVid-1;
        else
            PartEndTime = PartCounter*jpgmax;
        end
        jpgmaxOfPart = PartEndTime - PartStartTime +1;
        
        for PartIdx = 1:jpgmaxOfPart
            CurrentFrameTotal = PartStartTime+PartIdx-1;
            CurrentFramePart = CurrentFrameTotal - ((PartCounter-1)*jpgmax);
            
            try
                image_in = ReadSEQIdxFrame(fid, fidIdx, CurrentFrameTotal, worker.ProcessId);
            catch
                msg = ['Error reading frame ' num2str(CurrentFrameTotal) ' in ' Videoname ', Part: ' num2str(PartCounter)];
                disp(msg)
                fidLog = fopen(fullfile(STIPfad, 'STI_gneration_parallel_ver2-Log.txt'), 'a');
                if fidLog == -1
                    error('Cannot open log file.');
                end
                fprintf(fidLog, '%s: %s\r\n', datestr(now, 0), msg);
                fclose(fidLog);
                image_in = image_in_white;
            end
            
            for LineNr = StartLinie:EndLinie
                stiImage{LineNr}(:,CurrentFramePart) = image_in(stiImage_Idx{LineNr});
            end
            
            if ~mod(CurrentFramePart,10000)
                disp(['Part ' num2str(PartCounter) ': Passed Frame ' num2str(CurrentFramePart) ' in ' num2str(round(toc/60,1)) ' minutes']);
            end
        end
        
        %% Save STI as .mat
        
        for LineNr = StartLinie:EndLinie
            stiSave = stiImage{LineNr};
            
            if LineNr > 9
                LinienNummer = '';
            else
                LinienNummer = '0';
            end
            
            if PartCounter > 9
                PartNummer = '';
            else
                PartNummer = '0';
            end
            filename = [STIPfad Videoname '-Linie' LinienNummer num2str(LineNr) '-Part' PartNummer num2str(PartCounter) '.mat'];
            parsave(filename, stiSave);
        end
        disp(['Part ' num2str(PartCounter) ' saved in ' num2str(round(toc/60,1)) ' minutes']);
        fclose(fid);
    end
    disp(['Done with SEQ ' num2str(i) ' of ' num2str(EndFileNr)]);
end
