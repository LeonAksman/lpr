function varargout = prt_ui_compute_weights(varargin)
% PRT_UI_COMPUTE_WEIGHTS M-file for prt_ui_compute_weights.fig
% 
% PRT_UI_COMPUTE_WEIGHTS, by itself, creates a new PRT_UI_COMPUTE_WEIGHTS 
% or raises the existing singleton*.
%
% H = PRT_UI_COMPUTE_WEIGHTS returns the handle to a new PRT_UI_COMPUTE_WEIGHTS
% or the handle to the existing singleton*.
%
% PRT_UI_COMPUTE_WEIGHTS('CALLBACK',hObject,eventData,handles,...) calls 
% the local function named CALLBACK in PRT_UI_COMPUTE_WEIGHTS.M with the 
% given input arguments.
%
% PRT_UI_COMPUTE_WEIGHTS('Property','Value',...) creates a new PRT_UI_COMPUTE_WEIGHTS
% or raises the existing singleton*.  Starting from the left, property 
% value pairs are applied to the GUI before prt_ui_compute_weights_OpeningFcn
% gets called.  An unrecognized property name or invalid value makes 
% property application stop.  All inputs are passed to prt_ui_compute_weights_OpeningFcn
% via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J.Schrouff
% $Id: prt_ui_compute_weights.m 741 2013-07-22 14:07:36Z mjrosa $

% Edit the above text to modify the response to help prt_ui_compute_weights

% Last Modified by GUIDE v2.5 13-Feb-2013 14:07:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @prt_ui_compute_weights_OpeningFcn, ...
    'gui_OutputFcn',  @prt_ui_compute_weights_OutputFcn, ...
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


% --- Executes just before prt_ui_compute_weights is made visible.
function prt_ui_compute_weights_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_compute_weights (see VARARGIN)

% Choose default command line output for prt_ui_compute_weights
handles.output = hObject;

%if window already exists, just put it as the current figure
Tag='weights';
F = findall(allchild(0),'Flat','Tag',Tag);
if length(F) > 1
    % Multiple Graphics windows - close all but most recent
    close(F(2:end))
    F = F(1);
    uistack(F,'top')
elseif length(F)==1
    uistack(F,'top')
else
    set(handles.figure1,'Tag',Tag)
    
    set(handles.figure1,'Name','PRoNTo :: Compute weights')
    %set size of the window, taking screen resolution and platform into account
    S0= spm('WinSize','0',1);   %-Screen size (of the current monitor)
    if ispc
        PF='MS Sans Serif';
    else
        PF= spm_platform('fonts');     %-Font names (for this platform)
        PF=PF.helvetica;
    end
    tmp  = [S0(3)/1280 (S0(4))/800];
    ratio=min(tmp)*[1 1 1 1];
    FS = 1 + 0.85*(min(ratio)-1);  %factor to scale the fonts
    x=get(handles.figure1,'Position');
    set(handles.figure1,'DefaultTextFontSize',FS*12,...
        'DefaultUicontrolFontSize',FS*12,...
        'DefaultTextFontName',PF,...
        'DefaultAxesFontName',PF,...
        'DefaultUicontrolFontName',PF)
    set(handles.figure1,'Position',ratio.*x)
    set(handles.figure1,'Resize','on')
    
    color=prt_get_defaults('color');
    set(handles.figure1,'Color',color.bg1)
    aa=get(handles.figure1,'children');
    for i=1:length(aa)
        if strcmpi(get(aa(i),'type'),'uipanel')
            set(aa(i),'BackgroundColor',color.bg2)
            bb=get(aa(i),'children');
            if ~isempty(bb)
                for j=1:length(bb)
                    if ~isempty(find(strcmpi(get(bb(j),'Style'),{'text',...
                            'radiobutton','checkbox'})))
                        set(bb(j),'BackgroundColor',color.bg2)
                    elseif ~isempty(find(strcmpi(get(bb(j),'Style'),'pushbutton')))
                        set(bb(j),'BackgroundColor',color.fr)
                    end
                    set(bb(j),'FontUnits','pixel')
                    xf=get(bb(j),'FontSize');
                    set(bb(j),'FontSize',ceil(FS*xf),'FontName',PF,...
                        'FontUnits','normalized','Units','normalized')
                end
            end
        elseif strcmpi(get(aa(i),'type'),'uicontrol')
            if ~isempty(find(strcmpi(get(aa(i),'Style'),{'text',...
                    'radiobutton','checkbox'})))
                set(aa(i),'BackgroundColor',color.bg1)
            elseif ~isempty(find(strcmpi(get(aa(i),'Style'),'pushbutton')))
                set(aa(i),'BackgroundColor',color.fr)
            end
        end
        set(aa(i),'FontUnits','pixel')
        xf=get(aa(i),'FontSize');
        set(aa(i),'FontSize',ceil(FS*xf),'FontName',PF,...
            'Units','normalized')
    end


set(handles.flag_cwi,'Value',0);
set(handles.flag_cwi,'Visible','off');
set(handles.flag_cwi,'Enable','off');
handles.flag = 0;
set(handles.compbutt,'Enable','off')
handles.img_name=[];
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_compute_weights wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_compute_weights_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_prt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_prt as text
%        str2double(get(hObject,'String')) returns contents of edit_prt as a double
handles.fname=get(handles.edit_prt,'String');
handles.prtdir=fileparts(handles.fname);
if exist('PRT','var')
    clear PRT
end
PRT=prt_load(handles.fname);
if ~isempty(PRT)
    handles.dat=PRT;
else
    beep
    disp('Could not load file')
    return
end
%fill the list of models
if ~isfield(handles.dat,'model')
    beep
    disp('No model found in this PRT')
    disp('Please specify model first')
    delete(handles.figure1)
end

handles.indm=[];
for m = 1:length(handles.dat.model)
    if isfield(handles.dat.model(m),'input') && ~isempty(handles.dat.model(m).input)
        if isfield(handles.dat.model(m),'output') && ~isempty(handles.dat.model(m).output)
            handles.indm=[handles.indm,m];
        end
    end
end

if isempty(handles.indm)
    beep
    disp('No model computed in this PRT')
    disp('Please specify AND run model before computing weights')
    return
end

list={handles.dat.model(:).model_name};
set(handles.pop_models,'String',list(handles.indm))
set(handles.pop_models,'Value',1)
handles.selmod=handles.indm(1);
set(handles.compbutt,'Enable','on')
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_prt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in br_prt.
function br_prt_Callback(hObject, eventdata, handles)
% hObject    handle to br_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.fname=spm_select(1,'.mat','Select PRT.mat',[],pwd,'PRT.mat');
set(handles.edit_prt,'String',handles.fname)
handles.prtdir=fileparts(handles.fname);
if exist('PRT','var')
    clear PRT
end
PRT=prt_load(handles.fname);
if ~isempty(PRT)
    handles.dat=PRT;
else
    beep
    disp('Could not load file')
    return
end
%fill the list of models
if ~isfield(handles.dat,'model')
    beep
    disp('No model found in this PRT')
    disp('Please specify model first')
    delete(handles.figure1)
end
handles.indm=[];
for i=1:length(handles.dat.model)
    if ~isempty(handles.dat.model(i).output)
        handles.indm=[handles.indm,i];
    end
end   
list={handles.dat.model(:).model_name};
set(handles.pop_models,'String',list(handles.indm))
set(handles.pop_models,'Value',1)
handles.selmod=handles.indm(1);
set(handles.compbutt,'Enable','on')
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in pop_models.
function pop_models_Callback(hObject, eventdata, handles)
% hObject    handle to pop_models (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_models contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_models
val=get(handles.pop_models,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_models,'Value',1)
    val=1;
end
handles.selmod=handles.indm(val);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_models_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_models (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_imgname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_imgname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_imgname as text
%        str2double(get(hObject,'String')) returns contents of edit_imgname as a double
handles.img_name=get(handles.edit_imgname,'String');
if ~prt_checkAlphaNumUnder(handles.img_name)
    beep
    disp('Name of the image should be in alphanumeric format (no extension)')
    disp('Please correct')
    return
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_imgname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_imgname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in flag_cwi, build the weight images for
% permutations flag
function flag_cwi_Callback(hObject, eventdata, handles)
% hObject    handle to flag_cwi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flag_cwi
flag=get(handles.flag_cwi,'Value');
if flag
    handles.flag=1;
else
    handles.flag=0;
end
guidata(hObject, handles);

% --- Executes on button press in compbutt.
function compbutt_Callback(hObject, eventdata, handles)
% hObject    handle to compbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list={handles.dat.model(:).model_name};
in.model_name=list{handles.selmod};
in.pathdir=handles.prtdir;
in.img_name=handles.img_name;  %for the moment, coming soon
prt_compute_weights(handles.dat,in,handles.flag);
delete(handles.figure1)
