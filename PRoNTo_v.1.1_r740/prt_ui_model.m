function varargout = prt_ui_model(varargin)
% PRT_UI_KERNEL_CONSTRUCTION M-file for prt_ui_kernel_construction.fig
%
% PRT_UI_KERNEL_CONSTRUCTION, by itself, creates a new 
% PRT_UI_KERNEL_CONSTRUCTION or raises the existing singleton*.
%
% H = PRT_UI_KERNEL_CONSTRUCTION returns the handle to a new 
% PRT_UI_KERNEL_CONSTRUCTION or the handle to the existing singleton*.
%
% PRT_UI_KERNEL_CONSTRUCTION('CALLBACK',hObject,eventData,handles,...)
% calls the local function named CALLBACK in PRT_UI_KERNEL_CONSTRUCTION.M 
% with the given input arguments.
%
% PRT_UI_KERNEL_CONSTRUCTION('Property','Value',...) creates a new 
% PRT_UI_KERNEL_CONSTRUCTION or raises the existing singleton*.  Starting 
% from the left, property value pairs are applied to the GUI before 
% prt_ui_kernel_construction_OpeningFcn gets called.  An unrecognized 
% property name or invalid value makes property application stop.  All 
% inputs are passed to prt_ui_kernel_construction_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
% instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id: prt_ui_model.m 741 2013-07-22 14:07:36Z mjrosa $

% Edit the above text to modify the response to help prt_ui_kernel_construction

% Last Modified by GUIDE v2.5 27-Mar-2013 13:22:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_model_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_model_OutputFcn, ...
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


% --- Executes just before prt_ui_kernel_construction is made visible.
function prt_ui_model_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_kernel_construction (see VARARGIN)

% Choose default command line output for prt_ui_kernel_construction
handles.output = hObject;

%if window already exists, just put it as the current figure
Tag='modelwin';
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
    
    %build figure when it doesn't exist
set(handles.figure1,'Name','PRoNTo :: Specify model')
% Choose the color of the different backgrounds and figure parameters
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
% set(handles.figure1,'Units','normalized')
set(handles.figure1,'Resize','on')

color=prt_get_defaults('color');
handles.color=color;
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

%Set defaults for some subfields and popup menus
handles.def=prt_get_defaults('model');
set(handles.kernel_methods,'Value',1)
set(handles.kernel_methods,'Enable','off')
handles.use_kernel=1;
set(handles.pop_cv,'String',{'Custom'})
set(handles.pop_cv,'Value',1)
handles.cv.type='custom';
handles.cv.mat_file=[];
set(handles.pop_reg,'String',{'Classification','Regression'})
set(handles.pop_reg,'Value',1)
handles.type='classification';
set(handles.butt_defclass,'ForegroundColor',handles.color.high)
set(handles.pop_machine,'String',{'Binary support vector machine',...
        'Binary Gaussian Process Classification',...
        'Multiclass GPC'})
set(handles.pop_machine,'Value',1)
handles.machine.function='prt_machine_svm_bin';
handles.machine.args=handles.def.svmargs;
% list={'Sample averaging (within block)',...
%     'Sample averaging (within subject/condition)',...
%     'Mean centre features using training data',...
%     'Divide data vectors by their norm',...
%     'Perform a GLM (fMRI only)'};  %GLM not shown since not implemented
%     yet
list={'Sample averaging (within block)',...
    'Sample averaging (within subject/condition)',...
    'Mean centre features using training data',...
    'Divide data vectors by their norm'};

handles.indop{1}=1:length(list);
handles.indop{2}=0;
set(handles.uns_list,'String',list)
set(handles.sel_list,'String',{''})
handles.operations = [];
handles.namop=list;
set(handles.uns_list,'Value',1)
set(handles.sel_list,'Value',1)
handles.flagguicv=0;
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_kernel_construction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_model_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isfield(handles,'output') && ~isempty(handles.output)
    varargout{1} = handles.output;
else
    varargout{1}=[];
end




% --- Executes on button press in br_prt.
function br_prt_Callback(hObject, eventdata, handles)
% hObject    handle to br_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname=spm_select(1,'.mat','Select PRT.mat',[],pwd,'PRT.mat');
if exist('PRT','var')
    clear PRT
end
PRT=prt_load(fname);
if ~isempty(PRT)
    handles.dat=PRT;
    set(handles.edit_prt,'String',fname);
else
    beep
    disp('Could not load file')
    return
end

if ~isfield(handles.dat,'fs')
    beep
    disp('No feature set found in the PRT.mat')
    disp('Please, prepare feature set before computing model')
    delete(handles.figure1)
    return
end
list={};
for i=1:length(PRT.fs)
    if ~isempty(PRT.fs(i).fs_name)
        list=[list; {PRT.fs(i).fs_name}];
    end
end
set(handles.pop_featset,'String',list)
set(handles.pop_featset,'Value',1)
if length(handles.dat.fs(1).modality)>1
    list=get(handles.pop_cv,'String');
    list=[list;{'Leave One Run/Session Out'}];
    set(handles.pop_cv,'String',list)
    set(handles.pop_cv,'Value',length(list))
    handles.cv.type = 'loro';
    handles.multimod = 1;
end
list=get(handles.pop_featset,'String');
handles.fs(1).fs_name=list{1};
handles.fs(1).indfs=1;

% Update handles structure
guidata(hObject, handles);



function edit_prt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_prt as text
%        str2double(get(hObject,'String')) returns contents of edit_prt as a double
fname=get(handles.edit_prt,'String');
if exist('PRT','var')
    clear PRT
end
PRT=prt_load(fname);
if ~isempty(PRT)
    handles.dat=PRT;
    set(handles.edit_prt,'String',fname);
else
    beep
    disp('Could not load file')
    return
end

if ~isfield(handles.dat,'fs')
    beep
    disp('No feature set found in the PRT.mat')
    disp('Please, prepare feature set before computing model')
    delete(handles.figure1)
    return
end
list={};
for i=1:length(PRT.fs)
    if ~isempty(PRT.fs(i).fs_name)
        list=[list; {PRT.fs(i).fs_name}];
    end
end
set(handles.pop_featset,'String',list)
set(handles.pop_featset,'Value',1)
if length(handles.dat.fs(1).modality)>1
    list=get(handles.pop_cv,'String');
    list=[list;{'Leave One Run/Session Out'}];
    set(handles.pop_cv,'String',list)
    set(handles.pop_cv,'Value',length(list))
    handles.cv.type = 'loro';
    handles.multimod = 1;
end
list=get(handles.pop_featset,'String');
handles.fs(1).fs_name=list{1};
handles.fs(1).indfs=1;

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

function edit_modelname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_modelname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_modelname as text
%        str2double(get(hObject,'String')) returns contents of edit_modelname as a double
handles.model_name=deblank(get(handles.edit_modelname,'String'));
if ~(prt_checkAlphaNumUnder(handles.model_name))
    beep
    disp('Model name should be entered in alphanumeric format only')
    disp('Please correct')
    set(handles.edit_modelname,'ForegroundColor',[1,0,0])
    return
else
    set(handles.edit_modelname,'ForegroundColor',[0,0,0])
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_modelname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_modelname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_featset.
function pop_featset_Callback(hObject, eventdata, handles)
% hObject    handle to pop_featset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_featset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_featset
val=get(handles.pop_featset,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_feaset,'Value',1)
    val=1;
end
list=get(handles.pop_featset,'String');
handles.fs(1).fs_name=list{val};
handles.fs(1).indfs=val;
if length(handles.dat.fs(val).modality)>1
    list=get(handles.pop_cv,'String');
    list=[list;{'Leave One Run/Session Out'}];
    set(handles.pop_cv,'String',list)
    set(handles.pop_cv,'Value',length(list))
    handles.cv.type = 'loro';
    handles.multimod = 1;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_featset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_featset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in kernel_methods.
function kernel_methods_Callback(hObject, eventdata, handles)
% hObject    handle to kernel_methods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of kernel_methods
handles.use_kernel=get(handles.kernel_methods,'Value');
if get(handles.pop_reg,'Value')==1 %for classification
    if ~handles.use_kernel
        set(handles.pop_machine,'String',{'Random Forest'})
        set(handles.pop_machine,'Value',1)
        handles.machine.function='prt_machine_RT_bin';
        handles.machine.args=handles.def.rtargs;
    else
        set(handles.pop_machine,'String',{'Binary support vector machine',...
            'Binary Gaussian Process Classification',...
            'Multiclass GPC'})
        set(handles.pop_machine,'Value',1)
        handles.machine.function='prt_machine_svm_bin';
        handles.machine.args=handles.def.svmargs;
    end
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in pop_reg.
function pop_reg_Callback(hObject, eventdata, handles)
% hObject    handle to pop_reg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_reg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_reg
val=get(handles.pop_reg,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_reg,'Value',1)
    val=1;
end
if val==1 %Classification
    handles.type='classification';
    nk=get(handles.kernel_methods,'Value');
    if nk==1
        %set the list of machines
        set(handles.pop_machine,'String',{'Binary support vector machine',...
            'Binary Gaussian Process Classification',...
            'Multiclass GPC'})
        set(handles.pop_machine,'Value',1)
        handles.machine.function='prt_machine_svm_bin';
        handles.machine.args=handles.def.svmargs;
    else
        %set the list of machines
        set(handles.pop_machine,'String',{'Random Forest'})
        set(handles.pop_machine,'Value',1)
        handles.machine.function='prt_machine_RT_bin';
        handles.machine.args=handles.def.rtargs;  
    end
    set(handles.butt_defclass,'String','Define classes')
elseif val==2
    handles.type='regression';
    set(handles.butt_defclass,'String','Select subjects/scans')
    %set the list of machines
    set(handles.pop_machine,'String',{'Kernel Ridge Regression',...
        'Relevance Vector Regression','Gaussian Process Regression'})
    set(handles.pop_machine,'Value',1)
    handles.machine.function='prt_machine_krr';
    handles.machine.args=handles.def.krrargs;
end
set(handles.butt_defclass,'ForegroundColor',handles.color.high)
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_reg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_reg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in but_defclass.
function butt_defclass_Callback(hObject, eventdata, handles)
% hObject    handle to butt_def_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(handles.type,'classification')
    speccl=prt_ui_select_class('UserData',{handles.dat,handles.fs(1).indfs});
    handles.design=speccl.design;
    handles.listnames=speccl.condm;
    handles.indclas=speccl.indclas;
    if isempty(speccl)
        beep
        disp('No class specified')
        return
    end
    handles.class=speccl.class;
    ns=zeros(length(speccl.class),1);
    ng1=1;
    ng2=1;
    for ii=1:length(speccl.class)
        for jj=1:length(speccl.class(ii).group)
            ns(ii)=ns(ii)+length(speccl.class(ii).group(jj).subj);
        end
        if jj==1
            if ii==1
                gname=speccl.class(ii).group(jj).gr_name;
            else
                if strcmpi(gname,speccl.class(ii).group(jj).gr_name)
                    ng2=ng2+1;
                end
            end
        else
            ng1=0;
        end
    end
    ng2=floor(ng2/length(speccl.class));
    if (speccl.design) && max(ns)==1
        list=get(handles.pop_cv,'String');
        list=[list;{'Leave One Block Out'};{'k-folds CV on Block'}];
        set(handles.pop_cv,'String',list)
        set(handles.pop_cv,'Value',length(list)-1)
        handles.cv.type     = 'lobo';
    end
    handles.loospg=speccl.loospg;
    if min(ns)>1
        list=get(handles.pop_cv,'String');
        list=[list;{'Leave One Subject Out'};{'k-folds CV on Subject Out'}];
        set(handles.pop_cv,'String',list)
        set(handles.pop_cv,'Value',length(list)-1)
        handles.cv.type     = 'loso';
        if ~ng1 || ~ng2
            list=get(handles.pop_cv,'String');
            list=[list;{'Leave One Subject per Group Out'};...
                {'k-folds CV on Subject per Group'}];
            set(handles.pop_cv,'String',list)
        end
    end
else
    sel=prt_ui_select_reg('UserData',{handles.dat,handles.fs(1).indfs});
    if isempty(sel)
        beep
        disp('No subject selected for regression')
        return
    end
    handles.group=sel;
    n=0;
    for i=1:length(sel)
        n=n+length(sel(i).subj);
    end
    if n>1
        list=get(handles.pop_cv,'String');
        list=[list;{'Leave One Subject Out'};{'k-folds CV on Subject Out'}];
        set(handles.pop_cv,'String',list)
        set(handles.pop_cv,'Value',length(list)-1)
        handles.cv.type     = 'loso';
    end
end
set(handles.butt_defclass,'ForegroundColor',[0 0 0])
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in pop_machine.
function pop_machine_Callback(hObject, eventdata, handles)
% hObject    handle to pop_machine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_machine contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_machine
mach=get(handles.pop_machine,'String');
val=get(handles.pop_machine,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_machine,'Value',1)
    val=1;
end
if any(strfind(mach{val},'support'))
    handles.machine.function='prt_machine_svm_bin';
    handles.machine.args=handles.def.svmargs;
elseif any(strfind(mach{val},'Binary Gaussian'))
    handles.machine.function='prt_machine_gpml';
    handles.machine.args=handles.def.gpcargs;
elseif any(strfind(mach{val},'Multiclass GPC'))
    handles.machine.function='prt_machine_gpclap';
    handles.machine.args=handles.def.gpclapargs;
elseif any(strfind(mach{val},'Ridge'))
    handles.machine.function='prt_machine_krr';
    handles.machine.args=handles.def.krrargs;
elseif any(strfind(mach{val},'Relevance'))
    handles.machine.function='prt_machine_rvr';
    handles.machine.args=[];
elseif any(strfind(mach{val},'Process Regression'))
    handles.machine.function='prt_machine_gpr';
    handles.machine.args=handles.def.gprargs;
elseif any(strfind(mach{val},'Random'))
    handles.machine.function='prt_machine_RT_bin';
    handles.machine.args=handles.def.rtargs;    
end
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_machine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_machine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_cv.
function pop_cv_Callback(hObject, eventdata, handles)
% hObject    handle to pop_cv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_cv contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_cv
% assemble structure for performing cross-validation
val=get(handles.pop_cv,'Value');
mach=get(handles.pop_cv,'String');
handles.cv.k=0; %by default, Leave-One-Out options
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_cv,'Value',1)
    val=1;
end
if any(strfind(mach{val},'Subject Out'))
    handles.cv.type = 'loso';
elseif any(strfind(mach{val},'Subject per Group'))
    if ~handles.loospg
        beep
        disp('Warning: Subjects are not balanced across classes!')
    end
    handles.cv.type = 'losgo';
elseif any(strfind(mach{val},'Block'))
    handles.cv.type = 'lobo';
elseif any(strfind(mach{val},'Run'))        %currently implemented for MCKR only
    handles.cv.type = 'loro';
else
    handles.cv.type     = 'custom';
    cvmatf=spm_select(1,'mat','Select .mat file corresponding to the custom cross-validation');
    handles.cv.mat_file = cvmatf;
    %fill the input of the 'prt_model' button
%     in.fname=get(handles.edit_prt,'String');
%     if ~isfield(handles,'model_name')
%         beep
%         disp('Please enter a valid model name')
%     end
%     in.model_name=handles.model_name;
%     in.type=handles.type;
%     in.machine=handles.machine;
%     in.use_kernel=handles.use_kernel;
%     in.operations=handles.operations;
%     in.fs(1).fs_name=handles.fs(1).fs_name;
%     in.cv=handles.cv;
%     %check that classes/subjects/scans were defined
%     if strcmpi(in.type,'classification')
%         if ~isfield(handles,'class')
%             beep
%             disp('No class selected for classification')
%             disp('Please, define classes')
%             return
%         else
%             for i=1:length(handles.class)
%                 ind=[];
%                 for g=1:length(handles.class(i).group)
%                     if ~isempty(handles.class(i).group(g).gr_name)
%                         ind=[ind,g];
%                     end
%                 end
%                 handles.class(i).group=handles.class(i).group(ind);
%             end
%             in.class=handles.class;
%         end
%     else
%         if ~isfield(handles,'group')
%             beep
%             disp('No subjects/scans selected for classification')
%             disp('Please, select subjects/scans')
%             return
%         else
%             ind=[];
%             for g=1:length(handles.group)
%                 if ~isempty(handles.group(g).gr_name)
%                     ind=[ind,g];
%                 end
%             end
%             handles.group=handles.group(ind);
%             in.group=handles.group;
%         end
%     end
%     handles.in=in;
%     prt_ui_specify_CV_basis(handles);
%     handles.flagguicv=1;
end
if any(strfind(mach{val},'k-fold'))
    kt=prt_text_input('Title','Specify k, the number of folds');
    handles.cv.k=str2num(kt);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_cv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_cv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in uns_list.
function uns_list_Callback(hObject, eventdata, handles)
% hObject    handle to uns_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns uns_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uns_list
val=get(handles.uns_list,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.uns_list,'Value',1)
    val=1;
end
% specify operations to apply to the data prior to prediction
ind=handles.indop{1}(val);
handles.operations=[handles.operations, ind];
handles.indop{1}=setdiff(handles.indop{1},ind);
if isempty(handles.indop{1})
    handles.indop{1}=0;
    set(handles.uns_list,'String',{''})
else
    set(handles.uns_list,'String',{handles.namop{handles.indop{1}}})    
end
set(handles.uns_list,'Value',1)
if handles.indop{2}==0
    handles.indop{2}=ind;
else
    handles.indop{2}=[handles.indop{2},ind];
end
set(handles.sel_list,'String',{handles.namop{handles.indop{2}}})
set(handles.sel_list,'Value',length(handles.indop{2}))
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function uns_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uns_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sel_list.
function sel_list_Callback(hObject, eventdata, handles)
% hObject    handle to sel_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sel_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sel_list
val=get(handles.sel_list,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.sel_list,'Value',1)
    val=1;
end
% specify operations to apply to the data prior to prediction
ind=handles.indop{2}(val);
handles.operations=setdiff(handles.operations, ind);
handles.indop{2}=setdiff(handles.indop{2},ind);
if isempty(handles.indop{2})
    handles.indop{2}=0;
    set(handles.sel_list,'String',{''})
else
    set(handles.sel_list,'String',{handles.namop{handles.indop{2}}})    
end
set(handles.sel_list,'Value',1)
if handles.indop{1}==0
    handles.indop{1}=ind;
else
    handles.indop{1}=[handles.indop{1},ind];
end
set(handles.uns_list,'String',{handles.namop{handles.indop{1}}})
set(handles.uns_list,'Value',length(handles.indop{1}))
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sel_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in buildbutt.
function buildbutt_Callback(hObject, eventdata, handles)
% hObject    handle to buildbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%fill the input of the 'prt_model' button
in.fname=get(handles.edit_prt,'String');
if ~isfield(handles,'model_name')
    beep
    disp('Please, provide a model name')
    return
end
if handles.flagguicv
    %reload prt since the new CV has been saved in it
    fname=get(handles.edit_prt,'String');
    load(fname) % no need for prt_load here
    handles.dat = PRT;   
end
in.model_name=handles.model_name;
in.type=handles.type;
in.machine=handles.machine;
in.use_kernel=handles.use_kernel;
in.operations=handles.operations;
in.fs(1).fs_name=handles.fs(1).fs_name;
in.cv=handles.cv;
%check that classes/subjects/scans were defined
if strcmpi(in.type,'classification')
    if ~isfield(handles,'class')
        beep
        disp('No class selected for classification')
        disp('Please, define classes')
        return
    else
        for i=1:length(handles.class)
            ind=[];
            for g=1:length(handles.class(i).group)
                if ~isempty(handles.class(i).group(g).gr_name)
                    ind=[ind,g];
                end
            end
            handles.class(i).group=handles.class(i).group(ind);
        end
        in.class=handles.class;
    end
else
    if ~isfield(handles,'group')
        beep
        disp('No subjects/scans selected for classification')
        disp('Please, select subjects/scans')
        return
    else
        ind=[];
        for g=1:length(handles.group)
            if ~isempty(handles.group(g).gr_name)
                ind=[ind,g];
            end
        end
        handles.group=handles.group(ind);
        in.group=handles.group;
    end
end

%checks on the CV framework compared to the model entered
if strcmpi(in.cv.type,'lobo')
    if ~isfield(in,'class')
        beep
        disp('Leave One Block Out cross-validation only allowed for classification')
        disp('Please correct')
        return
    else
        for c=1:length(in.class)
            for i=1:length(in.class(c).group)
                if length(in.class(c).group(i).subj)>1
                    beep
                    disp('Leave One Block Out cross-validation only allowed for within-subject classification')
                    disp('Please correct')
                    return
                end
            end
        end
    end
end
if ~isfield(in,'class')
    if ~strcmpi(in.cv.type,'loso')
        beep
        disp('Regression only allows a Leave (One) Subject Out cross-validation')
        disp('Please correct')
    end
end
PRT=prt_model(handles.dat,in);
clear in
in.fname      = get(handles.edit_prt,'String');
in.model_name = handles.model_name;
if exist('PRT','var')
    clear PRT
end
load(in.fname)
mid = prt_init_model(PRT, in);
% Special cross-validation for MCKR
if strcmpi(PRT.model(mid).input.machine.function,'prt_machine_mckr')
    prt_cv_mckr(PRT,in);
else
    prt_cv_model(PRT, in);
end
disp('Model specification and estimation complete.')
disp('Done...')
delete(handles.figure1)


% --- Executes on button press in buildbutt.
function specbutt_Callback(hObject, eventdata, handles)
% hObject    handle to buildbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%fill the input of the 'prt_model' button
in.fname=get(handles.edit_prt,'String');
if ~isfield(handles,'model_name')
    beep
    disp('Please enter a valid model name')
end
if handles.flagguicv
    %reload prt since the new CV has been saved in it
    fname=get(handles.edit_prt,'String');
    load(fname) % no need for prt_load here
    handles.dat = PRT;   
end
in.model_name=handles.model_name;
in.type=handles.type;
in.machine=handles.machine;
in.use_kernel=handles.use_kernel;
in.operations=handles.operations;
in.fs(1).fs_name=handles.fs(1).fs_name;
in.cv=handles.cv;
%check that classes/subjects/scans were defined
if strcmpi(in.type,'classification')
    if ~isfield(handles,'class')
        beep
        disp('No class selected for classification')
        disp('Please, define classes')
        return
    else
        for i=1:length(handles.class)
            ind=[];
            for g=1:length(handles.class(i).group)
                if ~isempty(handles.class(i).group(g).gr_name)
                    ind=[ind,g];
                end
            end
            handles.class(i).group=handles.class(i).group(ind);
        end
        in.class=handles.class;
    end
else
    if ~isfield(handles,'group')
        beep
        disp('No subjects/scans selected for classification')
        disp('Please, select subjects/scans')
        return
    else
        ind=[];
        for g=1:length(handles.group)
            if ~isempty(handles.group(g).gr_name)
                ind=[ind,g];
            end
        end
        handles.group=handles.group(ind);
        in.group=handles.group;
    end
end

%checks on the CV framework compared to the model entered
if strcmpi(in.cv.type,'lobo')
    if ~isfield(in,'class')
        beep
        disp('Leave One Block Out cross-validation only allowed for classification')
        disp('Please correct')
        return
    else
        for c=1:length(in.class)
            for i=1:length(in.class(c).group)
                if length(in.class(c).group(i).subj)>1
                    beep
                    disp('Leave One Block Out cross-validation only allowed for within-subject classification')
                    disp('Please correct')
                    return
                end
            end
        end
    end
end
if ~isfield(in,'class')
    if ~strcmpi(in.cv.type,'loso')
        beep
        disp('Regression only allows a Leave One Subject Out cross-validation')
        disp('Please correct')
    end
end

prt_model(handles.dat,in);

disp('Model specification complete.')
disp('Done...')
delete(handles.figure1)