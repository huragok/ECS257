function varargout = Localization(varargin)
% LOCALIZATION MATLAB code for Localization.fig
%      LOCALIZATION, by itself, creates a new LOCALIZATION or raises the existing
%      singleton*.
%
%      H = LOCALIZATION returns the handle to a new LOCALIZATION or the handle to
%      the existing singleton*.
%
%      LOCALIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOCALIZATION.M with the given input arguments.
%
%      LOCALIZATION('Property','Value',...) creates a new LOCALIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Localization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Localization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Localization

% Last Modified by GUIDE v2.5 20-Mar-2013 21:20:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Localization_OpeningFcn, ...
                   'gui_OutputFcn',  @Localization_OutputFcn, ...
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


% --- Executes just before Localization is made visible.
function Localization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Localization (see VARARGIN)

addpath('../Data','../Functions');
[FileName,PathName] = uigetfile('../Data/Data.mat','Select mat file');
load( fullfile(PathName,FileName) );   %# pass file path as string

% Initialization of other data member
data.route=[];
data.speedRange = [0,inf];
data.numSpeed = 1;
data.Ts = 2;
data.epsilon = 0.05;
data.p = 0;
data.k = 0;
data.NcutMax = 0.6;

data.speedProfile = zeros(0, 2);
data.numSample = 0;
data.xSample = zeros(0, 2);
data.rssiSample = zeros(0, 2);
data.speedSample = [];
data.tSample = [];

data.indexPosCurrent = [];
data.costViterbi = [];
data.routeViterbi = [];

data.count = 0; % Initialize the number of steps finished by Viterbi algorithm

PlotFloorPlan(data.wall, data.corner, data.x, 1);
setappdata(hObject,'mydata',data);

% Choose default command line output for Localization
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Localization wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Localization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
data = getappdata(handles.figure1,'mydata');
NcutMax = str2double(get(hObject,'string'));
if isnan(NcutMax )
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
 return
end
data.NcutMax  = NcutMax ;
setappdata(handles.figure1,'mydata',data);

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = getappdata(handles.figure1,'mydata');

button_state = get(hObject,'Value');
if button_state == get(hObject,'Max')
    set(hObject, 'String', 'On');
    
    posCluster = BiPartition(data.W, data.NcutMax);
    numCluster = size(posCluster, 1);
      
    cla; % clear axe
    PlotFloorPlan(data.wall, data.corner, data.x, 1); % replot the floor plan
    
    cmap=colormap(rand(numCluster,3)); % cover the measurement point with colored cross indicating clusters
    for indexCluster = 1:numCluster
        xTemp = data.x(posCluster{indexCluster},:);
        plot(75 - xTemp(:,2), xTemp(:,1), '+', 'Color',cmap(indexCluster,:), 'linewidth', 2), hold on;
    end
    
    % Replot the trajectory
    for indexSample = 1 : data.count - 1
        plot(75 - [data.xSample(indexSample, 2); data.xSample(indexSample + 1, 2)],...
             [data.xSample(indexSample, 1); data.xSample(indexSample+1, 1)], ...
             'bo--', 'linewidth', 2);
        
        plot(75 - [data.x(data.indexPosCurrent(indexSample), 2); data.x(data.indexPosCurrent(indexSample + 1), 2)],...
             [data.x(data.indexPosCurrent(indexSample), 1); data.x(data.indexPosCurrent(indexSample + 1), 1)],...
             'ro--', 'linewidth', 2); % Plot the estimated current posiition
    end
    
elseif button_state == get(hObject,'Min')
    set(hObject, 'String', 'Off');
    
    cla; % clear axe
    PlotFloorPlan(data.wall, data.corner, data.x, 1); % replot the floor plan
    
    % Replot the trajectory
    for indexSample = 1 : data.count - 1
        plot(75 - [data.xSample(indexSample, 2); data.xSample(indexSample + 1, 2)],...
             [data.xSample(indexSample, 1); data.xSample(indexSample+1, 1)], ...
             'bo--', 'linewidth', 2);
        
        plot(75 - [data.x(data.indexPosCurrent(indexSample), 2); data.x(data.indexPosCurrent(indexSample + 1), 2)],...
             [data.x(data.indexPosCurrent(indexSample), 1); data.x(data.indexPosCurrent(indexSample + 1), 1)],...
             'ro--', 'linewidth', 2); % Plot the estimated current posiition
    end
end
setappdata(handles.figure1,'mydata',data);
% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = getappdata(handles.figure1,'mydata');

cla;
PlotFloorPlan(data.wall, data.corner, data.x, 1);
data.count = 0;
set(handles.pushbutton5, 'String', 'Start');
set(handles.togglebutton1, 'String', 'Off');
set(handles.togglebutton1,'Value',0.0);

setappdata(handles.figure1,'mydata',data);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = getappdata(handles.figure1,'mydata');
if (data.count == 0) % The first step of the Viterbi-like algorithm, initialization
    
    data.numSample = size(data.rssiSample, 1); % number of samples
    data.indexPosCurrent = zeros(1, data.numSample); % best estimation of the current position at each sampling time

    data.costViterbi = zeros(data.k, 1); % The cost function of the route with least cost whose current position is the ith measurement position, i = 1, 2, ..., k 
    data.routeViterbi = zeros(data.k, 1); % The corresponding route up to current position i, i = 1, 2, ..., k

    % Initialization: in the first step the cost comes only from the
    % observation, assuming equally likely initial state
    indexPoskNear = GetkNear(data.rssiSample(1, :), data.meanRssi, data.k); % Coarsely find the k possible positions according to the first observation
    data.routeViterbi(:, 1) = indexPoskNear;
    for indexk = 1 : data.k
        data.costViterbi(indexk) = GetDeltaLLR(data.rssiSample(1, :), data.meanRssi(indexPoskNear(indexk), :), data.covRssi(:, :, indexPoskNear(indexk)));
    end
    
    [~, indexkCostMin] = min(data.costViterbi);
    data.indexPosCurrent(1) = data.routeViterbi(indexkCostMin, 1);

    data.count = 1;
    set(hObject, 'String', 'Go on');
    
elseif data.count < data.numSample
    plot(75 - [data.xSample(data.count, 2); data.xSample(data.count + 1, 2)],...
         [data.xSample(data.count, 1); data.xSample(data.count+1, 1)], ...
         'bo--', 'linewidth', 2);
    
    [data.indexPosCurrent(data.count+1), data.costViterbi, data.routeViterbi]...
  = GetPosCurrent(data.rssiSample(data.count+1, :), data.speedSample(data.count), data.meanRssi, data.covRssi, data.walkDistance, data.Ts, data.p, data.k, data.costViterbi, data.routeViterbi); % Updatee position estimation and Viterbi cost and routes
    
    plot(75 - [data.x(data.indexPosCurrent(data.count), 2); data.x(data.indexPosCurrent(data.count+1), 2)],...
         [data.x(data.indexPosCurrent(data.count), 1); data.x(data.indexPosCurrent(data.count+1), 1)],...
         'ro--', 'linewidth', 2); % Plot the estimated current posiition
     
    data.count = data.count + 1;
end
setappdata(handles.figure1,'mydata',data);
guidata(hObject,handles);


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
data = getappdata(handles.figure1,'mydata');
route = str2num(get(hObject,'string'));
if isempty(route)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
 return
end
data.route = ModifyRoute(route, data.next, data.walkDistance);
setappdata(handles.figure1,'mydata',data);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
data = getappdata(handles.figure1,'mydata');
k = str2double(get(hObject,'string'));
if isnan(k)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
 return
end
data.k = k;
setappdata(handles.figure1,'mydata',data);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
data = getappdata(handles.figure1,'mydata');
p = str2double(get(hObject,'string'));
if isnan(p)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
 return
end
data.p = p;
setappdata(handles.figure1,'mydata',data);

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = getappdata(handles.figure1,'mydata');
if data.count == 0
    data.speedProfile = GenSpeedProfile(data.route, data.speedRange, data.numSpeed, data.walkDistance);
    disp('Speed profile generated!');
end
setappdata(handles.figure1,'mydata',data);


function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
data = getappdata(handles.figure1,'mydata');
speedRange = str2num(get(hObject,'string'));
if isempty(speedRange)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
 return
end
data.speedRange = speedRange;
setappdata(handles.figure1,'mydata',data);

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
data = getappdata(handles.figure1,'mydata');
numSpeed = str2double(get(hObject,'string'));
if isnan(numSpeed)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
 return
end
data.numSpeed = numSpeed;
setappdata(handles.figure1,'mydata',data);

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
data = getappdata(handles.figure1,'mydata');
Ts = str2double(get(hObject,'string'));
if isnan(Ts)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
 return
end
data.Ts = Ts;
setappdata(handles.figure1,'mydata',data);

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
data = getappdata(handles.figure1,'mydata');
epsilon = str2double(get(hObject,'string'));
if isnan(epsilon)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
 return
end
data.epsilon = epsilon;
setappdata(handles.figure1,'mydata',data);

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = getappdata(handles.figure1,'mydata');
if data.count == 0
    [data.xSample, data.speedSample, data.tSample] = GenRouteSample(data.route, data.speedProfile, data.Ts, data.walkDistance, data.x);
    data.rssiSample = GenRssiSample(data.xSample, data.x, data.corner, data.wall, data.epsilon, data.rssiDatabase);
    disp('Samples generated!');
end
setappdata(handles.figure1,'mydata',data);

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
