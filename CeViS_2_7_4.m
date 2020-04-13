function varargout = CeViS_2_7_4(varargin)
% CeViS_2_7_4 MATLAB code for CeViS_2_7_4.fig
% -------------------------------------------------------------------------
% Cell Visit Survey - Program for honey bee behavioural studies
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
%
%                                            *,,
%                                            (/&
%                                               ,                   /,#
%                                                (                  *,(
%                                                 /
%                                                 ,
%                                                  .  *,,,/.,,,,     *
%                  %     #       .     %   ((,,,,,,/,,,,,,,*,,,(     (
%                 %         *           /,,,,,,,,,,#/,,,,,,,,,,,,,,//
%                             .%     /.,,,,,,,,*,,,,,,,,,,,,,,,,,,,/(
%                 .            &    ,,,,,,,,*,,,,,,,,,,,,,,,,,,,,,/*(
%                 %            #  ,,,,,,,,,,(,,,,.,#/,,/.*,,,,,%(,,,,.
%                              #  ,,,,#,,,,,(,,,,,,,,,,,,,.,,,,*,,,,,,*
%                  .              *#,,.%,,,,,,,,#  %,,,,,,/,,,,.,,,,,,,
%                               ( *,,,((,,,,,,#/    *,/*.(,,,,(,,,,,,,,
%                     (          #,,&,,,,,/,,,@@,  #/     ,,*,,,,,,,.#,
%                      /         *,./,,,,,,,,,&.(*(%&&   (,,,,,,,,,,,/
%                        &       #,,*,,,,,#,,,,,,,,,(   %,,,,,,,,,,,,*
%                          %       ,#,,,,,,&,,,,,,,,/,,,,,,,,,/,,,,,,#
%                       .%@@&@      ,,,,,,,@@&,,,,,,,,,,,,,(/,*,,,,,.
%              ./,,,  @@@&&@#,,,(.   @,,,,%&&@@@@@&%%*,,,,,,,(,(,,,,#
%            &,,,,,,&@@&@@,,,,,,&@@,,,/,,,#((#&@@@,,,,,,,,,,,(,,*,,/
%         %,,,,,,,,%@&@&(,,,,,,@&@,,,,*%@,,,%##(,,,,,,,,,,*,,,#
%      &,,,,,,,*,,*/,,&(,,,,,,&@@&,,,,/,,&@&*,,,,,,,,,,%,,*(,,/    .*
%    %,,,,,,,,#,,(,,,%@,,,,,,,@&@*,,,,%,,,,,,(,,,,,,,,,,,,,,,,,,,,,,%
%   .,,,,,,,,(,,,,,,#&&,,,,,,*&&@,,,,,#,,,,,*      .,*(#(*,,,,,,#
%    .%##%#%/%,,,,,&@@&,,,,,,,&&&,,,,,@@*,#                ,,,,(
%   .(,,,,,,,(,,*(,,,@@*,,,,,,*&%,,,,/@&&                   /%
% ,,,,,,,,,,,,,,,,,,/%%&*,,,,,,,/,,,,&,
% ,,,,,,,,,,,,,,**          /%%/,,,,,.
% %/,,,,,,,*##                 #,,,,(
%                          /*,,,,,,(
%                     #,,*,,,,,,,,%
%                    #*//,,,,,,,,(#
%                        #,,,,,,,#
%                      %,,,/  #,,(
%                      ,,*     #,,#
%
% -------------------------------------------------------------------------
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CeViS_2_7_4_OpeningFcn, ...
    'gui_OutputFcn',  @CeViS_2_7_4_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- STARTUP AND GENERAL ********************************************
%=====================================================================
% --- Executes just before CeViS is made visible.
function CeViS_2_7_4_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CeViS_2_1 (see VARARGIN)

% Choose default command line output for CeViS_2_1
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CeViS_2_1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%=====================================================================
% --- My Startup Code --------------------------------------------------
% Clear old stuff from console.

% Change the current folder to the folder of this m-file.
% (The line of code below is from Brett Shoelson of The Mathworks.)
cd(fileparts(which(mfilename)));

% MATLAB QUIRK: Need to clear out any global variables you use anywhere
% otherwise it will remember their prior values from a prior running of the macro.
clear global;

handles.macroFolder = cd;
%set(handles.figMainWindow, 'Visible', 'off');

% Load up the initial values from the mat file.
handles = LoadUserSettings(handles);

% If the image folder does not exist, but the imdemos folder exists, then point them to that.
if exist(handles.ImageFolder, 'dir') == 0
    % Folder stored in the mat file does not exist.  Try the imdemos folder instead.
    imdemosFolder = fileparts(which('cameraman.tif')); % Determine where demo images folder is (works with all versions).
    if exist(imdemosFolder, 'dir') == 0
        % imdemos folder exists.  Use it.
        handles.ImageFolder = imdemosFolder;
    else
        % imdemos folder does not exist.  Use current folder.
        handles.ImageFolder = cd;
    end
end

if exist(handles.SaveFolder, 'dir') == 0
    % Folder stored in the mat file does not exist.  Try the imdemos folder instead.
    imdemosFolder = fileparts(which('cameraman.tif')); % Determine where demo images folder is (works with all versions).
    if exist(imdemosFolder, 'dir') == 0
        % imdemos folder exists.  Use it.
        handles.SaveFolder = imdemosFolder;
    else
        % imdemos folder does not exist.  Use current folder.
        handles.SaveFolder = cd;
    end
end

% handles.ImageFolder will be a valid, existing folder by the time you get here.
set(handles.txtFolder, 'string', handles.ImageFolder);
set(handles.txtSave, 'string' ,handles.SaveFolder);
set(handles.selectvideo_text, 'string' ,handles.VideoFile);
set(handles.bob_number, 'string' ,handles.RepetitionString);

%uiwait(msgbox(handles.ImageFolder));
% Load list of images in the image folder.
handles = LoadImageList(handles);
% Select none of the items in the listbox.
set(handles.lstImageList, 'value', 1);
% Update the number of images in the Analyze button caption.
%UpdateAnalyzeButtonCaption(handles);

hold off;	% IMPORTANT NOTE: hold needs to be off in order for the "fit" feature to work correctly.


set(handles.axes1, 'visible', 'off');	% Hide plot of results since there are no results yet.
set(handles.axes2, 'visible', 'off');
set(handles.axes3, 'visible', 'off');
set(handles.axes5, 'visible', 'off');
set(handles.axes6, 'visible', 'off');
set(handles.slider1, 'visible', 'off')
set(handles.lstLog, 'String', {'Welcome to CeViS. Logging is active...'});

handles.oviposition = [];
handles.larvalHatch = [];
handles.capping = [];
handles.prepupa = [];

Initialization(handles)
guidata(hObject, handles); % Update handles structure

% --- load user settings.
function handles = LoadUserSettings(handles)
try
    % Load up the initial values from the mat file.
    matFullFileName = fullfile(handles.macroFolder, 'CeViS_User_Settings.mat');
    if exist(matFullFileName, 'file')
        % Pull out values and stuff them in structure initialValues.
        initialValues = load(matFullFileName);
        % Assign the image folder from the lastUsedImageFolder field of the structure.
        handles.ImageFolder = initialValues.lastUsedImageFolder;
        handles.SaveFolder = initialValues.lastUsedSaveFolder;
        handles.VideoFile = initialValues.lastUsedVideoFile;
        handles.RepetitionString = initialValues.lastRepetitionString;
        % Get the last state of the Send to Excel checkbox.
        % chkSendToExcel = initialValues.guiSettings.chkSendToExcel;
        % Send that value to the checkbox control on the GUI.
        % set(handles.chkSendToExcel, 'Value', chkSendToExcel);
    else
        % If the mat file file does not exist yet, save the settings out to a new settings .mat file.
        SaveUserSettings(handles);
    end
catch ME
    errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    WarnUser(errorMessage);
end
return; % from LoadUserSettings()

% --- save user settings.
function SaveUserSettings(handles)
try
    % Save the current folder they're looking at.
    lastUsedImageFolder = handles.ImageFolder;
    lastUsedSaveFolder = handles.SaveFolder;
    lastUsedVideoFile = handles.VideoFile;
    lastRepetitionString = handles.RepetitionString;
    % Get current value of GUi controls, like checkboxes, etc.
    % guiSettings.chkSendToExcel = get(handles.chkSendToExcel, 'Value');
    % Save all the settings to a .mat file.
    save('CeViS_User_Settings.mat', 'lastUsedImageFolder', 'lastUsedSaveFolder', 'lastUsedVideoFile', 'lastRepetitionString');
catch ME
    errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    WarnUser(errorMessage);
end
return; % from SaveUserSettings()

% --- display warning message.
function WarnUser(warningMessage)
fprintf(1, '%s\n', warningMessage);
uiwait(warndlg(warningMessage));
return; % from WarnUser()

% --- initialize variables.
function Initialization(handles)

global Projektname
Projektname = get(handles.bob_number,'String');

global zelllinie
zelllinie = [212 330 337 319];

global FeedingEvents
FeedingEvents = cell(0);

global UnclassifiedEvents
UnclassifiedEvents = cell(0);

global HeatingEvents
HeatingEvents = cell(0);

global BuildingEvents
BuildingEvents = cell(0);

global InspectionEvents
InspectionEvents = cell(0);

global FeedingEventsSaveTemp
FeedingEventsSaveTemp = cell(0);

global UnclassifiedEventsSaveTemp
UnclassifiedEventsSaveTemp = cell(0);

global HeatingEventsSaveTemp
HeatingEventsSaveTemp = cell(0);

global BuildingEventsSaveTemp
BuildingEventsSaveTemp = cell(0);

global InspectionEventsSaveTemp
InspectionEventsSaveTemp = cell(0);

global potNoFeedingNo
potNoFeedingNo = 0;

%global sorted
%sorted = [];

global Classifier2Checked
Classifier2Checked = get(handles.use_2C_classifier_checkbox, 'Value');

global Classifier4Checked
Classifier4Checked = get(handles.use_4C_classifier_checkbox, 'Value');

global BeeNetClassifierType
BeeNetClassifierType = 0;

global toggleAltKeyPressed
toggleAltKeyPressed = 0;



% --- DETECT EVENTS FUNCTIONS  ***************************************
%=====================================================================
% --- reset all event lists.
function ResetAllEventLists()
global FeedingEvents
global HeatingEvents
global BuildingEvents
global UnclassifiedEvents
global InspectionEvents
FeedingEvents(:) = [];
HeatingEvents(:) = [];
BuildingEvents(:) = [];
UnclassifiedEvents(:) = [];
InspectionEvents(:) = [];

% --- used if several STI are classified in sequence.
function BatchDetection(handles)
global selectedListboxItem

if get(handles.batch_processing_checkbox,'Value')
    set(handles.Analysis_btn,'Visible','off')
    set(handles.continue_button,'Visible','on')
    index_selected = get(handles.lstImageList,'Value');
    batch_size = str2double(get(handles.batch_size,'String'));
    list_size = size(get(handles.lstImageList,'String'),1);
    
    if batch_size == 0
        batch_size = list_size+1 - index_selected;
    end
    
    batch_end = index_selected-1 + batch_size;
    if batch_end > list_size
        batch_size = batch_size - (batch_end - list_size);
    end
    for i = 1:batch_size
        msg = ['Loading file ' num2str(i) ' of ' num2str(batch_size)];
        logDisplay(msg, handles)
        LoadImage(handles)
        uiwait(gcf);
        DetectEvents(handles)
        index_selected = get(handles.lstImageList,'Value');
        if i ~= batch_size
            set(handles.lstImageList,'Value',index_selected+1)
        end
        selectedListboxItem = get(handles.lstImageList,'Value');
    end
    set(handles.Analysis_btn,'Visible','on')
    set(handles.continue_button,'Visible','off')
else
    DetectEvents(handles)
end

% --- detect events within STI.
function DetectEvents(handles)
global BwImage
global imgOriginal
global basefilename
global cellFilter
global LevelImage
global potNoFeedingNo
global Classifier2Checked
global Classifier4Checked

ResetAllEventLists()
cellFilter(:) = [];
potNoFeedingNo = 0;

SetPointerWatch()

if Classifier2Checked
    AnalysisMessage = ['Analyzing ' basefilename ' (2 Classes)'];
elseif Classifier4Checked
    AnalysisMessage = ['Analyzing ' basefilename ' (4 Classes)'];
else
    AnalysisMessage = ['Analyzing ' basefilename ' (no Classifyier)' ];
end

logDisplay(AnalysisMessage, handles)

smoothing = 0;
fps = 30;
winSize = 300;
LevelThersh = [0, 25, 65];
% LevelDuration = fps;
cellVisits = cell(2, 1);
localGradThresh = 0;
prozent = str2double(get(handles.level3percent, 'String'));
minimum_visit_length = str2double(get(handles.minimum_visit_length, 'String'));
maximum_visit_length = str2double(get(handles.maximum_visit_length,'String'));
graustufe = str2double(get(handles.thrsh_worker, 'string'));
larval_threshold = str2double(get(handles.thrshLarva, 'String'));

cut_image_by = str2double(get(handles.cutImage, 'String'));
I = BwImage;

%% Detect Larva & Noise Levels

SetLarvalLevel(handles);
if get(handles.auto_detect_noise_level,'Value') == 1
    DetectNoiseLevelHough(handles)
end
%%

if size(I,1) ~= size(LevelImage,1) % *********** 08.06.2018 added CutImageBy Correction ******
    LevelImage = LevelImage(1:size(I,1),:);
end

[Gmag,~] = imgradient(I);
winGrad = mean(Gmag);

% percentation of coveragage on each x(frame) location.
percCover = zeros(1,size(I,2));

% levels at each x(frame) location.
levelLine = zeros(1,size(I,2));

% processin with the windows for level computation.
for j = 1:winSize:size(I,2)
    endJ = winSize;
    if(j> (size(I,2)-winSize))
        endJ = size(I,2)-j;
    end
    localGrad = mean(winGrad(j:j+endJ));
    if(localGrad > localGradThresh)
        for k = j:j+endJ
            localBW = I(:,k);
            localLevel = LevelImage(:,k);
            % Korrektur der LevelLine +1, sonst fehlerhaft bei markierten
            % Bienen mit weißem Nummernschild bei -1, also bei 100 % weiß
            BlackLine = (length(localLevel) - nnz(localLevel))+1;
            percBlack = ((length(localBW) - nnz(localBW)) / BlackLine )*100;
            percCover(1, k) = percBlack;
        end
    end
end

PartIdx = str2double(basefilename(end-1:end));
cellVisits{1, PartIdx} = [percCover; levelLine];


% begin smoothing

if(smoothing==0), Y = (cellVisits{1, PartIdx}(1,:)); end
if(smoothing==1)
    Y = smooth(cellVisits{1, PartIdx}(1,:),3) .';
    cellVisits{1, PartIdx}(1,:) = Y;
end

% smoothing ausgabe
%
% dimension = size(BwImage);
% hoehe = dimension(1,1);
%
% neu = cellVisits{1,PartIdx}(1,:);
% laenge = length(cellVisits{1,PartIdx}(1,:));
%
% bild = zeros(hoehe,laenge);
%
% for i = 1: laenge
%
%     prozAusfall = neu(1,i)*hoehe/100;
%
%     for z = 1:prozAusfall
%
%         bild(z,i)=1;
%
%     end
%
% end

%imgUpsideDown = flip(bild,1);
%IM2 = imcomplement(imgUpsideDown);
%imwrite(IM2, 'HUHU.png');

% begin analyzing

for u = 1:size(cellVisits{1,PartIdx},2)
    analyze = cellVisits{1,PartIdx}(1,u);
    level = 0;
    if(analyze > 0)
        
        if(analyze > LevelThersh(1) && analyze <= LevelThersh(2) )
            level = 1 ;
        elseif(analyze > LevelThersh(2) && analyze <= LevelThersh(3))
            level = 2 ;
        elseif(analyze > LevelThersh(3) )
            level = 3;
        end
        
        cellVisits{1,PartIdx}(2,u) = level;
        
    end
end

levelLine = cellVisits{1,PartIdx}(2,:);

% ---------------------------------------------------------------
idx = Y>0;
idx = ((idx(1:end-1) - idx(2:end)) ~= 0 );
if(Y(1) >0)
    idx(1) =1; end
if(mod(sum(idx),2) ==1)
    idx(end)= 1; end
xAccumulation =[];

d = [graustufe prozent minimum_visit_length maximum_visit_length larval_threshold cut_image_by];
d1 = [];

% display(['Cell number: ', num2str(PartIdx)] );

% for each  visit we compute above mentioned informations.
if(sum(idx)>1)
    x = find(idx==1) ;
    if (mod(length(x),2) ~= 0)
        r = length(x)+1;
        x(r) = size(imgOriginal,2);
    end
    xAccumulation = cell(4,length(x)/2);
    for j=1:2:length(x)
        
        new = x(j)+1; % HIER +1 SETZEN UM ZU VERHINDERN DASS ES BEI 0 ANFÄNGT
        % display(['start and end location  ', num2str([new x(j+1)]) ]) ;
        
        frameLength = x(j+1) - x(j);
        %duration = frameLength / fps;
        startTime = x(j)/fps;  % from the start of the video time.
        
        startFrame = x(j);
        TotalStartFrame = ((PartIdx-1) * 65499) + x(j);
        endFrame = startFrame + frameLength;
        
        if(numel(num2str(floor(startTime/3600)))==1)
            nullStunde = '0';
        else
            nullStunde = '';
        end
        
        if(numel(num2str(floor(mod(startTime,3600)/60)))==1)
            nullMinute = '0';
        else
            nullMinute = '';
        end
        
        if(numel(num2str(floor(mod(startTime,60))))==1)
            nullSekunde = '0';
        else
            nullSekunde = '';
        end
        
        startZeit = {[nullStunde num2str(floor(startTime/3600)) ':' nullMinute num2str(floor(mod(startTime,3600)/60)) ':' nullSekunde num2str(floor(mod(startTime,60)))]};
        
        
        level1Length = length(find(levelLine(x(j):x(j+1))==1));
        level2Length = length(find(levelLine(x(j):x(j+1))==2));
        level3Length = length(find(levelLine(x(j):x(j+1))==3));
        
        %level1Duration = level1Length/fps;
        %level2Duration = level2Length/fps;
        %level3Duration = level3Length/fps;
        
        level1Percent = level1Length/frameLength*100;
        level2Percent = level2Length/frameLength*100;
        level3Percent = level3Length/frameLength*100;
        
        
        
        % BEGIN TOTAL TIME CALCULATION %
        
        % Get Start Time from Filename
        StartYear = str2double(basefilename(4:7));
        StartMonth = str2double(basefilename(9:10));
        StartDay = str2double(basefilename(12:13));
        StartHour = str2double(basefilename(15:16));
        StartMinute = str2double(basefilename(18:19));
        StartSecond = str2double(basefilename(21:22));
        
        % Put Start Time in Cell
        Time = cell(1,5);
        Time{1,1} = StartMonth;
        Time{1,2} = StartDay;
        Time{1,3} = StartHour;
        Time{1,4} = StartMinute;
        Time{1,5} = StartSecond;
        
        % Get Frames to Add / 1 Frame = 1 Second
        FramesToAdd = TotalStartFrame;
        
        SecDay = 86400; %Seconds in a day
        
        % Calculate the numer of Hours etc to Add to Start Time
        ToAddDays = floor(FramesToAdd/SecDay);
        ToAddHours = floor(mod(FramesToAdd,SecDay)/3600);
        ToAddMinutes = floor(mod(FramesToAdd,3600)/60);
        ToAddSeconds = floor(mod(FramesToAdd,60));
        
        % Check if Month has 31 days
        Month31 = [1 3 5 7 8 10 12];
        if find(Month31 == StartMonth)
            MonthDays = 31;
            %SecMonth = 2678400;
        else
            MonthDays = 30;
            %SecMonth = 2592000;
        end
        
        % Add Time to Start Time
        TimeAdded = cell(1,5);
        TimeAdded{1,1} = Time{1,1};
        TimeAdded{1,2} = Time{1,2} + ToAddDays;
        TimeAdded{1,3} = Time{1,3} + ToAddHours;
        TimeAdded{1,4} = Time{1,4} + ToAddMinutes;
        TimeAdded{1,5} = Time{1,5} + ToAddSeconds;
        
        % Convert surplus
        if (TimeAdded{1,5} >= 60)
            TimeAdded{1,4} = TimeAdded{1,4} + 1;
            TimeAdded{1,5} = TimeAdded{1,5} - 60;
        end
        
        if (TimeAdded{1,4} >= 60)
            TimeAdded{1,3} = TimeAdded{1,3} + 1;
            TimeAdded{1,4} = TimeAdded{1,4} - 60;
        end
        
        if (TimeAdded{1,3} >= 24)
            TimeAdded{1,2} = TimeAdded{1,2} + 1;
            TimeAdded{1,3} = TimeAdded{1,3} - 24;
        end
        
        if (TimeAdded{1,2} > MonthDays)
            TimeAdded{1,1} = TimeAdded{1,1} +1;
            TimeAdded{1,2} = TimeAdded{1,2} - MonthDays;
        end
        
        % Create the Timestring
        if(numel(num2str(TimeAdded{1,1}))==1)
            nullMonth = '0';
        else
            nullMonth = '';
        end
        if(numel(num2str(TimeAdded{1,2}))==1)
            nullDays = '0';
        else
            nullDays = '';
        end
        if(numel(num2str(TimeAdded{1,3}))==1)
            nullHours = '0';
        else
            nullHours = '';
        end
        
        if(numel(num2str(TimeAdded{1,4}))==1)
            nullMinutes = '0';
        else
            nullMinutes = '';
        end
        
        if(numel(num2str(TimeAdded{1,5}))==1)
            nullSeconds = '0';
        else
            nullSeconds = '';
        end
        
        totalTime = {[ nullDays num2str(TimeAdded{1,2}) '-' nullMonth num2str(TimeAdded{1,1}) '-' num2str(StartYear) ' ' nullHours num2str(TimeAdded{1,3}) ':'  nullMinutes num2str(TimeAdded{1,4}) ':' nullSeconds num2str(TimeAdded{1,5}) ]};
        
        
        % END TOTAL TIME CALCULATION %
        
        
        
        
        
        %d1 =  [ frameLength, startFrame, endFrame, duration, level1Length, level2Length, level3Length, level1Duration, level2Duration, level3Duration, level1Percent, level2Percent, level3Percent  ];
        d1 =  [ frameLength, startFrame, endFrame, TotalStartFrame, level1Length, level2Length, level3Length, level1Percent, level2Percent, level3Percent, PartIdx];
        
        if(smoothing==0), xAccumulation{1, ceil(j/2)} = [ new : x(j+1); percCover(new:x(j+1))  ]; end
        if(smoothing==1), xAccumulation{1, ceil(j/2)} = [ new : x(j+1); Y(new:x(j+1))  ]; end
        
        xAccumulation{2, ceil(j/2)} = d;
        xAccumulation{3, ceil(j/2)} = d1;
        xAccumulation{4, ceil(j/2)} = startZeit;
        xAccumulation{5, ceil(j/2)} = totalTime;
    end
    
    
    
end

cellVisits{2, PartIdx} = xAccumulation;


% write FilterList

Filterbesuch = 1;

if ~isempty(cellVisits{2,PartIdx})
    AnzahlVisits = size(cellVisits{2,PartIdx},2);
    for VisitCounter=1:AnzahlVisits
        % if (cellVisits{2,PartIdx}{3,VisitCounter}(1,1) >= minimum_visit_length && cellVisits{2,PartIdx}{3,VisitCounter}(1,1) <= 300)
        if (cellVisits{2,PartIdx}{3,VisitCounter}(1,1) >= minimum_visit_length && cellVisits{2,PartIdx}{3,VisitCounter}(1,1) <= maximum_visit_length && cellVisits{2,PartIdx}{3,VisitCounter}(1,10) >= prozent)
            %if (cellVisits{2,PartIdx}{3,VisitCounter}(1,1) >= minimum_visit_length && cellVisits{2,PartIdx}{3,VisitCounter}(1,1) <= 300 && cellVisits{2,PartIdx}{3,VisitCounter}(1,10) >= prozent && cellVisits{2,PartIdx}{3,VisitCounter}(1,9) >= 10);
            cellFilter{Filterbesuch,1} = cellVisits{2,PartIdx}{3,VisitCounter}; % frameLength, startFrame, endFrame, TotalStartFrame, level1Length, level2Length, level3Length, level1Percent, level2Percent, level3Percent, PartIdx
            cellFilter(Filterbesuch,2) = cellVisits{2,PartIdx}{5,VisitCounter}; % Time
            cellFilter{Filterbesuch,3} = cellVisits{2,PartIdx}{2,VisitCounter}; % graustufe, prozent, minimum_visit_length, maximum_visit_length, thrsh larva, cut image
            Filterbesuch = Filterbesuch+1;
        end
    end
end
% msgbox('Analysis Complete','Success');

assignin('base', 'cellFilter', cellFilter);
assignin('base', 'cellVisits', cellVisits);

CheckClassifierOptions(handles)

% --- set space that is occupied by the larva on STI top.
function SetLarvalLevel(handles)
global imgOriginal
global LevelImage

thrshLarva = str2double(get(handles.thrshLarva,'String'));
LevelImage = imbinarize(imgOriginal, thrshLarva);

hoehe = size(LevelImage, 1);
breite = size(LevelImage, 2);
imgMod = zeros(hoehe, breite);
LarvalLevelLineIndex = ones(1, breite);

for i = 1:breite
    spalte = LevelImage(:,i);
    h = find(spalte == 1);
    if(h>0)
        beginn = h(end);
        LarvalLevelLineIndex(1,i) = beginn;
        ende = 1;
        for z = ende:beginn
            spalte(z,1) = 1;
        end
    end
    imgMod(:,i) = spalte;
end
%imwrite(imgMod, 'temp2_bw.png'); % *********** 08.06.2018 corrected LevelImage ******
LevelImage = logical(imgMod); % *********** 13.06.2018 ***********

imgLevel = cat(3, imgOriginal, imgOriginal, imgOriginal);
for u = 1:size(imgLevel,2)
    if LarvalLevelLineIndex(1,u) ~= 1
        imgLevel(LarvalLevelLineIndex(1,u),u,1) = 255;
        imgLevel(LarvalLevelLineIndex(1,u),u,2) = 0;
        imgLevel(LarvalLevelLineIndex(1,u),u,3) = 0;
    end
end
% assignin('base','imgLevel',imgLevel);
imshow(imgLevel, 'InitialMagnification', 'fit', 'Parent', handles.axes1);
startframe = str2double(get(handles.frameposition, 'String'));
setXlim(handles, startframe)

% --- detection of space that is not the cell on STI bottom.
function DetectNoiseLevelHough(handles)
% Detect larva level by hough transformation (unused)
global imgOriginal

FillGap = 50; % Set distance of which lines will be connected (eg 5 or 50)
Threshold = 0.25; % 0.7 to Detect Larva
%level = graythresh(I)
BW2 = imbinarize(imgOriginal,Threshold);
BW2 = imfill(BW2,'holes');
imwrite(BW2, 'tempLarvalLevel_bw2.png');
BW = edge(BW2,'canny');
imwrite(BW, 'tempLarvalLevel_bw.png');
[H,T,R] = hough(BW);
P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(BW,T,R,P,'FillGap',FillGap,'MinLength',7);
% figure, imshow(I), hold on
max_len = 0;
y1 = 0;
y2 = 0;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    
    % Plot beginnings and ends of lines
    %plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    %plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    
    % Determine the endpoints of the longest line segment
    len = norm(lines(k).point1 - lines(k).point2);
    y1 = y1 + lines(k).point1(1,2);
    y2 = y2 + lines(k).point2(1,2);
    if ( len > max_len)
        max_len = len;
        xy_long = xy;
    end
end
if max_len == 0
    hMeanAllLines = 1;
    hMaxLongestLine = 1;
else
    hMeanAllLines = ((y1/length(lines))+(y2/length(lines)))/2;
    [hMaxLongestLine, ~] = max(xy_long(:,2));
end
%Difference = norm(hMeanAllLines - hMaxLongestLine);
LinePosition = hMaxLongestLine-10;

% hLine = [1 hMaxLongestLine; size(BW,2) hMaxLongestLine];
% mLine = [1 hMeanAllLines; size(BW,2) hMeanAllLines];
assignin('base','hLine',hMaxLongestLine);
assignin('base','mLine',hMeanAllLines);

axes(handles.axes1);
hold on;
line([1,65499],[LinePosition,LinePosition],'Color','blue','LineWidth',1);
hold off;

%plot(hLine(:,1),hLine(:,2),'LineWidth',1,'Color','red');

%imshow(image, 'InitialMagnification', 100, 'Parent', handles.axes2);

%line

% Highlight the longest line segment by coloring it cyan.
% LongestLineRow = ceil((xy_long(1,2)+ xy_long(2,2)) / size();
%
% LevelImage = zeros(size(imgOriginal,1),size(imgOriginal,2));
% LevelImage(1:hMaxLongestLine,:) = 1;
% LevelImage = logical(LevelImage);

cutImgBy = size(imgOriginal,1) - LinePosition;
set(handles.cutImage,'String', num2str(cutImgBy))
Convert(handles)

% --- run program according to classification options.
function CheckClassifierOptions(handles)
global Classifier2Checked
global Classifier4Checked
global cellFilter

messageAppeared = 0;
potFeedingNo = 1;
potFeedingAmount = size(cellFilter, 1);
set(handles.txtPotFeedingAmount, 'String', num2str(potFeedingAmount));
set(handles.txtPotFeedingNumber, 'String', num2str(potFeedingNo));

RejectChecked = get(handles.reject_events_checkbox, 'Value');
AcceptChecked = get(handles.accept_events_checkbox, 'Value');
QuickChecked = get(handles.quick_analysis_checkbox, 'Value');



if ~isempty(cellFilter)
    % ============================== 2C
    if Classifier2Checked
        ImageClassification(handles)
        set(handles.save_data_to_temp_btn,'Enable','on');
        
        if RejectChecked
            Reject_Events(handles)
        end
        if AcceptChecked
            Accept_Events(handles)
        end
        if QuickChecked
            save_data_to_temp(handles)
        end
        ColorizeBwImage(handles)
        
        if ~isempty(cellFilter)
            Display_Unsure_EventAmount(handles)
            DisplayEvent(handles)
        else
            SetPointerArrow()
            msg = 'All events classified.';
            logDisplay(msg, handles)
            messageAppeared = 1;
        end
        if ~messageAppeared
            SetPointerArrow()
            msg = 'Automatic 2C classification complete.';
            logDisplay(msg, handles)
        end
        
        % ============================== 4C
    elseif Classifier4Checked % Use Classifier (4 Classes)
        ImageClassification(handles)
        SortClassifiedEvents(handles)
        save_data_to_temp(handles)
        SetPointerArrow()
        msg = 'Automatic 4C classification complete.';
        logDisplay(msg, handles)
        % ============================== No Classifier
    else
        Display_Unsure_EventAmount(handles)
        DisplayEvent(handles)
    end
else
    SetPointerArrow()
    msg = 'Es gibt keine Ereignisse';
    logDisplay(msg, handles)
end



% --- CLASSIFICATION FUNCTIONS  **************************************
%=====================================================================
% --- loop to run through list of events that should be classified by CNN.
function ImageClassification(handles)
global cellFilter
global imgOriginal
tic
for ImageNo = 1:size(cellFilter,1)
    StartFrame = cellFilter{ImageNo,1}(1,2); % start point for Crop image
    Duration = cellFilter{ImageNo,1}(1,1); % width for Crop image
    Height = size(imgOriginal,1); % height for Crop image
    ImageToClassify = imcrop(imgOriginal,[StartFrame 1 Duration Height]);  % Crop the image
    %PreProcessedImage
    PreProcessedImage = readFunctionTrain(ImageToClassify);
    Predictions  = Classify(PreProcessedImage); % Use NNet function to classify
    cellFilter{ImageNo,5} = Predictions; % write
end
msg = ['Image classification completed in ' num2str(round(toc,1)) ' seconds.'];
logDisplay(msg, handles)

% --- pre-process image to fit CNN.
function PreProcessedImage = readFunctionTrain(I)
width = size(I,2);
hight = size(I,1);

if width < 227
    altered_w = 227 - width;
    I = padarray(I,[0 altered_w],'post');
elseif width > 227
    I = imcrop(I,[0 0 227 227]);
end

if hight < 227
    altered_h = 227-hight;
    I = padarray(I,[altered_h,0], 'post');
elseif height > 227
    I = imcrop(I,[0 0 227 227]);
end

% Some images may be grayscale.
% Replicate the image 3 times to create an RGB image.
if ismatrix(I)
    I = cat(3,I,I,I);
end
PreProcessedImage = I;
return

% --- predict behaviour.
function Predictions = Classify(PreProcessedImage)
global BeeNetClassifier
global Classifier2Checked
global Classifier4Checked

if Classifier2Checked
    preds = predict(BeeNetClassifier, PreProcessedImage);
    FeedPred = preds(1,1);
    OtherPred = preds(1,2);
    %HeatPred = 0;
    %BuildPred = 0;
    Predictions = [FeedPred, OtherPred];
elseif Classifier4Checked
    preds = predict(BeeNetClassifier, PreProcessedImage);
    BuildPred = preds(1,1);
    FeedPred = preds(1,2);
    HeatPred = preds(1,3);
    OtherPred = preds(1,4);
    Predictions = [FeedPred, OtherPred, HeatPred, BuildPred];
end
return

% --- reject events below precision threshold.
function Reject_Events(handles)
global cellFilter
global FeedingEvents
global UnclassifiedEvents

rejectLevel = str2double(get(handles.reject_level, 'string'));
rejected = [];

for ImgNo = 1:size(cellFilter,1)
    if double(cellFilter{ImgNo,5}(1,1)*100) < rejectLevel %UnclassifiedEvents Reject
        UnclassifiedEvents(end+1,:) = cellFilter(ImgNo,:);
        rejected = [rejected; ImgNo]; %Save Index to delete later
    end
end
%Delete Events in cellFilter and sort into Feeding Events
cellFilter(rejected,:) = [];
msg = [num2str(size(UnclassifiedEvents,1)) ' visit(s) have been rejected (No-Feeding probability > ' num2str(rejectLevel) ' %).'];
logDisplay(msg, handles)

set(handles.txtPotFeedingAmount,'String',num2str(size(cellFilter,1)));
assignin('base', 'cellFilter', cellFilter);
assignin('base', 'UnclassifiedEvents', FeedingEvents);
assignin('base', 'UnclassifiedEvents', UnclassifiedEvents);

% --- accept events below precision threshold.
function Accept_Events(handles)
global cellFilter
global FeedingEvents
global UnclassifiedEvents

acceptLevel = str2double(get(handles.accept_level, 'string'));
accepted = [];

for ImgNo = 1:size(cellFilter,1)
    if double(cellFilter{ImgNo,5}(1,1)*100) >= acceptLevel %UnclassifiedEvents Reject
        FeedingEvents(end+1,:) = cellFilter(ImgNo,:);
        accepted = [accepted; ImgNo]; %Save Index to delete later
    end
end
%Delete Events in cellFilter and sort into Feeding Events
cellFilter(accepted,:) = [];

msg = [num2str(size(FeedingEvents,1)) ' visit(s) have been accepted (feeding probability > ' num2str(acceptLevel) ' %).'];
logDisplay(msg, handles)

set(handles.txtPotFeedingAmount,'String',num2str(size(cellFilter,1)));
assignin('base', 'cellFilter', cellFilter);
assignin('base', 'FeedingEvents', FeedingEvents);
assignin('base', 'UnclassifiedEvents', UnclassifiedEvents);

% --- display events that need manual classification.
function Display_Unsure_EventAmount(handles)
global cellFilter
if size(cellFilter,1) < 1
    msg = 'No visits need classification.';
elseif size(cellFilter,1) > 1
    msg = [num2str(size(cellFilter,1)) ' visits need classification.'];
else
    msg = [num2str(size(cellFilter,1)) ' visit needs classification.'];
end
logDisplay(msg, handles)

% --- sort the events into lists corresponding to behaviour.
function SortClassifiedEvents(handles)
global cellFilter
global FeedingEvents
global UnclassifiedEvents
global HeatingEvents
global BuildingEvents
while ~isempty(cellFilter)
    highestPrediction = max(cellFilter{1,5});
    PredictionIndex = find(cellFilter{1,5} == highestPrediction);
    switch PredictionIndex
        case 1 % FeedingEvent
            FeedingEvents(end+1,:) = cellFilter(1,:);
        case 2 % UnclassifiedEvent
            UnclassifiedEvents(end+1,:) = cellFilter(1,:);
        case 3 % HeatingEvent
            HeatingEvents(end+1,:) = cellFilter(1,:);
        case 4 % BuildingEvent
            BuildingEvents(end+1,:) = cellFilter(1,:);
    end
    cellFilter(1,:) = [];
end
ColorizeBwImage(handles)
assignin('base', 'cellFilter', cellFilter);
assignin('base', 'FeedingEvents', FeedingEvents);
assignin('base', 'UnclassifiedEvents', UnclassifiedEvents);
assignin('base', 'HeatingEvents', HeatingEvents);
assignin('base', 'BuildingEvents', BuildingEvents);

% --- visualize classification on STI after auto classification.
function ColorizeBwImage(handles)
global FeedingEvents
global UnclassifiedEvents
global HeatingEvents
global BuildingEvents
global InspectionEvents
global ColorImage
global BwImage

ColorImage = cat(3, BwImage, BwImage, BwImage);

if ~isempty(HeatingEvents)
    ColorImage = ApplyColor(HeatingEvents, ColorImage, 1);
end
if ~isempty(FeedingEvents)
    ColorImage = ApplyColor(FeedingEvents, ColorImage, 2);
end
if ~isempty(BuildingEvents)
    ColorImage = ApplyColor(BuildingEvents, ColorImage, 3);
end
if ~isempty(UnclassifiedEvents)
    ColorImage = ApplyColor(UnclassifiedEvents, ColorImage, [1 3]);
end
if ~isempty(InspectionEvents)
    ColorImage = ApplyColor(InspectionEvents, ColorImage, [2 3]);
end
DisplayDetectionImage(ColorImage, handles)

% --- visualize classification on STI after manual classification.
function ColorizeLastEvent(handles, eventType)
global FeedingEvents
global UnclassifiedEvents
global ColorImage
if eventType == 1
    startFrame = FeedingEvents{end,1}(1,2);
    endFrame = FeedingEvents{end,1}(1,3);
    ColorImage(:,startFrame:endFrame,2) = 255;
else
    startFrame = UnclassifiedEvents{end,1}(1,2);
    endFrame = UnclassifiedEvents{end,1}(1,3);
    ColorImage(:,startFrame:endFrame,[1 3]) = 255;
end
DisplayDetectionImage(handles)

% --- apply the respective color on event.
function ColorImage = ApplyColor(EventType, ColorImage, channel)
for EventNo = 1:size(EventType,1)
    startFrame = EventType{EventNo,1}(1,2);
    endFrame = EventType{EventNo,1}(1,3);
    ColorImage(:,startFrame:endFrame,channel) = 255;
end



% --- SAVE FUNCTIONS  ********************************************
%=====================================================================
% --- save data to temporary lists.
function save_data_to_temp(handles)
global FeedingEvents
global UnclassifiedEvents
global HeatingEvents
global BuildingEvents
global InspectionEvents
%SaveTempAmount = size(FeedingEvents,1);

%Feeding Temp
if ~size(FeedingEvents,1) == 0
    save_feedings_to_temp(handles)
end

%Other Temp
if ~size(UnclassifiedEvents,1) == 0
    save_unclassified_to_temp(handles)
end

%Heating Temp
if ~size(HeatingEvents,1) == 0
    save_heatings_to_temp(handles)
end

%Building Temp
if ~size(BuildingEvents,1) == 0
    save_buildings_to_temp(handles)
end

%Inspection Temp
if ~size(InspectionEvents,1) == 0
    save_inspections_to_temp(handles)
end

set(handles.save_data_to_temp_btn,'Enable','off');

% --- save classified feedings.
function save_feedings_to_temp(handles)
global FeedingEvents
global FeedingEventsSaveTemp
global basefilename

for EventNo = 1:size(FeedingEvents,1)
    FeedingEventsSaveTemp(end+1, :) = FeedingEvents(EventNo,:);
end
FeedingEventsSaveTemp = sortrows(FeedingEventsSaveTemp,4);
set(handles.txtFeedStoredInTemp, 'String', num2str(size(FeedingEventsSaveTemp,1)));

msg = [num2str(size(FeedingEvents,1)) ' "Feedings" of ' basefilename ' have been stored in Temp.'];
logDisplay(msg, handles)

assignin('base', 'FeedingEventsSaveTemp', FeedingEventsSaveTemp);

% --- save unclassified events.
function save_unclassified_to_temp(handles)
global UnclassifiedEvents
global UnclassifiedEventsSaveTemp
global basefilename

for EventNo = 1:size(UnclassifiedEvents,1)
    UnclassifiedEventsSaveTemp(end+1,:) = UnclassifiedEvents(EventNo,:);
end
UnclassifiedEventsSaveTemp = sortrows(UnclassifiedEventsSaveTemp,4);
set(handles.txtOtherStoredInTemp, 'String', num2str(size(UnclassifiedEventsSaveTemp,1)));

msg = [num2str(size(UnclassifiedEvents,1)) ' "Unclassified" of ' basefilename ' have been stored in Temp.'];
logDisplay(msg, handles)

assignin('base', 'UnclassifiedEventsSaveTemp', UnclassifiedEventsSaveTemp);

% --- save classified heatings.
function save_heatings_to_temp(handles)
global HeatingEvents
global HeatingEventsSaveTemp
global basefilename

for EventNo = 1:size(HeatingEvents,1)
    HeatingEventsSaveTemp(end+1,:) = HeatingEvents(EventNo,:);
end
HeatingEventsSaveTemp = sortrows(HeatingEventsSaveTemp,4);
set(handles.txtHeatStoredInTemp, 'String', num2str(size(HeatingEventsSaveTemp,1)));

msg = [num2str(size(HeatingEvents,1)) ' "Heatings" of ' basefilename ' have been stored in Temp.'];
logDisplay(msg, handles)

assignin('base', 'HeatingEventsSaveTemp', HeatingEventsSaveTemp);

% --- save classified buildings.
function save_buildings_to_temp(handles)
global BuildingEvents
global BuildingEventsSaveTemp
global basefilename

for EventNo = 1:size(BuildingEvents,1)
    BuildingEventsSaveTemp(end+1,:) = BuildingEvents(EventNo,:);
end
BuildingEventsSaveTemp = sortrows(BuildingEventsSaveTemp,4);
set(handles.txtBuildStoredInTemp, 'String', num2str(size(BuildingEventsSaveTemp,1)));

msg = [num2str(size(BuildingEvents,1)) ' "Building" of ' basefilename ' have been stored in Temp.'];
logDisplay(msg, handles)

assignin('base', 'BuildingEventsSaveTemp', BuildingEventsSaveTemp);

% --- save classified inspections.
function save_inspections_to_temp(handles)
global InspectionEvents
global InspectionEventsSaveTemp
global basefilename

for EventNo = 1:size(InspectionEvents,1)
    InspectionEventsSaveTemp(end+1,:) = InspectionEvents(EventNo,:);
end
InspectionEventsSaveTemp = sortrows(InspectionEventsSaveTemp,4);
set(handles.txtInspStoredInTemp, 'String', num2str(size(InspectionEventsSaveTemp,1)));

msg = [num2str(size(InspectionEvents,1)) ' "Inspections" of ' basefilename ' have been stored in Temp.'];
logDisplay(msg, handles)

assignin('base', 'InspectionEventsSaveTemp', InspectionEventsSaveTemp);



% --- TEMPDATA FUNCTIONS  *****************************************
%=====================================================================
% --- export the temporary lists.
function ExportTempdata(hObject, handles)
global FeedingEventsSaveTemp
global UnclassifiedEventsSaveTemp
global HeatingEventsSaveTemp
global BuildingEventsSaveTemp
global InspectionEventsSaveTemp
global basefilename
base = basefilename(1:end-7);
global Projektname

d = {'Visit Length (f)', 'Start Frame', 'End Frame', 'Total Start Frame',...
    'Level 1 (f)', 'Level 2 (f)' , 'Level 3 (f)',...
    'Level 1 (%)', 'Level 2 (%)' , 'Level 3 (%)',...
    'Part', 'Bee Number', 'Time',...
    'Worker Threshold', 'Level 3 %', 'Minimum Visit Length', 'Maximum Visit Length',...
    'Larva Threshold', 'Bottom cut size (px)',...
    'Seconds from first Event',...
    'Feeding Probability', 'Unclassified Probability',...
    'Heating Probability', 'Building Probability',...
    'Corrected Feeding Duration',... 
    'Oviposition Frame', 'Larval Hatch Frame', 'Capping Frame', 'Pepupa Frame'};
warning('off','MATLAB:xlswrite:AddSheet')

ExcelPfad = [handles.SaveFolder '\04_Exceldaten\' Projektname '\'];
if(exist(ExcelPfad, 'dir')==0)
    mkdir(ExcelPfad)
end
Excel = actxserver ('Excel.Application');
File = [ExcelPfad base '.xls'];
if ~exist(File,'file')
    ExcelWorkbook = Excel.workbooks.Add;
    ExcelWorkbook.SaveAs(File,1);
    ExcelWorkbook.Close(false);
end
invoke(Excel.Workbooks,'Open',File);
        
if ~size(FeedingEventsSaveTemp,1) == 0
    if ~isempty(FeedingEventsSaveTemp{1,1})
        ExportTable = export_feeding_temp(d);
        ExportTable = AddOntogenesisTimestamps(handles, ExportTable);
        xlswrite1([ExcelPfad base '.xls'],ExportTable, 1, 'A1');
        Excel.Worksheets.Item(1).Name = 'Feedings';
    end
end

if ~size(UnclassifiedEventsSaveTemp,1) == 0
    if ~isempty(UnclassifiedEventsSaveTemp{1,1})
        ExportTable = export_unclassified_temp(d);
        ExportTable = AddOntogenesisTimestamps(handles, ExportTable);
        xlswrite1([ExcelPfad base '.xls'],ExportTable, 2, 'A1');
        Excel.Worksheets.Item(1).Name = 'Feedings';
        Excel.Worksheets.Item(2).Name = 'Unclassified';
    end
end

if ~size(HeatingEventsSaveTemp,1) == 0
    if ~isempty(HeatingEventsSaveTemp{1,1})
        ExportTable = export_heating_temp(d);
        ExportTable = AddOntogenesisTimestamps(handles, ExportTable);
        xlswrite1([ExcelPfad base '.xls'],ExportTable, 3, 'A1');
        Excel.Worksheets.Item(1).Name = 'Feedings';
        Excel.Worksheets.Item(2).Name = 'Unclassified';
        Excel.Worksheets.Item(3).Name = 'Heating';
    end
end

if ~size(BuildingEventsSaveTemp,1) == 0
    if ~isempty(BuildingEventsSaveTemp{1,1})
        ExportTable = export_building_temp(d);
        ExportTable = AddOntogenesisTimestamps(handles, ExportTable);
        xlswrite1([ExcelPfad base '.xls'],ExportTable, 4, 'A1');
        Excel.Worksheets.Item(1).Name = 'Feedings';
        Excel.Worksheets.Item(2).Name = 'Unclassified';
        Excel.Worksheets.Item(3).Name = 'Heating';
        Excel.Worksheets.Item(4).Name = 'Building';
    end
end

if ~size(InspectionEventsSaveTemp,1) == 0
    if ~isempty(InspectionEventsSaveTemp{1,1})
        ExportTable = export_inspection_temp(d);
        ExportTable = AddOntogenesisTimestamps(handles, ExportTable);
        xlswrite1([ExcelPfad base '.xls'],ExportTable, 5, 'A1');
        Excel.Worksheets.Item(1).Name = 'Feedings';
        Excel.Worksheets.Item(2).Name = 'Unclassified';
        Excel.Worksheets.Item(3).Name = 'Heating';
        Excel.Worksheets.Item(4).Name = 'Building';
        Excel.Worksheets.Item(5).Name = 'Inspection';
    end
end

invoke(Excel.ActiveWorkbook,'Save');
Excel.Quit
Excel.delete
clear Excel
%
% Excel = actxserver('Excel.Application'); % # open Activex server
% ExcelWorkbook = Excel.Workbooks.Open(File); % # open file (enter full path!)
%  % # rename 1st sheet
% ExcelWorkbook.Worksheets.Item(1).Name = 'Unclassified'; % # rename 1st sheet
% ExcelWorkbook.Worksheets.Item(1).Name = 'Feedings'; % # rename 1st sheet
% ExcelWorkbook.Save % # save to the same file
% ExcelWorkbook.Close(false)
% Excel.Quit

msg = ['Export of ' base ' complete.'];
logDisplay(msg, handles)

ClearTempdata(hObject, handles)
SetPointerArrow()

% --- export the feeding list.
function ExportTable = export_feeding_temp(d)
global FeedingEventsSaveTemp

AnzahlEvents = size(FeedingEventsSaveTemp,1);
ExportTable = cell(AnzahlEvents+1,29);
ExportTable(1,:) = d;
ExportTable(2:AnzahlEvents+1,1:size(FeedingEventsSaveTemp{1,1},2)) = num2cell(cell2mat(FeedingEventsSaveTemp(:,1)));
ExportTable(2:AnzahlEvents+1,13) = FeedingEventsSaveTemp(:,2);
ExportTable(2:AnzahlEvents+1,14:19) = num2cell(cell2mat(FeedingEventsSaveTemp(:,3)));
for EventNo = 2:AnzahlEvents+1
    ExportTable(EventNo,20) = num2cell(cell2mat(ExportTable(EventNo,4)) - cell2mat(ExportTable(2,4)));
end
if size(FeedingEventsSaveTemp,2) == 4
    if ~isempty(cell2mat(FeedingEventsSaveTemp(:,4)))
        ExportTable(2:AnzahlEvents+1,25) = FeedingEventsSaveTemp(:,4);
    end
elseif size(FeedingEventsSaveTemp,2) == 5
    if size(FeedingEventsSaveTemp{1,5},2) == 4
        ExportTable(2:AnzahlEvents+1,21:24) = num2cell(cell2mat(FeedingEventsSaveTemp(:,5)));
    else
        ExportTable(2:AnzahlEvents+1,21:22) = num2cell(cell2mat(FeedingEventsSaveTemp(:,5)));
    end
end

% --- export the unclassfied list.
function ExportTable = export_unclassified_temp(d)
global UnclassifiedEventsSaveTemp

AnzahlEvents = size(UnclassifiedEventsSaveTemp,1);
ExportTable = cell(AnzahlEvents+1,29);
ExportTable(1,:) = d;
ExportTable(2:AnzahlEvents+1,1:size(UnclassifiedEventsSaveTemp{1,1},2)) = num2cell(cell2mat(UnclassifiedEventsSaveTemp(:,1)));
ExportTable(2:AnzahlEvents+1,13) = UnclassifiedEventsSaveTemp(:,2);
ExportTable(2:AnzahlEvents+1,14:19) = num2cell(cell2mat(UnclassifiedEventsSaveTemp(:,3)));
for EventNo = 2:AnzahlEvents+1
    ExportTable(EventNo,20) = num2cell(cell2mat(ExportTable(EventNo,4)) - cell2mat(ExportTable(2,4)));
end
if size(UnclassifiedEventsSaveTemp,2) == 4
    if ~isempty(cell2mat(UnclassifiedEventsSaveTemp(:,4)))
        ExportTable(2:AnzahlEvents+1,25) = UnclassifiedEventsSaveTemp(:,4);
    end
elseif size(UnclassifiedEventsSaveTemp,2) == 5
    if size(UnclassifiedEventsSaveTemp{1,5},2) == 4
        ExportTable(2:AnzahlEvents+1,21:24) = num2cell(cell2mat(UnclassifiedEventsSaveTemp(:,5)));
    else
        ExportTable(2:AnzahlEvents+1,21:22) = num2cell(cell2mat(UnclassifiedEventsSaveTemp(:,5)));
    end
end

% --- export the heating list.
function ExportTable = export_heating_temp(d)
global HeatingEventsSaveTemp

AnzahlEvents = size(HeatingEventsSaveTemp,1);
ExportTable = cell(AnzahlEvents+1,29);
ExportTable(1,:) = d;
ExportTable(2:AnzahlEvents+1,1:size(HeatingEventsSaveTemp{1,1},2)) = num2cell(cell2mat(HeatingEventsSaveTemp(:,1)));
ExportTable(2:AnzahlEvents+1,13) = HeatingEventsSaveTemp(:,2);
ExportTable(2:AnzahlEvents+1,14:19) = num2cell(cell2mat(HeatingEventsSaveTemp(:,3)));
for EventNo = 2:AnzahlEvents+1
    ExportTable(EventNo,20) = num2cell(cell2mat(ExportTable(EventNo,4)) - cell2mat(ExportTable(2,4)));
end
if size(HeatingEventsSaveTemp,2) == 4
    if ~isempty(cell2mat(HeatingEventsSaveTemp(:,4)))
        ExportTable(2:AnzahlEvents+1,25) = HeatingEventsSaveTemp(:,4);
    end
elseif size(HeatingEventsSaveTemp,2) == 5
    ExportTable(2:AnzahlEvents+1,21:24) = num2cell(cell2mat(HeatingEventsSaveTemp(:,5)));
end

% --- export the building list.
function ExportTable = export_building_temp(d)
global BuildingEventsSaveTemp

AnzahlEvents = size(BuildingEventsSaveTemp,1);
ExportTable = cell(AnzahlEvents+1,29);
ExportTable(1,:) = d;
ExportTable(2:AnzahlEvents+1,1:size(BuildingEventsSaveTemp{1,1},2)) = num2cell(cell2mat(BuildingEventsSaveTemp(:,1)));
ExportTable(2:AnzahlEvents+1,13) = BuildingEventsSaveTemp(:,2);
ExportTable(2:AnzahlEvents+1,14:19) = num2cell(cell2mat(BuildingEventsSaveTemp(:,3)));
for EventNo = 2:AnzahlEvents+1
    ExportTable(EventNo,20) = num2cell(cell2mat(ExportTable(EventNo,4)) - cell2mat(ExportTable(2,4)));
end
if size(BuildingEventsSaveTemp,2) == 4
    if ~isempty(cell2mat(BuildingEventsSaveTemp(:,4)))
        ExportTable(2:AnzahlEvents+1,25) = BuildingEventsSaveTemp(:,4);
    end
elseif size(BuildingEventsSaveTemp,2) == 5
    ExportTable(2:AnzahlEvents+1,21:24) = num2cell(cell2mat(BuildingEventsSaveTemp(:,5)));
end

% --- export the inspection list.
function ExportTable = export_inspection_temp(d)
global InspectionEventsSaveTemp

AnzahlEvents = size(InspectionEventsSaveTemp,1);
ExportTable = cell(AnzahlEvents+1,29);
ExportTable(1,:) = d;
ExportTable(2:AnzahlEvents+1,1:size(InspectionEventsSaveTemp{1,1},2)) = num2cell(cell2mat(InspectionEventsSaveTemp(:,1)));
ExportTable(2:AnzahlEvents+1,13) = InspectionEventsSaveTemp(:,2);
ExportTable(2:AnzahlEvents+1,14:19) = num2cell(cell2mat(InspectionEventsSaveTemp(:,3)));
for EventNo = 2:AnzahlEvents+1
    ExportTable(EventNo,20) = num2cell(cell2mat(ExportTable(EventNo,4)) - cell2mat(ExportTable(2,4)));
end
if size(InspectionEventsSaveTemp,2) == 4
    if ~isempty(cell2mat(InspectionEventsSaveTemp(:,4)))
        ExportTable(2:AnzahlEvents+1,25) = InspectionEventsSaveTemp(:,4);
    end
elseif size(InspectionEventsSaveTemp,2) == 5
    ExportTable(2:AnzahlEvents+1,21:24) = num2cell(cell2mat(InspectionEventsSaveTemp(:,5)));
end

% --- export the timestamps of ontogenesis.
function ExportTable = AddOntogenesisTimestamps(handles, ExportTable)
if ~isempty(handles.oviposition)
ExportTable(2:size(ExportTable,1),26) = {handles.oviposition};
end
if ~isempty(handles.larvalHatch)
ExportTable(2:size(ExportTable,1),27) = {handles.larvalHatch};
end
if ~isempty(handles.capping)
ExportTable(2:size(ExportTable,1),28) = {handles.capping};
end
if ~isempty(handles.prepupa)
ExportTable(2:size(ExportTable,1),29) = {handles.prepupa};
end
return

% --- clears data in temp (automatically done after export).
function ClearTempdata(hObject, handles)

global FeedingEventsSaveTemp
global AlreadySavedInTempFeedings

global UnclassifiedEventsSaveTemp
global AlreadySavedInTempUnclassified

global HeatingEventsSaveTemp
global AlreadySavedInTempHeatings

global BuildingEventsSaveTemp
global AlreadySavedInTempBuilding

global InspectionEventsSaveTemp
global AlreadySavedInTempInspection

FeedingEventsSaveTemp(:) = [];
UnclassifiedEventsSaveTemp(:) = [];
HeatingEventsSaveTemp(:) = [];
BuildingEventsSaveTemp(:) = [];
InspectionEventsSaveTemp(:) = [];
handles.oviposition = [];
handles.larvalHatch = [];
handles.capping = [];
handles.prepupa = [];
guidata(hObject, handles);

AlreadySavedInTempFeedings = size(FeedingEventsSaveTemp,1);
AlreadySavedInTempUnclassified = size(UnclassifiedEventsSaveTemp,1);
AlreadySavedInTempHeatings = size(HeatingEventsSaveTemp,1);
AlreadySavedInTempBuilding = size(BuildingEventsSaveTemp,1);
AlreadySavedInTempInspection = size(InspectionEventsSaveTemp,1);

set(handles.txtFeedStoredInTemp, 'String', num2str(AlreadySavedInTempFeedings));
set(handles.txtOtherStoredInTemp, 'String', num2str(AlreadySavedInTempUnclassified));
set(handles.txtHeatStoredInTemp, 'String', num2str(AlreadySavedInTempHeatings));
set(handles.txtBuildStoredInTemp, 'String', num2str(AlreadySavedInTempBuilding));
set(handles.txtInspStoredInTemp, 'String', num2str(AlreadySavedInTempInspection));

assignin('base', 'FeedingEventsSaveTemp', FeedingEventsSaveTemp);
assignin('base', 'UnclassifiedEventsSaveTemp', UnclassifiedEventsSaveTemp);
assignin('base', 'HeatingEventsSaveTemp', HeatingEventsSaveTemp);
assignin('base', 'BuildingEventsSaveTemp', BuildingEventsSaveTemp);
assignin('base', 'InspectionEventsSaveTemp', InspectionEventsSaveTemp);

%set(handles.txtInfo, 'String', 'Tempdata has been cleared.');
msg = 'Tempdata has been cleared.';
logDisplay(msg, handles)



% --- MANUAL CLASSIFICATION FUNCTIONS *********************************
%=====================================================================
% --- event classified as feeding.
function Feeding(handles)
global cellFilter
global FeedingEvents

potFeedingAmount = str2double(get(handles.txtPotFeedingAmount, 'String'));
potFeedingNo = str2double(get(handles.txtPotFeedingNumber, 'String'));
FeedingEvents(end+1,:) = cellFilter(potFeedingNo,:);
FeedingEvents{end,1}(1,12) = str2double(get(handles.BeeNumber_edit, 'String'));
set(handles.BeeNumber_edit, 'String', num2str(0));

if potFeedingNo < potFeedingAmount
    set(handles.txtPotFeedingNumber, 'String', num2str(potFeedingNo+1));
    DisplayEvent(handles)
    
elseif potFeedingNo == potFeedingAmount
    ClassificationButtonsEnabled(handles, 0)
    set(handles.save_data_to_temp_btn,'Enable','on');
    set(handles.play_button,'Value',0)
    ColorizeBwImage(handles)
    
end
%ColorizeLastEvent(handles, 1)
assignin('base', 'FeedingEvents', FeedingEvents);
assignin('base', 'cellFilter', cellFilter);

% --- event classified as other/no feeding.
function NoFeeding(handles)
global cellFilter
global UnclassifiedEvents

potFeedingAmount = str2double(get(handles.txtPotFeedingAmount, 'String'));
potFeedingNo = str2double(get(handles.txtPotFeedingNumber, 'String'));
UnclassifiedEvents(end+1,:) = cellFilter(potFeedingNo,:);
UnclassifiedEvents{end,1}(1,12) = str2double(get(handles.BeeNumber_edit, 'String'));
set(handles.BeeNumber_edit, 'String', num2str(0));

if potFeedingNo < potFeedingAmount
    set(handles.txtPotFeedingNumber, 'String', num2str(potFeedingNo+1));
    DisplayEvent(handles)
    
elseif  potFeedingNo == potFeedingAmount
    ClassificationButtonsEnabled(handles, 0)
    set(handles.save_data_to_temp_btn,'Enable','on');
    set(handles.play_button,'Value',0)
    ColorizeBwImage(handles)
    
end
%ColorizeLastEvent(handles, 0)
assignin('base', 'UnclassifiedEvents', UnclassifiedEvents);
assignin('base', 'cellFilter', cellFilter);

% --- event classified as inspection.
function Inspection(handles)
global cellFilter
global InspectionEvents

potFeedingAmount = str2double(get(handles.txtPotFeedingAmount, 'String'));
potFeedingNo = str2double(get(handles.txtPotFeedingNumber, 'String'));
InspectionEvents(end+1,:) = cellFilter(potFeedingNo,:);
InspectionEvents{end,1}(1,12) = str2double(get(handles.BeeNumber_edit, 'String'));
set(handles.BeeNumber_edit, 'String', num2str(0));

if potFeedingNo < potFeedingAmount
    set(handles.txtPotFeedingNumber, 'String', potFeedingNo+1);
    DisplayEvent(handles)
    
elseif potFeedingNo == potFeedingAmount
    ClassificationButtonsEnabled(handles, 0)
    set(handles.save_data_to_temp_btn,'Enable','on');
    set(handles.play_button,'Value',0)
    ColorizeBwImage(handles)
end
%ColorizeLastEvent(handles, 1)
assignin('base', 'InspectionEvents', InspectionEvents);
assignin('base', 'cellFilter', cellFilter);

% --- feeding event duration corrected from inspection duration.
function InspectionFeeding()
global FeedingEvents
potFeedingNo = str2double(get(handles.txtPotFeedingNumber, 'String'));
frameposition = str2double(get(handles.frameposition, 'String'));

if ~(frameposition >= FeedingEvents{potFeedingNo,1}(1,3)) && ~(frameposition <= FeedingEvents{potFeedingNo,1}(1,2))
    corredtedFeedingDuration = FeedingEvents{potFeedingNo,1}(1,1)-(frameposition-FeedingEvents{potFeedingNo,1}(1,2));
    FeedingEvents{potFeedingNo,4} = corredtedFeedingDuration;
    Feeding(handles)
else
    uicontrol(handles.btnBack);
    btnBack_Callback(handles.btnBack,[],handles);
end
assignin('base', 'FeedingEvents', FeedingEvents);



% --- DISPLAY FUNCTIONS  ********************************************
%=====================================================================
% --- load corresponding AVI or SEQ video data.
function LoadVideo(handles)
global basefilename
global v
global fid fidIdx
global zelllinie
global Projektname

LinienPfad = [handles.SaveFolder '\02_Linien\' Projektname '\'];
k = strfind(basefilename, 'Linie');
erste_nummer = basefilename(k+5);
zweite_nummer = basefilename(k+6);
linie = str2double([erste_nummer zweite_nummer]);
base = basefilename(1:end-15);
linienname = [base '_Linien.txt'];
FirstLine = strcat(LinienPfad, linienname);
fullVideoPath = [handles.VideoFile '\' base '.avi'];
fullSeqPath = [handles.VideoFile '\' base '.seq'];

try
    define_line_points = load(FirstLine);
    zelllinie = [define_line_points(linie,1),define_line_points(linie,2),define_line_points(linie,3),define_line_points(linie,4)];
catch ME
    msg = sprintf('Error reading Lines: \n%s', ME.message);
    logDisplay(msg, handles)
    %   WarnUser(errorMessage);
end

if exist(fullVideoPath,'file') == 2
    try
        v = VideoReader(fullVideoPath);
        if fid > 0, fclose(fid); end
    catch ME
        msg = sprintf('Error loading Video:\n%s\n%s', ME.message, fullVideoPath);
        logDisplay(msg, handles)
        %   WarnUser(errorMessage);
    end
elseif exist(fullSeqPath,'file') == 2
    try
        fid = fopen(fullSeqPath);
        fidIdx = fopen([fullSeqPath '.idx']);
    catch ME
        msg = sprintf('Error loading Seq:\n%s\n%s', ME.message, fullSeqPath);
        logDisplay(msg, handles)
        %   WarnUser(errorMessage);
    end
else
    msg = 'No available video or sequence found.';
    logDisplay(msg, handles)
end

% --- display corresponding AVI or SEQ video data.
function DisplayVideo(frame, handles)
global v
global zelllinie
global fid
y1 = zelllinie(2)+100;
y2 = zelllinie(4)-100;
if y2 <= 0
    y2 = -y2;
    y1 = y1 + y2 +1;
    y2 = 1;
end
% if y1 > size(v,1)
%     y1 = size(v,1);
% end

try
    %video = rgb2gray(read(v,frame));
    if fid > 0
        video = ReadSEQIdxFrame(frame);
    else
        video = rgb2gray(readindex(v,frame));
    end
    if size(video,3) == 3
        videobeschnitt = video(y2:y1,:,1);
    else
        videobeschnitt = video(y2:y1,:);
    end
    zeitanzeige = video(1:32,1:220);
    imshow(videobeschnitt, 'InitialMagnification', 'fit', 'Parent', handles.axes5);
    imshow(zeitanzeige, 'InitialMagnification', 'fit', 'Parent', handles.axes6);
catch
    set(handles.axes5,'Visible','off');
    set(handles.axes6,'Visible','off');
    %     errorMessage = sprintf('Error in function DisplayVideo.\nError Message:\n%s', ME.message);
    %     WarnUser(errorMessage);
end

% --- select image from listbox to display STI.
function LoadImage(handles)
clear global imgOriginal;
global imgOriginal
global baseImageFileName
global selectedListboxItem

if ~get(handles.interactive_noise_set,'Value')
    set(handles.cutImage,'String','0');
end

ListOfImageNames = get(handles.lstImageList, 'string');
baseImageFileName = strcat(cell2mat(ListOfImageNames(selectedListboxItem)));
fullImageFileName = [handles.ImageFolder '\' baseImageFileName];	% Prepend folder.

SetPointerWatch()

set(handles.axes1, 'visible', 'on','xtick',[],'ytick',[]);	% Hide plot of results since there are no results yet.
set(handles.axes2, 'visible', 'on','xtick',[],'ytick',[]);
set(handles.axes3, 'visible', 'on','xtick',[],'ytick',[]);
set(handles.axes5, 'visible', 'on','xtick',[],'ytick',[]);
set(handles.axes6, 'visible', 'on','xtick',[],'ytick',[]);
set(handles.slider1, 'visible', 'on')

imgOriginal = DisplayImage(handles, fullImageFileName);

% If imgOriginal is empty (couldn't be read), just exit.
if isempty(imgOriginal)
    return;
end
%setXlim(handles, str2double(get(handles.frameposition,'String')))
SetLarvalLevel(handles)
convertDone = 0;
if get(handles.interactive_noise_set,'Value')
    %cla(handles.axes2)
    imgOriginal_begin = imgOriginal(:,1:300);
    imgOriginal_end = imgOriginal(:,end-300:end);
    imgOriginal_begin_end = imfuse(imgOriginal_begin,imgOriginal_end,'method', 'montage');
    imshow(imgOriginal_begin_end,'Parent',handles.axes1,'InitialMagnification','fit');
    %setXlim(handles, 500)
    set(gcf,'CurrentAxes',handles.axes1)
    %set(gcf,'Pointer','bottom')
    [~,y] = ginput(1);
    y = (size(imgOriginal,1)-round(y,0))+5;
    set(handles.cutImage, 'String',num2str(y));
    imshow(imgOriginal,'Parent',handles.axes1,'InitialMagnification','fit');
    Convert(handles)
    convertDone = 1;
    setXlim(handles, 500)
end
if ~convertDone
    Convert(handles)
end
SetPointerArrow()

return % from lstImageList_Callback()

% --- displays images in main axes.
function imageArray = DisplayImage(handles, fullImageFileName)
% Read in image.
imageArray = []; % Initialize
global basefilename
global extension
global columns
global folder

[folder, basefilename, extension] = fileparts(fullImageFileName);
extension = lower(extension);


try
    if extension == '.png'
        [imageArray, ~] = imread(fullImageFileName);
    elseif extension == '.mat'
        load(fullImageFileName, 'stiSave')
        assignin('base','stiSave', stiSave)
%         if class(stiSave) == 'double'
            imageArray = uint8(stiSave);
%         else
%             imageArray = stiSave;
%         end
    end
    
catch ME
    % Will get here if imread() fails, like if the file is not an image file but a text file or Excel workbook or something.
    errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    WarnUser(errorMessage);
    return;	% Skip the rest of this function
end

% try
hold off;	% IMPORTANT NOTE: hold needs to be off in order for the "fit" feature to work correctly.

imshow(imageArray, 'InitialMagnification', 'fit', 'Parent', handles.axes1);
set(handles.axes1, 'xlim', [-500 500]);

[~, columns, ~] = size(imageArray);

set(handles.slider1, 'Min', 1);
set(handles.slider1, 'Max', columns-1000);
set(handles.slider1, 'Value', 1);
set(handles.slider1, 'SliderStep', [100/(columns-1000) , 1000/(columns-1000)]);
set(handles.frameposition, 'String', '500');

set(handles.sliderstep, 'String', num2str((100/columns)*columns));

part = str2double(basefilename(end-1:end))-1;
frame = part*65499+500;
set(handles.totalFrame, 'String', num2str(frame));

timeFrame = part*65499;
time_hrs = num2str(floor(timeFrame/3600));
time_min = num2str(floor(mod(timeFrame,3600)/60));
if(numel(time_min)==1)
    time_min = ['0' time_min];
end
time_sec = num2str(floor(mod(timeFrame,60)));
if(numel(time_sec)==1)
    time_sec = ['0' time_sec];
end
time = [time_hrs ':' time_min ':' time_sec];
set(handles.time_edit, 'String', time);

LoadVideo(handles)
DisplayVideo(frame, handles)

set(handles.btnBack,'Enable','off')
ClassificationButtonsEnabled(handles, 0)
set(handles.txtPotFeedingNumber,'String','0')
set(handles.txtPotFeedingAmount,'String','0')
% catch ME
%     errorMessage = sprintf('Error in function DisplayImage.\nError Message:\n%s', ME.message);
%     %errorMessage = sprintf(linienname);
%     WarnUser(errorMessage);
% end


return; % from DisplayImage

% --- converts to binary STI.
function Convert(handles)

global imgOriginal;
global basefilename
global BwImage

set(handles.btnFeeding,'BackgroundColor',[.94 .94 .94]);
set(handles.btnNoFeeding,'BackgroundColor',[.94 .94 .94]);
set(handles.feeding_probability, 'String', ' ');
set(handles.nofeeding_probability, 'String', ' ');

graustufe = str2double(get(handles.thrsh_worker, 'string'));
cutImageBy = str2double(get(handles.cutImage, 'string'));
I = imgOriginal;
if(3 == length(size(I)));  I=rgb2gray(I); end

if get(handles.adaptive_bw_checkbox,'Value')
    img = logical(imbinarize(I,'adaptive','ForegroundPolarity','dark','Sensitivity',graustufe));
else
    img = logical(imbinarize(I,graustufe));
end


dimension = size(img);
hoehe = dimension(1,1);
breite = dimension(1,2);


% Correct BW Image position after cut 
set(handles.axes2, 'Units', 'pixels');
height = cutImageBy * 1.375;
set(handles.axes2, 'Units', 'pixels', 'Position', [8 56+cutImageBy 1484 201-height]);


imgMod = zeros(hoehe, breite);

for i = 1:breite
    
    spalte = img(:,i);
    h = find(spalte == 0);
    if(h>0)
        beginn = h(1);
        
        ende = hoehe;
        
        for z = beginn:ende
            spalte(z,1) = 0;
        end
    end
    imgMod(:,i) = spalte;
    
end

if cutImageBy ~= 0
    imgMod = imgMod(1:end-cutImageBy,1:end);
end

if imgMod(end,1) == 0 && imgMod(end,2) == 1
    imgMod(:,1) = 1;
    msg = ['Please note: First Pixelline deleted in ' basefilename];
    logDisplay(msg, handles)
end

BwImage = imgMod;
DisplayDetectionImage(imgMod, handles)

% --- displays small STI above scrollbar for overview and navigation.
function DisplayDetectionImage(Image, handles)
global imgOriginal
position = str2double(get(handles.frameposition, 'String'));


imshow(Image, 'InitialMagnification', 'fit', 'Parent', handles.axes2);
setXlim(handles, position)
imshow(Image, 'Parent', handles.axes3)

axesHandlesToChildObjects = findobj(handles.axes1, 'Type', 'line');
if ~isempty(axesHandlesToChildObjects)
    delete(axesHandlesToChildObjects);
end

if size(imgOriginal,1) ~= size(Image,1)
    axes(handles.axes1);
    hold on;
    line([1,65499],[size(Image,1),size(Image,1)],'Color','blue','LineWidth',1);
    hold off;
end

% --- deletes all events after capping of cell has occured.
function SetCappingPoint(handles)
global BwImage
position = str2double(get(handles.frameposition, 'String'));
BwImage(:,position:end) = 1;
DisplayDetectionImage(BwImage, handles)

% --- jumps to selected event of list on STI.
function DisplayEvent(handles)
global cellFilter
global basefilename

set(handles.btnFeeding,'BackgroundColor',[.94 .94 .94]);
set(handles.btnNoFeeding,'BackgroundColor',[.94 .94 .94]);
set(handles.feeding_probability, 'String', ' ');
set(handles.nofeeding_probability, 'String', ' ');

potFeedingNo = str2double(get(handles.txtPotFeedingNumber, 'String'));

startframe = cellFilter{potFeedingNo,1}(1,2);

setXlim(handles, startframe)
set(handles.frameposition,'String', startframe);
set(handles.visit_length_txt, 'String', num2str(cellFilter{potFeedingNo,1}(1,1)));
set(handles.L3_length_txt, 'String', num2str(cellFilter{potFeedingNo,1}(1,10)));

part = str2double(basefilename(end-1:end))-1;
frame = part*65499+startframe;
set(handles.totalFrame, 'String', num2str(frame));
TimeConversion(handles)

if size(cellFilter,2) == 5
    FeedingProbability = cellFilter{potFeedingNo,5}(1,1);
    OtherProb = cellFilter{potFeedingNo,5}(1,2);
    FeedingProb = sprintf('%.2f',FeedingProbability * 100);
    NoFeedingProb = sprintf('%.2f',OtherProb*100);
    
    if FeedingProbability > 0.5
        set(handles.feeding_probability, 'String', [num2str(FeedingProb) '%']);
        set(handles.btnFeeding,'BackgroundColor','green');
    else
        set(handles.nofeeding_probability, 'String', [num2str(NoFeedingProb) '%']);
        set(handles.btnNoFeeding,'BackgroundColor','red');
    end
    % set(handles.togglebutton1,'string','ON','enable','on','BackgroundColor','green');
end

set(handles.btnBack,'Enable','on')
ClassificationButtonsEnabled(handles, 1)
SetPointerArrow()

% --- plays video and moves STI.
function abspielen(handles, play)
while play == 1
    if get(handles.play_button,'Value') == 0
        set(handles.play_button,'Value',0)
        break
    end
    
    sliderpos = get(handles.slider1,'Value');
    setSliderpos = sliderpos+1;
    
    
    posi = num2str(floor(setSliderpos));
    set(handles.frameposition, 'String', posi);
    
    timeFrame = str2double(get(handles.totalFrame,'String'));
    set(handles.totalFrame, 'String', num2str(timeFrame+1));
    
    %    if ~mod(timeFrame,30)
    %time2Frame = timeFrame/30;
    time2Frame = timeFrame;
    time_hrs = num2str(floor(time2Frame/3600));
    time_min = num2str(floor(mod(time2Frame,3600)/60));
    if(numel(time_min)==1)
        time_min = ['0' time_min];
    end
    time_sec = num2str(floor(mod(time2Frame,60)));
    if(numel(time_sec)==1)
        time_sec = ['0' time_sec];
    end
    time = [time_hrs ':' time_min ':' time_sec];
    set(handles.time_edit, 'String', time);
    %    end
    
    setXlim(handles, setSliderpos)
    DisplayVideo(timeFrame, handles)
    pause(0.05)
end

% --- converts total frame in time.
function TimeConversion(handles)
%timeFrame = timeFrame/30;
totalFrame = str2double(get(handles.totalFrame, 'String'));
time_hrs = num2str(floor(totalFrame/3600));
time_min = num2str(floor(mod(totalFrame,3600)/60));
if(numel(time_min)==1)
    time_min = ['0' time_min];
end
time_sec = num2str(floor(mod(totalFrame,60)));
if(numel(time_sec)==1)
    time_sec = ['0' time_sec];
end
time = [time_hrs ':' time_min ':' time_sec];
set(handles.time_edit, 'String', time);

% --- jump to entered position on STI.
function JumpToFrame(handles)
global basefilename

L = get(handles.slider1,{'min','max','value'});  % Get the slider's info.
E = str2double(get(handles.frameposition,'String'));  % Numerical edit string.
if E >= L{1} && E <= L{2}
    set(handles.slider1,'value',E)  % E falls within range of slider.
    
    min = E;
    max = E+1000;
    
    set(handles.axes1, 'xlim', [min max]);
    set(handles.axes2, 'xlim', [min max]);
    
    part = str2double(basefilename(end-1:end))-1;
    frame = part*65499+E;
    set(handles.totalFrame, 'String', num2str(frame));
    TimeConversion(handles)
    DisplayVideo(frame, handles)
else
    set(handles.frameposition,'string',L{3}) % User tried to set slider out of range.
end

% --- set axes to display STI at position.
function setXlim(handles, startframe)
set(handles.axes1, 'xlim', [startframe-500 startframe+500]);
set(handles.axes2, 'xlim', [startframe-500 startframe+500]);
set(handles.slider1,'Value', startframe);



% --- TOOL FUNCTIONS  ********************************************
%=====================================================================
% --- set mouse pointer to watch.
function SetPointerWatch()
set(gcf,'Pointer','watch');
drawnow;

% --- set mouse pointer to arrow.
function SetPointerArrow()
set(gcf,'Pointer','arrow');
drawnow;

% --- displays log message.
function logDisplay(msg, handles)
Log = get(handles.lstLog, 'String');
Log{end+1} = msg;
set(handles.lstLog, 'String', Log)
set(handles.lstLog, 'value', size(Log, 1));
logEntry(char(Log(end)), handles)

% --- creates Log entry.
function logEntry(msg, handles)

fid = fopen(fullfile(handles.SaveFolder, 'CeViS-Log.txt'), 'a');
if fid == -1
    error('Cannot open log file.');
end
fprintf(fid, '%s: %s\r\n', datestr(now, 0), msg);
fclose(fid);

% --- loads listbox with files in folder handles.handles.ImageFolder.
function handles = LoadImageList(handles)
ListOfImageNames = {};
folder = handles.ImageFolder;
if ~isempty(handles.ImageFolder)
    if exist(folder,'dir') == false
        warningMessage = sprintf('Note: the folder used when this program was last run:\n%s\ndoes not exist on this computer.\nPlease select an image folder.', handles.ImageFolder);
        msgboxw(warningMessage);
        return;
    end
else
    msgboxw('No folder specified as input for function LoadImageList.');
    return;
end
% If it gets to here, the folder is good.
ImageFiles = dir([handles.ImageFolder '/*.*']);
for Index = 1:length(ImageFiles)
    baseFileName = ImageFiles(Index).name;
    [folder, name, extension] = fileparts(baseFileName);
    extension = upper(extension);
    switch lower(extension)
        case {'.png', '.bmp', '.jpg', '.tif', '.avi', '.mat'}
            % Allow only PNG, TIF, JPG, or BMP images
            ListOfImageNames = [ListOfImageNames baseFileName];
        otherwise
    end
end
%set(handles.lstImageList,'Value',1);
set(handles.lstImageList,'string',ListOfImageNames);
return

% --- reads frame at constant frame rate.
function outputFrame = readindex(videoSource, frameNumber)
info = get(videoSource);
videoSource.CurrentTime = (frameNumber-1)/info.FrameRate;
outputFrame = readFrame(videoSource);

% --- reads frame of SEQ file.
function I = ReadSEQIdxFrame(frame)
global fid
endianType = 'ieee-le';
[readStart, imageBufferSize] = GetIdxFrameInfo(frame);
warning('off','MATLAB:imagesci:jpg:libraryMessage')
fseek(fid,readStart,'bof');
JpegSEQ = fread(fid,imageBufferSize,'uint8',endianType);

% Use two temp files to prevent fopen errors
if mod(frame,2)
    tempName = 'Temp\_tmp1.jpg';
else
    tempName = 'Temp\_tmp2.jpg';
end
tempFile = fopen(tempName,'w');
if tempFile < 0
    tempName = 'Temp\worker_tmp3.jpg';
    tempFile = fopen(tempName,'w');
end
fwrite(tempFile,JpegSEQ);
fclose(tempFile);
I = imread(tempName);
return

% --- reads frame metadata to precess compressed SEQ file.
function [readStart, imageBufferSize] = GetIdxFrameInfo(frame)
global fidIdx
endianType = 'ieee-le';
if frame == 1
    readStart = 1028;
    fseek(fidIdx,8,'bof');
    imageBufferSize = fread(fidIdx,1,'ulong',endianType);
else
    readStartIdx = frame*24;
    fseek(fidIdx,readStartIdx,'bof');
    readStart = fread(fidIdx,1,'uint64',endianType)+4;
    %fseek(fidIdx,4,'cof');
    imageBufferSize = fread(fidIdx,1,'ulong',endianType);
end
return

% --- enables classification buttons.
function ClassificationButtonsEnabled(handles, status)
if status == 0
    set(handles.btnFeeding, 'Enable', 'off');
    set(handles.btnNoFeeding, 'Enable', 'off');
    set(handles.btn_insp_feeding, 'Enable', 'off');
    set(handles.btn_inspection, 'Enable', 'off');
else
    set(handles.btnFeeding, 'Enable', 'on');
    set(handles.btnNoFeeding, 'Enable', 'on');
    set(handles.btn_insp_feeding, 'Enable', 'on');
    set(handles.btn_inspection, 'Enable', 'on');
end

% *** SLIDER
%=====================================================================
% --- slider function for navigation through STI.
function slider1_Callback(hObject, eventdata, handles)
global basefilename
r = groot;
fig = r.Children;
set(fig,'Units','pixels')
sliderpos = get(fig,'CurrentPoint');

% set(handles.slider1,'Units','pixels')
% g = get(handles.slider1,'Position')
if sliderpos(1) > 1485-15
    sliderpos(1) = 1485-15;
elseif sliderpos(1) < 45
    sliderpos(1) = 40.0221835447869433;
end

sliderpos = round((sliderpos(1)-40)*45.07845836200964,0);
set(hObject,'Value',sliderpos);

%sliderpos = get(hObject,'Value');
% min = sliderpos-500;
% max = sliderpos+500;
posi = num2str(floor(sliderpos));
set(handles.frameposition, 'String', posi);

posinum = str2double(posi);
part = str2double(basefilename(end-1:end))-1;
timeFrame = part*65499+posinum;
frame = timeFrame+1;
totalFrame = num2str(timeFrame);
set(handles.totalFrame, 'String', totalFrame);
TimeConversion(handles)

% set(handles.axes1, 'xlim', [min max]);
% set(handles.axes2, 'xlim', [min max]);
setXlim(handles, sliderpos)
DisplayVideo(frame, handles)



















% --- Folders panel
%=====================================================================
% --- executes at click on image list.
function lstImageList_Callback(hObject, eventdata, handles)
global baseImageFileName
global selectedListboxItem


% Get image name
selectedListboxItem = get(handles.lstImageList, 'value');
if isempty(selectedListboxItem)
    % Bail out if nothing was selected.
    return;
elseif length(selectedListboxItem) > 1
    baseImageFileName = '';
    return;
else
    LoadImage(handles)
end

% --- sets repetition number to use correct folders.
function bob_number_Callback(hObject, eventdata, handles)
% hObject    handle to bob_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bob_number as text
%        str2double(get(hObject,'String')) returns contents of bob_number as a double
global Projektname
Projektname = get(hObject,'String');
handles.RepetitionString = Projektname;
SaveUserSettings(handles);

% --- select the root directory of CeViS for correct subfolders.
function select_save_folder_Callback(hObject, eventdata, handles)
% hObject    handle to select_save_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
returnValue = uigetdir(handles.SaveFolder,'Select folder for saving');
% returnValue will be 0 (a double) if they click cancel.
% returnValue will be the path (a string) if they clicked OK.
if returnValue ~= 0
    % Assign the value if they didn't click cancel.
    handles.SaveFolder = returnValue;
    set(handles.txtSave, 'string' ,handles.SaveFolder);
    guidata(hObject, handles);
    % Save the image folder in our ini file.
    SaveUserSettings(handles);
end
return

% --- select a directory of the videos.
function selectvideo_pushbutton_Callback(hObject, eventdata, handles)
% Asks user to select a directory of the videos

% hObject    handle to selectvideo_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
returnValue = uigetdir(handles.VideoFile,'Select Video Folder');
% returnValue will be 0 (a double) if they click cancel.
% returnValue will be the path (a string) if they clicked OK.

if returnValue ~= 0
    % Assign the value if they didn't click cancel.
    handles.VideoFile = returnValue;
    set(handles.selectvideo_text, 'string' ,handles.VideoFile);
    guidata(hObject, handles);
    % Save the image folder in our ini file.
    SaveUserSettings(handles);
end
return

% --- select a directory and then loads up the listbox.
function btnSelectFolder_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%msgbox(handles.ImageFolder);
returnValue = uigetdir(handles.ImageFolder,'Select Image Folder');
% returnValue will be 0 (a double) if they click cancel.
% returnValue will be the path (a string) if they clicked OK.
if returnValue ~= 0
    % Assign the value if they didn't click cancel.
    handles.ImageFolder = returnValue;
    handles = LoadImageList(handles);
    set(handles.txtFolder, 'string' ,handles.ImageFolder);
    guidata(hObject, handles);
    % Save the image folder in our ini file.
    SaveUserSettings(handles);
end
return



% --- Information panel
%=====================================================================
% --- shows position in Image; Set value to jump to position.
function frameposition_Callback(hObject, eventdata, handles)
JumpToFrame(handles)

% --- shows video frame.
function totalFrame_Callback(hObject, eventdata, handles) %#ok<*INUSD>

% --- shows total frame number as passed time.
function time_edit_Callback(hObject, eventdata, handles)



% --- Event Detection panel
%=====================================================================
% --- use adaptive binarization.
function adaptive_bw_checkbox_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    set(handles.thrsh_worker,'String','0.1');
    SetPointerWatch()
    Convert(handles)
    SetPointerArrow()
else
    set(handles.thrsh_worker,'String','0.25');
    SetPointerWatch()
    Convert(handles)
    SetPointerArrow()
end

% --- set gray threshold for binarization.
function thrsh_worker_Callback(hObject, eventdata, handles)
% hObject    handle to thrsh_worker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thrsh_worker as text
%        str2double(get(hObject,'String')) returns contents of thrsh_worker as a double

Convert(handles)

% --- set pixel to cut lower area of BW image prior to analysis.
function cutImage_Callback(hObject, eventdata, handles)
% str2double(get(hObject,'String')) returns contents of cutImage as a double
SetPointerWatch()
Convert(handles)
SetPointerArrow()

% --- set threshold to determine larva on STI.
function thrshLarva_Callback(hObject, eventdata, handles)
SetLarvalLevel(handles)



% --- Neural Network panel
%=====================================================================
% --- when 2 calsses checkbox is checked.
function use_2C_classifier_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to use_2C_classifier_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_2C_classifier_checkbox
global Classifier2Checked
global Classifier4Checked
global BeeNetClassifier
global BeeNetClassifierType
Classifier2Checked = get(hObject,'Value');
Classifier4Checked = get(handles.use_4C_classifier_checkbox, 'Value');
if Classifier2Checked
    set(handles.reject_events_checkbox,'enable','on')
    set(handles.accept_events_checkbox,'enable','on')
    set(handles.use_4C_classifier_checkbox, 'Value', 0, 'enable','off');
    if BeeNetClassifierType ~= 2
        SetPointerWatch()
        BeeNetClassifier = load ('LW_TrainVgg16Classify_20180625', 'beeNet_20180625');
        BeeNetClassifier = BeeNetClassifier.beeNet_20180625;
        BeeNetClassifierType = 2;
        SetPointerArrow()
    end
else
    set(handles.reject_events_checkbox,'Value',0,'enable','off')
    set(handles.quick_analysis_checkbox,'Value',0,'enable','off')
    set(handles.text35,'Visible','off')
    set(handles.reject_level,'Visible','off')
    set(handles.use_4C_classifier_checkbox, 'Value', 0, 'enable','on');
end

% --- when 4 calsses checkbox is checked.
function use_4C_classifier_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to use_4C_classifier_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_4C_classifier_checkbox
global Classifier2Checked
global Classifier4Checked
global BeeNetClassifier
global BeeNetClassifierType
Classifier2Checked = get(handles.use_2C_classifier_checkbox, 'Value');
Classifier4Checked = get(hObject,'Value');
if Classifier4Checked
    %set(handles.level3percent, 'Value', 0, 'enable', 'off')
    set(handles.use_2C_classifier_checkbox, 'Value', 0,'enable','off')
    set(handles.reject_events_checkbox,'enable','on')
    set(handles.reject_events_checkbox,'Value',0,'enable','off')
    set(handles.accept_events_checkbox,'Value',0,'enable','off')
    set(handles.quick_analysis_checkbox,'Value',1,'enable','off')
    set(handles.text35,'Visible','off')
    set(handles.reject_level,'Visible','off')
    set(handles.level3percent,'String','0','enable','off');
    set(handles.minimum_visit_length,'String','10','enable','off');
    set(handles.maximum_visit_length,'String','10000','enable','off');
    set(handles.batch_processing_checkbox,'enable','on');
    if BeeNetClassifierType ~= 4
        SetPointerWatch()
        BeeNetClassifier = load ('LW_TrainVgg16_BeeNet4_201807', 'beeNet4_201807');
        BeeNetClassifier = BeeNetClassifier.beeNet4_201807;
        BeeNetClassifierType = 4;
        SetPointerArrow()
    end
else
    set(handles.use_2C_classifier_checkbox, 'Value', 0, 'enable','on')
    set(handles.quick_analysis_checkbox,'Value',0,'enable','off')
    set(handles.level3percent,'String','30','enable','on');
    set(handles.minimum_visit_length,'String','10','enable','on');
    set(handles.maximum_visit_length,'String','300','enable','on');
    set(handles.batch_processing_checkbox,'enable','off');
end

% --- when reject events checkbox is checked.
function reject_events_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to reject_events_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of reject_events_checkbox
active = get(hObject,'Value');
if active
    set(handles.text35,'Visible','on')
    set(handles.reject_level,'Visible','on')
    set(handles.text45,'Visible','on')
    set(handles.quick_analysis_checkbox,'enable','on')
else
    set(handles.text35,'Visible','off')
    set(handles.reject_level,'Visible','off')
    set(handles.text45,'Visible','off')
end
if ~active && get(handles.accept_events_checkbox,'Value') == 0
    set(handles.quick_analysis_checkbox,'Value',0,'enable','off')
end

% --- when accept events checkbox is checked.
function accept_events_checkbox_Callback(hObject, eventdata, handles)
active = get(hObject,'Value');
if active
    set(handles.text46,'Visible','on')
    set(handles.accept_level,'Visible','on')
    set(handles.text47,'Visible','on')
    set(handles.quick_analysis_checkbox,'enable','on')
else
    set(handles.text46,'Visible','off')
    set(handles.accept_level,'Visible','off')
    set(handles.text47,'Visible','off')
end
if ~active && get(handles.reject_events_checkbox,'Value') == 0
    set(handles.quick_analysis_checkbox,'Value',0,'enable','off')
end

% --- when batch processing checkbox is checked.
function batch_processing_checkbox_Callback(hObject, eventdata, handles)
BatchChecked = get(hObject,'Value');
if BatchChecked
    set(handles.batch_size,'Visible','on');
else
    set(handles.batch_size,'Visible','off');
end



% --- Analysis panel
%=====================================================================
% --- button to start analysis.
function Analysis_btn_Callback(hObject, eventdata, handles)
% hObject    handle to Analysis_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BatchDetection(handles)

% --- saves information in temporary variable.
function save_data_to_temp_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_data_to_temp_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_data_to_temp(handles)
set(handles.save_data_to_temp_btn,'Enable','off');

% --- export information in excel file.
function export_tempdata_btn_Callback(hObject, eventdata, handles)
ExportTempdata(hObject, handles)



% --- Manual Classification panel 
%=====================================================================
% --- event classified as feeding.
function btnFeeding_Callback(hObject, eventdata, handles)
Feeding(handles)

% --- event unclassified.
function btnNoFeeding_Callback(hObject, eventdata, handles)
NoFeeding(handles)

% --- set the position where feeding begins after inspection.
function btn_insp_feeding_Callback(hObject, eventdata, handles)
InspectionFeeding()

% --- event classified as inspection.
function btn_inspection_Callback(hObject, eventdata, handles)
Inspection(handles)


% --- Control panel
%=====================================================================
% --- jump back to beginning of event (<<).
function btnBack_Callback(hObject, eventdata, handles)
% hObject    handle to btnBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cellFilter
global basefilename

potFeedingNo = str2double(get(handles.txtPotFeedingNumber, 'String'));
startframe = cellFilter{potFeedingNo,1}(1,2);
part = str2double(basefilename(end-1:end))-1;
totalframe = part*65499+startframe;

set(handles.frameposition, 'String', num2str(startframe));
set(handles.totalFrame, 'String', num2str(totalframe));
TimeConversion(handles)
setXlim(handles, startframe)
DisplayVideo(totalframe, handles)

% --- play video (Play).
function play_button_Callback(hObject, eventdata, handles)
play = get(hObject,'Value');
abspielen(handles, play)

% --- jump back 10 frames (<< 10).
function jump_b_10_Callback(hObject, eventdata, handles)
jump(hObject, eventdata, handles, -10)

% --- jump forward 100 frames (100 >>).
function jump_f_100_Callback(hObject, eventdata, handles)
jump(hObject, eventdata, handles, +100)

% --- jump forward 10 frames (10 >>).
function jump_f_10_Callback(hObject, eventdata, handles)
jump(hObject, eventdata, handles, +10)

% --- jump forward 1 frame (1 >>).
function jump_f_1_Callback(hObject, eventdata, handles)
jump(hObject, eventdata, handles, +1)

% --- jump function.
function jump(hObject, eventdata, handles, amount)
startframe = str2double(get(handles.frameposition, 'String')) +amount;
totalframe = str2double(get(handles.totalFrame, 'String')) +amount;
set(handles.frameposition, 'String', num2str(startframe));
set(handles.totalFrame, 'String', num2str(totalframe));
TimeConversion(handles)
setXlim(handles, startframe)
DisplayVideo(totalframe, handles)

% --- corrects the starting frame of event.
function start_correction_Callback(hObject, eventdata, handles)
global cellFilter

VisitToCorrect = str2double(get(handles.txtPotFeedingNumber, 'String'));
FramesToCorrect = str2double(get(handles.totalFrame, 'String'));

OldLength = cellFilter{VisitToCorrect, 1}(1,1);
OldStart = cellFilter{VisitToCorrect, 1}(1,2);
OldStartTotal = cellFilter{VisitToCorrect, 1}(1,4);

DifferenceValue = FramesToCorrect - OldStartTotal;
NewLength = OldLength - DifferenceValue;
NewStart = OldStart + DifferenceValue;
NewStartTotal = OldStartTotal + DifferenceValue;

cellFilter{VisitToCorrect, 1}(1,1) = NewLength;
cellFilter{VisitToCorrect, 1}(1,2) = NewStart;
cellFilter{VisitToCorrect, 1}(1,4) = NewStartTotal;
cellFilter{VisitToCorrect, 1}(1,5:10) = 0;

set(handles.visit_length_txt, 'String', num2str(cellFilter{VisitToCorrect, 1}(1,1)));
startframe = NewStart;

set(handles.frameposition, 'String', num2str(startframe));
setXlim(handles, startframe)

msg = ['New start set from ' num2str(OldStartTotal) ' to ' num2str(NewStartTotal) '.'];
logDisplay(msg, handles)
 



% --- Ontogenesis panel
%=====================================================================
% --- set oviposition frame and calculate approximate larval hatch 
function oviposition_button_Callback(hObject, eventdata, handles)
handles.oviposition = str2double(get(handles.totalFrame,'String'));
msg = ['Oviposition at frame: ' num2str(handles.oviposition) ' saved in temp'];
logDisplay(msg, handles)
ApproxHatchtime = handles.oviposition + 259200;
msg = ['Approx. larval hatch: ' num2str(ApproxHatchtime) ' (3.95 Parts)'];
logDisplay(msg, handles)
guidata(hObject, handles);

% --- set larval hatch frame
function larval_hatch_button_Callback(hObject, eventdata, handles)
handles.larvalHatch = str2double(get(handles.totalFrame,'String'));
msg = ['Laval hatch at frame: ' num2str(handles.larvalHatch) ' saved in temp'];
logDisplay(msg, handles)
guidata(hObject, handles);

% --- set capping frame and calculate approximate oviposition & larval hatch 
function set_capping_point_button_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
handles.capping = str2double(get(handles.totalFrame,'String'));
msg = ['Capping at frame: ' num2str(handles.capping) ' saved in temp'];
logDisplay(msg, handles)
ApproxHatchtime = handles.capping - 475200;
ApproxOviposition = handles.capping - 734400;
msg = ['Approx. larval hatch: ' num2str(ApproxHatchtime) '(7.25 parts); Oviposition: ' num2str(ApproxOviposition) ' (11.2 parts)'];
logDisplay(msg, handles)
guidata(hObject, handles);
SetCappingPoint(handles)

% --- set frame after completion of metamorphosis 
function prepupa_button_Callback(hObject, eventdata, handles)
handles.prepupa = str2double(get(handles.totalFrame,'String'));
msg = ['Prepupa at frame: ' num2str(handles.prepupa) ' saved in temp'];
logDisplay(msg, handles)
guidata(hObject, handles);



% --- Other panel
%=====================================================================
% --- discontinued function to export analysis data of one STI part.
function btnExport_Callback(hObject, eventdata, handles)
% hObject    handle to btnExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BEARBEITEN%
global FeedingEvents
global basefilename
global Projektname
%base = basefilename(1:end-7);

% begin excel export

ExcelPfad = [handles.SaveFolder '\04_Exceldaten\' Projektname '\'];


if (isempty(FeedingEvents)==0)
    
    %d = {'Visit Length (f)', 'Start Frame', 'End Frame', 'Duration (s)', 'Level 1 (f)', 'Level 2 (f)' , 'Level 3 (f)', 'Level 1 (s)', 'Level 2 (s)' , 'Level 3 (s)', 'Level 1 (%)', 'Level 2 (%)' , 'Level 3 (%)' , 'Bee Number'};
    d = {'Visit Length (f)', 'Start Frame', 'End Frame', 'Total Start Frame', 'Level 1 (f)', 'Level 2 (f)' , 'Level 3 (f)', 'Level 1 (%)', 'Level 2 (%)' , 'Level 3 (%)' , 'Part', 'Bee Number', 'Time', 'Greythreshold', 'Level 3 %', 'Minimum Visit Length'};
    warning('off','MATLAB:xlswrite:AddSheet')
    
    if(exist(ExcelPfad, 'dir')==0)
        mkdir(ExcelPfad)
    end
    
    Excel = actxserver ('Excel.Application');
    File = [ExcelPfad basefilename '.xls'];
    if ~exist(File,'file')
        ExcelWorkbook = Excel.workbooks.Add;
        ExcelWorkbook.SaveAs(File,1);
        ExcelWorkbook.Close(false);
    end
    invoke(Excel.Workbooks,'Open',File);
    
    
    AnzahlFeeding = size(FeedingEvents, 1);
    xlswrite1([ExcelPfad basefilename '.xls'],d, 1, 'A1');
    for VisitCounter=1:AnzahlFeeding;
        xlswrite1([ExcelPfad basefilename '.xls'],FeedingEvents{VisitCounter,1}, 1, ['A' num2str(VisitCounter+1)]); % frameLength, startFrame, endFrame, TotalStartFrame, level1Length, level2Length, level3Length, level1Percent, level2Percent, level3Percent, PartIdx, BeeNumber
        xlswrite1([ExcelPfad basefilename '.xls'],FeedingEvents{VisitCounter,2}, 1, ['M' num2str(VisitCounter+1)]); % Time
        xlswrite1([ExcelPfad basefilename '.xls'],FeedingEvents{VisitCounter,3}, 1, ['N' num2str(VisitCounter+1)]); % graustufe prozent minimum_visit_length
        % xlswrite1([ExcelPfad basefilename '.xls'],cellVisits{2,PartIdx}{3,VisitCounter}, 1, ['B' num2str(Filterbesuch)]);
        % xlswrite1([ExcelPfad basefilename '.xls'],cellVisits{2,PartIdx}{1,VisitCounter} .', VisitCounter+1, 'A1');
        % FeedingEvents{Filterbesuch,1} = cellVisits{2,PartIdx}{3,VisitCounter};
        
    end
end


invoke(Excel.ActiveWorkbook,'Save');
Excel.Quit
Excel.delete
clear Excel
%end

SetPointerArrow()

% --- button to clear all temporary data.
function clear_Temp_Data_Callback(hObject, eventdata, handles)
% hObject    handle to clear_Temp_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ClearTempdata(hObject, handles)

% --- flip STI image vertically.
function flip_image_Callback(hObject, eventdata, handles)
global imgOriginal
global baseImageFileName

stiSave = flip(imgOriginal,1);
fullImageFileName = [handles.ImageFolder '\' baseImageFileName];
save(fullImageFileName,'stiSave');
imgOriginal = DisplayImage(handles, fullImageFileName);
Convert(handles)
msg = ['Image flipped: ' fullImageFileName];
logDisplay(msg, handles)

% --- set range to jump in STI when clicking on sloder arrows.
function sliderstep_Callback(hObject, eventdata, handles)
% hObject    handle to sliderstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sliderstep as text
%        str2double(get(hObject,'String')) returns contents of sliderstep as a double
global columns

minor = str2double(get(hObject,'String'));
minorstep = minor/(columns-1000);
majorstep = 1000/(columns-1000);

set(handles.slider1, 'SliderStep', [minorstep , majorstep]);



























% --- CREATE FUNCTIONS  **********************************************
%=====================================================================
% --- Executes during object creation, after setting all properties.
function lstImageList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstImageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function txtInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.

set(hObject, 'Min', 1);
set(hObject, 'Max', 1000);
set(hObject, 'Value', 1);


if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function frameposition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameposition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function thrsh_worker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thrsh_worker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function txtSave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function totalFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function time_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function sliderstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function cutImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function bob_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bob_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function level3percent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to level3percent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function BeeNumber_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BeeNumber_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function lstLog_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function minimum_visit_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minimum_visit_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function reject_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reject_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function thrshLarva_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thrshLarva (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Analysis_btn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Analysis_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function save_data_to_temp_btn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_data_to_temp_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function maximum_visit_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maximum_visit_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function accept_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to accept_events_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function batch_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to batch_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- EMPTY FUNCTIONS & CALLBACKS ************************************
%=====================================================================
% --- empty function or callback.
function level3percent_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function BeeNumber_edit_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function lstLog_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function figure1_KeyPressFcn(hObject, eventdata, handles)
%disp(eventdata.Key) % Let's display the key, for fun!
% switch eventdata.Key
%     case 'return'
%         if get(handles.play_button,'Value') == 0
%             set(handles.play_button,'Value',1)
%             abspielen(handles, 1)
%         else
%             set(handles.play_button,'Value',0)
%         end
%     case 'space'
%         Feeding(handles)
% end

% --- empty function or callback.
function minimum_visit_length_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function auto_detect_noise_level_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function txtInfo_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function reject_level_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function accept_level_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function quick_analysis_checkbox_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function maximum_visit_length_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function interactive_noise_set_Callback(hObject, eventdata, handles)

% --- empty function or callback.
function batch_size_Callback(hObject, eventdata, handles)



% --- OUTPUT & KEYPRESS FUNCTIONS  ***********************************
%=====================================================================
function varargout = CeViS_2_7_4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% --- Outputs from this function are returned to the command line.

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
global toggleShiftKeyPressed
% keyPressed = eventdata.Key;
%
%  if strcmpi(keyPressed,'control')
%      f = msgbox('Back');
%  elseif strcmpi(keyPressed,'space')
%      f = msgbox('Pause');
%
%      % set focus to the button
% %      uicontrol(handles.pushbutton1);
%      % call the callback
% %      pushbutton1_Callback(handles.pushbutton1,[],handles);
%  end

%eventdata % Let's see the KeyPress event data
%disp(eventdata.Key) % Let's display the key, for fun!
switch eventdata.Key
    case 's'
        playButtonPressed = get(handles.play_button,'Value');
        if playButtonPressed == 0
            set(handles.play_button,'Value',1)
        else
            set(handles.play_button,'Value',0)
        end
        uicontrol(handles.play_button);
        play_button_Callback(handles.play_button,[],handles);
        
    case 'y'
        %set focus to the button
        uicontrol(handles.jump_b_10);
        % call the callback
        jump_b_10_Callback(handles.jump_b_10,[],handles);
    case 'control'
            toggleShiftKeyPressed = 0;
    case 'shift'
            toggleShiftKeyPressed = 1;
end

% --- Executes on button press in continue_button.
function continue_button_Callback(hObject, eventdata, handles)
uiresume(gcbf)

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
global toggleShiftKeyPressed
global basefilename
part = str2double(basefilename(end-1:end))-1;
frameposition = str2double(get(handles.frameposition,'String'));
totalFrame = str2double(get(handles.totalFrame,'String'));
r = groot;
fig = r.Children;
set(fig,'Units','pixels')
sliderpos = get(fig,'CurrentPoint');
x = sliderpos(1);
y = sliderpos(2);
if x > 16 && x < 1515 && y > 146 && y < 618
    if eventdata.VerticalScrollCount < 1
        if toggleShiftKeyPressed
            newFrameposition = frameposition-50;
            newTotalFrame = totalFrame-50;
        else
            newFrameposition = frameposition-500;
            newTotalFrame = totalFrame-500;
        end
    else
        if toggleShiftKeyPressed
            newFrameposition = frameposition+50;
            newTotalFrame = totalFrame+50;
        else
            newFrameposition = frameposition+500;
            newTotalFrame = totalFrame+500;
        end
    end
    if newTotalFrame > part*65499+65499
        newTotalFrame = part*65499+65499;
    elseif newTotalFrame < part*65499+1
        newTotalFrame = part*65499+1;
    end    
    if newFrameposition > 65499
        newFrameposition = 65499;
    elseif newFrameposition < 1
        newFrameposition = 1;
    end
    set(handles.frameposition,'String',num2str(newFrameposition))
    set(handles.totalFrame,'String',num2str(newTotalFrame))
    setXlim(handles, newFrameposition)
    DisplayVideo(newTotalFrame, handles)
end
