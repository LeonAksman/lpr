function varargout = prt_ui_custom_CV(varargin)
% PRT_UI_CUSTOM_CV M-file for prt_ui_custom_CV.fig
% 
% PRT_UI_CUSTOM_CV, by itself, creates a new PRT_UI_CUSTOM_CV or 
% raises the existing singleton*.
%
% H = PRT_UI_CUSTOM_CV returns the handle to a new PRT_UI_CUSTOM_CV 
% or the handle to the existing singleton*.
%
% PRT_UI_CUSTOM_CV('CALLBACK',hObject,eventData,handles,...) calls the 
% local function named CALLBACK in PRT_UI_CUSTOM_CV.M with the given 
% input arguments.
%
% PRT_UI_CUSTOM_CV('Property','Value',...) creates a new PRT_UI_CUSTOM_CV
% or raises the existing singleton*.  Starting from the left, property 
% value pairs are applied to the GUI before prt_ui_custom_CV_OpeningFcn 
% gets called.  An unrecognized property name or invalid value makes 
% property application stop.  All inputs are passed to prt_ui_custom_CV_OpeningFcn
% via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id: prt_ui_custom_CV.m 672 2013-03-18 14:48:18Z schrouff $

% Edit the above text to modify the response to help prt_ui_custom_CV

% Last Modified by GUIDE v2.5 11-Jun-2013 14:45:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_custom_CV_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_custom_CV_OutputFcn, ...
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


% --- Executes just before prt_ui_custom_CV is made visible.
function prt_ui_custom_CV_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_custom_CV (see VARARGIN)

set(handles.figure1,'Name','PRoNTo :: Custom Cross-Validation')
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

% Choose the color of the different backgrounds and figure parameters
color=prt_get_defaults('color');
set(handles.figure1,'Color',color.bg1)
aa=get(handles.figure1,'children');
for i=1:length(aa)
    if strcmpi(get(aa(i),'type'),'uipanel')
        set(aa(i),'BackgroundColor',color.bg2)
        bb=get(aa(i),'children');
        if ~isempty(bb)
            for j=1:length(bb)
                if isfield(get(bb(j)),'Style')
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
        end
    elseif strcmpi(get(aa(i),'type'),'uicontrol')
        if ~isempty(find(strcmpi(get(aa(i),'Style'),{'text',...
                'radiobutton','checkbox','listbox'})))
            set(aa(i),'BackgroundColor',color.bg1)
        elseif ~isempty(find(strcmpi(get(aa(i),'Style'),'pushbutton')))
            set(aa(i),'BackgroundColor',color.fr)
        end
    end
    set(aa(i),'FontUnits','pixel')
    xf=get(aa(i),'FontSize');
    if ispc
        set(aa(i),'FontSize',ceil(FS*xf),'FontName',PF,...
            'FontUnits','normalized','Units','normalized')
    else
        set(aa(i),'FontSize',ceil(FS*xf),'FontName',PF,...
            'Units','normalized')
    end
end


%get information from the PRT.mat
if ~isempty(varargin)
    handles.CV=varargin{1};
    dat=num2cell(handles.CV);
    handles.ID=varargin{2};
    handles.in=varargin{3};
    handles.prt=varargin{4};
end
set(handles.editcv,'Data',dat);
disp_CV(hObject,handles,handles.ID,handles.CV)
set(handles.editcv,'ColumnEditable',true(1,size(handles.CV,2)));
lc=cell(size(handles.CV,2),1);
for i=1:size(handles.CV,2)
    lc{i}=['fold ',num2str(i)];
end
set(handles.editcv,'ColumnName',lc)
lr=cell(size(handles.CV,1),1);
for i=1:size(handles.CV,1)
    if max(handles.ID(:,2))>1
        lr{i}=['S',num2str(handles.ID(i,2)),' '];
    end
    if max(handles.ID(:,4))>1
        lr{i}=[lr{i},'c',num2str(handles.ID(i,4))];
    end
end
set(handles.editcv,'RowName',lr)
handles.flagdone=0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_specify_CV_basis wait for user response (see UIRESUME)
uiwait(handles.figure1);




% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_custom_CV_OutputFcn(hObject, eventdata, handles) 
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

%This figure can be deleted now
if isfield(handles,'figure1') && handles.flagdone
    delete(handles.figure1)
end




% --- Executes when entered data in editable cell(s) in editcv.
function editcv_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to editcv (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.CV=cell2mat(get(handles.editcv,'Data'));
if any(any(~ismember(handles.CV,[0,1,2])))
    beep
    disp('Values should be either 0, 1 or 2')
    return
end
disp_CV(hObject,handles,handles.ID,handles.CV)
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in done_button.
function done_button_Callback(hObject, eventdata, handles)
% hObject    handle to done_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.CV=cell2mat(get(handles.editcv,'Data'));
if any(any(~ismember(handles.CV,[0,1,2])))
    beep
    disp('Values should be either 0, 1 or 2')
    return
end
[modelid, PRT] = prt_init_model(handles.prt,handles.in);
PRT.model(modelid).input.cv_mat     = handles.CV;
PRT.model(modelid).input.cv_type=handles.in.cv.type;

% Save PRT.mat
% -------------------------------------------------------------------------
disp('Updating PRT.mat.......>>')
if spm_matlab_version_chk('7') >= 0
    save(handles.in.fname,'-V7','PRT');
else
    save(handles.in.fname,'-V6','PRT');
end
handles.flagdone=1;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1)



% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CV=handles.CV;
if ~ispc
    handles.in.fname = strrep(handles.in.fname,'\',filesep);
end
a=fileparts(handles.in.fname);
cvnam=fullfile(a,['CV_model_',handles.in.model_name,'.mat']);
disp('Saving Cross-Validation matrix in a .mat.......>>')
if spm_matlab_version_chk('7') >= 0
    save(cvnam,'-V7','CV');
else
    save(cvnam,'-V6','CV');
end

%--------------------------------------------------------------------------
%------------------------- Subfunctions -----------------------------------
%--------------------------------------------------------------------------
function disp_CV(hObject,handles,dat,CV)

cla(handles.axes1)
cla(handles.axes2)
cla(handles.axes3)

%Plot the id_mat in the left part of the window
set(handles.figure1,'CurrentAxes',handles.axes1)
for i=1:6
    dat(:,i)=dat(:,i)./max(dat(:,i));
end
imagesc(dat);
set(gca,'XTick',1:6)
set(gca,'XTickLabel',{'Group','Subject','Modality','Condition','Block','Scans'},...
    'FontWeight','demi','FontSize',9);
set(gca,'YTickLabel',{})
colorbar('Location','WestOutside')
set(get(gca,'Title'),'String','Feature set','FontWeight','bold')

%Plot the CV matrix in the right part of the window
set(handles.figure1,'CurrentAxes',handles.axes2)
xticksl=cell(1,size(CV,2));
for i=1:size(CV,2)
    xticksl{i}=num2str(i);
end
%inverting unused and test for colour purposes
if max(max(CV)-min(CV))>1
    indt=(CV==0);
    indu= (CV==2);
    CV(indt)=2;
    CV(indu)=0;
else
    indt=(CV==1);
    indu= (CV==2);
    CV(indt)=2;
    CV(indu)=1;
end

set(gca,'FontWeight','bold')
xlabel('CV Folds','fontweight','demi')
imagesc(CV);
set(gca,'XTick',1:i)
set(gca,'YTickLabel',{})
set(gca,'XTickLabel',xticksl,'FontWeight','demi','FontSize',9)
colormap(gray)
set(get(gca,'Title'),'String','Cross-Validation','FontWeight','bold')

%Plot the 'legend' corresponding to the CV matrix in the right bottom part
set(handles.figure1,'CurrentAxes',handles.axes3)
if max(max(CV)-min(CV))>1
    leg=[0; 1; 2];
    imagesc(leg);
    set(gca,'YTick',[1,2,3])
    set(gca,'YTickLabel',{'Test','Train','Unused'});
else
    leg=[1; 2];
    imagesc(leg);
    set(gca,'YTick',[1,2])
    set(gca,'YTickLabel',{'Test','Train'});
end
set(gca,'YAxisLocation','right')
set(gca,'XTickLabel',{})

% Update handles structure
guidata(hObject, handles);
