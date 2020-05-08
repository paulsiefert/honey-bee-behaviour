% -------------------------------------------------------------------------
% FreeHandDraw - Program to draw lines of interest on Norpix sequences
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
% This script sets the coordinates that can be used by Bresenhams line 
% algorithm in order to create a space-time image (STI) from a Norpix
% sequence. The saved text file will contain information needed in the "STI
% generation" script (STI_generation_parallel_ver5_SEQ.m).
%
% Code evolved from Rudra Hotas original script, former member of the Ramesh
% workgroup. See publication for affiliation details.
% -------------------------------------------------------------------------

clear all;

% Variables ------------------------
ProjectNumber = 15; % ID
SEQPath = 'T:\BOB-15\'; % Path to Norpix sequences
SEQName = 'D5_2019-07-17_15-12-56.000'; % Sequence name
AddLines = 0; % Set if Lines should not start at 1
% --------------------------------------------------

currentFolder = pwd;
DriveLetter = currentFolder(1:3);
ProjectName = ['BOB-' num2str(ProjectNumber)];
LinePath = [DriveLetter '\CeViS\02_Linien\' ProjectName '\'];
endianType = 'ieee-le';

fileName = [SEQPath SEQName '.seq'];
if(exist([SEQPath SEQName '.seq'], 'file')==0)
    uiwait(msgbox(['The video "' SEQPath SEQName '" does not exist.'],'Error!','modal'));
elseif(exist([SEQPath SEQName '.seq'], 'file')==2)
    if true
        if(exist(LinePath, 'dir')==0)
            mkdir(LinePath);
        end
        
        fid = fopen(fileName,'r','b'); % open the sequence
        fseek(fid,572, 'bof');
        NoOfFramesinVid = fread(fid, 1, 'ulong', endianType);
        
        idxName = [fileName '.idx'];
        fidIdx = fopen(idxName,'r','b');
        if fidIdx < 0
            error('Could not open index file');
        else
            disp('Index loaded');
        end
        
    end
    FirstFrame = ReadSEQIdxFrame(fid, fidIdx, 1, 0);
    LastFrame = ReadSEQIdxFrame(fid, fidIdx, NoOfFramesinVid-1, 0);
    
    FuseBlend = imfuse(FirstFrame,LastFrame,'blend');
    FuseMontage = imfuse(FirstFrame,LastFrame,'montage');
    imwrite(FuseBlend,[LinePath SEQName '.png']);
    imwrite(FuseMontage,[LinePath SEQName '_montage.png']);
end
% -----------------------------------------

b = figure;
imshow(LastFrame);

LIO = {};
choiceLio = 1;
counter = 1;

while ( choiceLio ~= 0)

    % Construct a questdlg with three options
    list = {'Add New Line', 'Add Cell Number Line', 'Modify Line','End'};
    
    [choice,~] = listdlg('ListString',list,'SelectionMode','single','InitialValue',2,'ListSize',[150,150]);
    %     % Handle response
    switch choice
        case 3
            choiceLio = 3;
        case 1
            disp(['--Adding Line: ' num2str(counter)])
            cellNrEntry = 0;
            choiceLio = 1;
        case 4
            disp('--Line of interest - Done')
            choiceLio = 0;
            if(exist('h','var')==0)
                uiwait(msgbox('No line set.','Fehler!','modal'));
            end
        case 2
            prompt = {'Enter cell number:'};
            dlgtitle = 'Input';
            dims = [1 20];
            definput = {''};
            cellNumber = inputdlg(prompt,dlgtitle,dims,definput);
            cellNrEntry = 1;
            choiceLio = 1;
    end
    
    if(1==choiceLio)
        h(counter) = imline(); data=get(h(counter));
        LIO{end+1}=get(data.Children(4));
        koords = [LIO{counter}.XData(1) LIO{counter}.YData(1)];
        display(koords);
        xkoords = koords(1,1);
        ykoords = koords(1,2)-10;
        if cellNrEntry == 1
            text(xkoords,ykoords,['Linie ' num2str(counter+AddLines) '; C#' cellNumber{1,1}],'Color','w','FontSize',8);
        else
            text(xkoords,ykoords,['Linie ' num2str(counter+AddLines)],'Color','w','FontSize',8);
        end
        cellNrEntry = 0;
        counter = counter+1;
        
    elseif(3==choiceLio) % modify line
        prompt = {'Which Line?'};
        dlg_title = 'Input';
        num_lines = 1;
        def = {'1'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        LineToModify = answer{1,1};
        display(['--Modifieing Line: ' LineToModify]);
        Lin = str2num(LineToModify);
        delete(h(Lin));
        h(Lin) = imline(); data=get(h(Lin));
        LIO{Lin}=get(data.Children(4));
        
    end
   
    
end
numel(LIO);

% savinging into .txt file
data=[];
for i=1:length(LIO)
    data = [data; uint16([LIO{i}.XData(1) LIO{i}.YData(1) LIO{i}.XData(end) LIO{i}.YData(end)]) ];
end
dlmwrite([LinePath SEQName '_Linien.txt'], data, 'delimiter', ' ');

% save overview image
movegui(b)
f = getframe(gca);
img = frame2im(f);
imwrite(img, [LinePath SEQName '_Linien.png']);
close all;