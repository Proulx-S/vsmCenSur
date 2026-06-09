clear all
close all
% figure('MenuBar','none','Toolbar','none')


% dataIndexFile = '~/work/generalPreproc/doIt_generalPreproc/vsmDiamCenSur_indexFile.mat';
% dataIndexFile = '~/work/generalPreproc/doIt_generalPreproc/vsmDiamCenSur_indexFile20250630.mat'; % after reprocessing of vfMRIpc
dataIndexFile = '/local/users/Proulx-S/generalPreproc/vsmDiamCenSur_indexFile20250630.mat';
%%%%%%%%%%%%%%%%%%%%%
%% Set up environment
%%%%%%%%%%%%%%%%%%%%%
% Detect computing environment
os   = char(java.lang.System.getProperty('os.name'));
host = char(java.net.InetAddress.getLocalHost.getHostName);
user = char(java.lang.System.getProperty('user.name'));

% Configure paths accordingly
if strcmp(os,'Linux') && strcmp(host,'takoyaki') && strcmp(user,'sebp')
    storageDir = '/local/users/Proulx-S/';
    scratchDir = '/scratch/users/Proulx-S/';
    toolDir    = fullfile(scratchDir,'tools');
    workScript = mfilename;
    workFile   = [workScript '.mat'];
    workDir    = fullfile(scratchDir,'vsmCenSur',workScript); if ~exist(workDir,'dir'); mkdir(workDir); end
    % workDir    = fullfile(getenv('HOME'),'/work/vsmCenSur/',workScript); if ~exist(workDir,'dir'); mkdir(workDir); end
    workFile   = fullfile(fileparts(workDir),workFile);
    envId      = 1;
    setenv('SINGULARITY_BINDPATH',strjoin({storageDir scratchDir toolDir workDir},','));
else
    dbstack; error('not implemented')
end

% Load dependencies
%%% matlab
restoredefaultpath
addpath(genpath(         workDir                                 ))
tool = 'vasomoTools'; toolURL = 'https://github.com/Proulx-S/vasomoTools.git';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,tool)))
% tool = 'bassReg2'; toolURL = 'https://github.com/Proulx-S/vasomoTools.git';
% if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
% addpath(genpath(fullfile(toolDir,tool)))
tool = 'util'; toolURL = 'https://github.com/Proulx-S/util.git';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,tool)))
% tool = 'chronux'; toolURL = 'https://github.com/Proulx-S/chronux';
% if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
% addpath(genpath(fullfile(toolDir,'chronux/chronux_2_12/modified')))
% tool = 'fieldtrip'; toolURL = 'https://github.com/fieldtrip/fieldtrip';
% if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
% addpath(genpath(fullfile(toolDir,'fieldtrip/external/freesurfer')))
% tool = 'shplot'; toolURL = 'https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/64990/versions/6/download/zip';
% if ~exist(fullfile(toolDir, tool), 'dir'); tmpZip = fullfile(tempdir, 'shplot.zip'); websave(tmpZip, toolURL); unzip(tmpZip, fullfile(toolDir, tool)); delete(tmpZip); end
% addpath(genpath(fullfile(toolDir,tool)))
% tool = 'multigradient'; toolURL = 'https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/4dc86a0f-886b-488c-9318-59a1c9fb0f3e/e5d982ae-3ddd-4768-8b34-8d71d956d893/packages/zip';
% if ~exist(fullfile(toolDir, tool), 'dir'); tmpZip = fullfile(tempdir, 'shplot.zip'); websave(tmpZip, toolURL); unzip(tmpZip, fullfile(toolDir, tool)); delete(tmpZip); end
% addpath(genpath(fullfile(toolDir,tool)))

tool = 'util'; repoURL = 'https://github.com/Proulx-S/util'; subTool = ''; branch = '';
gitClone(repoURL, fullfile(toolDir, tool), subTool, branch);

tool = 'vfMRItools'; repoURL = 'https://github.com/Proulx-S/vfMRItools'; subTool = ''; branch = 'dev-tsVSresp';
gitClone(repoURL, fullfile(toolDir, tool), subTool, branch);

tool = 'fieldtrip'; repoURL = 'https://github.com/fieldtrip/fieldtrip'; subTool = 'external/freesurfer'; branch = '';
gitClone(repoURL, fullfile(toolDir, tool), subTool, branch);
tool = 'multigradient'; toolURL = 'https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/4dc86a0f-886b-488c-9318-59a1c9fb0f3e/e5d982ae-3ddd-4768-8b34-8d71d956d893/packages/zip';
mathworksClone(toolURL, fullfile(toolDir, tool));
tool = 'shplot'; repoURL = 'https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/64990/versions/6/download/zip';
mathworksClone(repoURL, fullfile(toolDir, tool));




%%% neurodesk
switch envId
    case 1
        global src
        %%%% afni
        src.afni = 'ml afni/24.3.00';
        system([src.afni '; 3dinfo > /dev/null'],'-echo');
        %%%% ants
        src.ants = 'ml ants/2.5.3';
        system([src.ants '; antsRegistration --version > /dev/null'],'-echo');
        %%%% freesurfer
        src.fs   = 'ml freesurfer/8.0.0';
        system([src.fs   '; mri_convert > /dev/null'],'-echo');
        %%%% fsl for fslview once we figure out how to make it work
    otherwise
        dbstack; error('not implemented')
        % neurodeskModule = {
        % ":/neurodesktop-storage/containers/freesurfer_8.0.0_20250210"
        % ":/neurodesktop-storage/containers/afni_24.3.00_20241003"};
        % for i = 1:length(neurodeskModule)
        %     if contains(getenv("PATH"),neurodeskModule{i}); continue; end
        %     setenv("PATH",getenv("PATH") + neurodeskModule{i});
        % end
end
%% %%%%%%%%%%%%%%%%%%



if 0
tool = 'bassReg2'; repoURL = 'https://github.com/Proulx-S/bassReg2'; subTool = ''; branch = '';
gitClone(repoURL, fullfile(toolDir, tool), subTool, branch);

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load preprocessed data
% Load data index file
reorderSubj = [1 3 4 5 6 7 8 9 10 2];
disp('Loading index file...')
index = load(dataIndexFile);
rCond   = index.rCond; index = rmfield(index,'rCond');
subList = index.info.subList(reorderSubj);
rCond   = rCond(reorderSubj);
% fieldNames = fieldnames(index.QA);
% for i = 1:length(fieldNames)
%     index.QA.(fieldNames{i}) = index.QA.(fieldNames{i})(reorderSubj);
% end
disp('Subjects:')
disp(char(subList))
disp('---------')
% reorderAcq = [2 4 3 1];
reorderAcq = [3 6 5 1];
acqList = index.info.acqList(reorderAcq);
% acqList = {}; for S = 1:length(rCond); acqList = cat(1,acqList,fields(rCond{S})); end; acqList = unique(acqList);
% acqList(ismember(acqList,{'phs' 'QA'})) = []; acqList = acqList(reorderAcq);
disp('Acquisition conditions:')
disp(char(acqList))
disp('---------')
reorderTask = [3 2 1];
taskList = index.info.taskList(reorderTask);
% taskList = {};
% for S = 1:length(rCond)
%     for A = 1:length(acqList)
%         if ~isfield(rCond{S},acqList{A}); continue; end
%         taskList = cat(1,taskList,fields(rCond{S}.(acqList{A})));
%     end
% end
% taskList = unique(taskList);
% taskList = taskList(reorderTask);
disp('Tasks:')
disp(char(taskList))
disp('---------')

% Assert runCond
% disp('Asserting runCond...')
% % disp('getting tr from nifti headers')
% for S = 1:length(rCond)
%     disp(['getting tr from nifti headers (S=' num2str(S) '/' num2str(length(rCond)) ')'])
%     for A = 1:length(acqList)
%         if ~isfield(rCond{S},acqList{A}); continue; end
%         for T = 1:length(taskList)
%             task = taskList{T}; if ~isfield(rCond{S}.(acqList{A}),task) || isempty(rCond{S}.(acqList{A}).(task)); continue; end
%             % if isempty(rCond{S}.(acqList{A}).(task).tr)
%                 for R = 1:size(rCond{S}.(acqList{A}).(task).fPreprocList,1)
%                     rCond{S}.(acqList{A}).(task).tr(R,1) = MRIget(rCond{S}.(acqList{A}).(task).fPreprocList{R,1},'tr');
%                     % mri = MRIread(rCond{S}.(acqList{A}).(task).fPreprocList{R,1},1);
%                     % rCond{S}.(acqList{A}).(task).tr(R,1) = mri.tr/1000;
%                 end
%             % end
%         end
%     end
% end
% ts time-grid offset: the preprocessed timeseries has its first nDummy frames removed
% (nFrameOrig-nFrame), so its first sample sits at tsStartTime = (nFrameOrig-nFrame)*tr in the
% full (with-dummy) acquisition timeline. dsgn.onsetList is in that full-ts time, so any
% onset-relative ts indexing (getFaa/indexTs2Trial) must account for tsStartTime. Track it on rCond.
for S = 1:length(rCond)
    acqFlds = fieldnames(rCond{S});
    for A = 1:numel(acqFlds)
        if ~isstruct(rCond{S}.(acqFlds{A})); continue; end
        tkFlds = fieldnames(rCond{S}.(acqFlds{A}));
        for T = 1:numel(tkFlds)
            rc = rCond{S}.(acqFlds{A}).(tkFlds{T});
            if isempty(rc) || ~isa(rc,'runCond');                continue; end
            if isempty(rc.nFrameOrig) || isempty(rc.nFrame) || isempty(rc.tr); continue; end
            nRem = mode(double(rc.nFrameOrig(:)) - double(rc.nFrame(:)));   % dummy frames removed from the front
            rCond{S}.(acqFlds{A}).(tkFlds{T}).tsStartTime = nRem * mean(double(rc.tr(:)));
        end
    end
end

clear index
%% %%%%%%%%%%%%%%%%%%%%%%


forceThis   = 0;
verboseThis = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subject-by-subject and acquisition-by-acquisition QA --- AUTOMATIC STEPS
%%% Compute correlation matrix
for S = 1:length(rCond)
    for A = 1:length(acqList)
        acq = acqList{A};
        if ~isfield(rCond{S},acq) || isempty(rCond{S}.(acq)); continue; end
        
        %%% Combine runs
        [rCond{S}.(acq).QA.fList,rCond{S}.(acq).QA.fMaskList,rCond{S}.(acq).QA.nDummy,rCond{S}.(acq).QA.taskList,rCond{S}.(acq).QA.acqTime] = combineRunsAcrossTasks(rCond{S}.(acq));

        %%% Get correlation matrix
        [rCond{S}.(acq).QA.fXCorr,hXCorr] = xCorrQA(rCond{S}.(acq).QA.fList,rCond{S}.(acq).QA.fMaskList,rCond{S}.(acq).QA.nDummy,[],[],forceThis,verboseThis);
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


forceThis   = 0;
verboseThis = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subject-by-subject and acquisition-by-acquisition QA --- MANUAL STEPS and EXCLUSIONS
%%% Exclude frames and runs with bad spatial correspondence
% rCond = rCondOrig;
for S = 1:length(rCond)
    for A = 1:length(acqList)
        acq = acqList{A};
        if ~isfield(rCond{S},acq) || isempty(rCond{S}.(acq)); continue; end
        taskListTmp = fields(rCond{S}.(acq)); taskListTmp = taskListTmp(contains(taskListTmp,'task_'));


        % if contains(acq,'vfMRIpc')
        %     forceThis = 2;
        % else
        %     forceThis = 0;
        % end
        %%%% Intereactively define frame/run grouping
        [kI,k,rCond{S}.(acq).QA.fXCorrDendro,fClustId,mainClustId,hFig] = QAdendrogram(rCond{S}.(acq).QA.fXCorr,forceThis,verboseThis);
        if verboseThis<2; close(hFig); end

        %%%% Create new censor file based on clustering
        fCnsr_mainClust = replace(fClustId,'ClstIdx.1D',''); [fCnsr_mainClust,b,~] = fileparts(fCnsr_mainClust); fCnsr_mainClust = fullfile(fCnsr_mainClust,strcat('censorMainClst_',b,'.csv'));
        fCnsr           = replace(fCnsr_mainClust,'censorMainClst_','censor_');
        for R = 1:length(fClustId)
            clustId            = readmatrix(fClustId{R},'Filetype','text')';
            cnsrMainClust      = readmatrix(fCnsr{R} ,'Filetype','text');
            cnsrMainClust(:,2) = clustId==mainClustId(R);
            writematrix(cnsrMainClust, fCnsr_mainClust{R}, 'Delimiter', ',');
        end
        
        %%%% Add fClust, fClustCnsr and mainClust id things to rCond
        taskListTmp = fields(rCond{S}.(acq)); taskListTmp = taskListTmp(contains(taskListTmp,'task_'));
        for T = 1:length(taskListTmp)
            rCond{S}.(acq).(taskListTmp{T}).fClustId = fClustId(ismember(rCond{S}.(acq).QA.taskList,taskListTmp{T}));
            rCond{S}.(acq).(taskListTmp{T}).mainClustId = mainClustId(ismember(rCond{S}.(acq).QA.taskList,taskListTmp{T}));
            rCond{S}.(acq).(taskListTmp{T}).fCnsr = fCnsr(ismember(rCond{S}.(acq).QA.taskList,taskListTmp{T}));
            rCond{S}.(acq).(taskListTmp{T}).fCnsr_mainClust = fCnsr_mainClust(ismember(rCond{S}.(acq).QA.taskList,taskListTmp{T}));
        end
        
        %%%% Exclude runs that are not in the main cluster
        rCond{S}.(acq).QA.fListExclude = rCond{S}.(acq).QA.fList(mainClustId~=mode(mainClustId));
        rCondExcl{S,1}.(acq).QA = rCond{S}.(acq).QA;
        for T = 1:length(taskListTmp)
            rCondExcl{S,1}.(acq).(taskListTmp{T}) = rCond{S}.(acq).(taskListTmp{T});
            indExcl = ismember(rCondExcl{S,1}.(acq).(taskListTmp{T}).fPreprocList,rCond{S}.(acq).QA.fListExclude);
            allFields = {'ses' 'fList' 'fPreprocList' 'fPreprocMaskList' 'fTransList' 'fTransCatList' 'fOrigList' 'bidsList' 'wd' 'date' 'acqTime' 'nFrame' 'nFrameOrig' 'tr' 'trExc' 'nDummy' 'vSize' 'bhvr' 'fClustId' 'mainClustId' 'fCnsr' 'fCnsr_mainClust'};
            R = size(rCondExcl{S,1}.(acq).(taskListTmp{T}).fPreprocList,1);
            for F = 1:length(allFields)
                if size(rCondExcl{S,1}.(acq).(taskListTmp{T}).(allFields{F}),1)~=R
                    rCondExcl{S,1}.(acq).(taskListTmp{T}).(allFields{F})          = [];
                else
                    rCondExcl{S,1}.(acq).(taskListTmp{T}).(allFields{F})(indExcl,:,:) = [];
                end
            end
            if size(rCondExcl{S,1}.(acq).(taskListTmp{T}).fPreprocList,1)==0
                rCondExcl{S,1}.(acq) = rmfield(rCondExcl{S,1}.(acq),taskListTmp{T});
                % rCondExcl{S,1}.(acq).(taskListTmp{T}) = [];
            end
        end
    end
end
% QA.subList = subListU;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rCondOrig = rCond;
rCond = rCondExcl; clear rCondExcl


forceThis   = 0;
verboseThis = 0;
%%%%%%%%%%%%%%%%%%%%%%%%
%% Anatomical processing
% for A = 1%:length(acqList)
    A = find(contains(acqList,'vfMRI_'));
    for S = 1:size(subList,1)
        % if ~isfield(rCond{S},acqList{A}) || isempty(rCond{S}.(acqList{A})); continue; end
        % if contains(acqList{A},{'bold'}); continue; end
        % if contains(acqList{A},{'vfMRIpc' 'bold'}); continue; end
        [volAnat,rCond{S}.(acqList{A})] = volAnatPreproc6(rCond{S}.(acqList{A}),forceThis,verboseThis);
    end
% end
%% %%%%%%%%%%%%%%%%%%%%%


forceThis   = 0;
verboseThis = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Response estimation and activation detection processing
%%%
%%% NOTE: Need to figure out run order. Probably need to perform a sort according to acquisition time. More importantly, run-r in the bids filename might not always match the run index here in matlab (e.g. bids run-r might not be starting at and increasing by 1, and some runs might be excluded)
%%%
for S = 1:size(subList,1)
    for A = 1:length(acqList)
        % if A==2 || A==3; 
        %     forceThis   = 1;
        %     verboseThis = 1;
        % else
        %     forceThis   = 0;
        %     verboseThis = 0;
        % end

        % if contains(acqList{A},'vfMRIpc')
        %     forceThis = 1;
        % else
        %     forceThis = 0;
        % end

        acq  = acqList{A}; if ~isfield(rCond{S},acq) || isempty(rCond{S}.(acq)); continue; end
        for T = 1:length(taskList)
            task = taskList{T}; if ~isfield(rCond{S}.(acq),task) || isempty(rCond{S}.(acq).(task)); continue; end

            [volResp,volRespCmplx,volRespCmplxMag1] = getVolResp2(rCond{S}.(acq).(task),[],[],[],forceThis,verboseThis);
            
            
            %%% get nTrial
            volResp.respCat.xMat.nTrial = sum(volResp.respCat.xMat.mat(~volResp.respCat.xMat.cnsr,volResp.respCat.xMat.nPoly+1:end),1);
            if length(volResp.respCat.xMat.nTrial)~=volResp.respCat.xMat.nReg; dbstack; error('nTrial mismatch'); end

            
            %%% compile results
            rCond{S}.(acq).(task).volResp.mag       = volResp;
            rCond{S}.(acq).(task).volResp.cmplx     = volRespCmplx;
            rCond{S}.(acq).(task).volResp.cmplxMag1 = volRespCmplxMag1;

        end
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get number of censored frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
subIndList = [];
for S = 1:size(subList,1)
    if ~isfield(rCond{S},acq) || ~isfield(rCond{S}.(acq),task); continue; end
    subIndList(end+1) = S;
end
nCnsr = rCond(subIndList);
for s = 1:size(nCnsr,1)
    nCnsr{s}.vfMRI_dflt_none.task_50sPrd5sDur
    fList = nCnsr{s}.vfMRI_dflt_none.task_50sPrd5sDur.volResp.mag.respCat.cmd{contains(nCnsr{s}.vfMRI_dflt_none.task_50sPrd5sDur.volResp.mag.respCat.cmd,'-input')}; fList = strsplit(fList,' ')'; fList([1 end]) = []; fList = replace(fList,'[0..$]','');
    if any(contains(nCnsr{s}.vfMRI_dflt_none.task_50sPrd5sDur.volResp.mag.respCat.cmd,'-CENSORTR'))
        cnsrList = nCnsr{s}.vfMRI_dflt_none.task_50sPrd5sDur.volResp.mag.respCat.cmd{contains(nCnsr{s}.vfMRI_dflt_none.task_50sPrd5sDur.volResp.mag.respCat.cmd,'-CENSORTR')}; cnsrList = strsplit(cnsrList,' ')'; cnsrList = cellfun(@(x) str2num(x),strsplit(cnsrList{2},','),'UniformOutput',false); cnsrList = [cnsrList{:}];
    else
        cnsrList = [];
    end
    frame0 = 0;
    tmp.nFrame = nan(size(fList))';
    tmp.nCnsrFrames = nan(size(fList))';
    for r = 1:length(fList)
        tmp.nFrame(r) = MRIget(fList{r},'nt');
        tmp.nCnsrFrames(r) = nnz(ismember(cnsrList,(0:tmp.nFrame(r)-1)+frame0));
        frame0 = frame0 + tmp.nFrame(r);
    end
    nCnsr{s} = tmp;
end
nCnsr = [nCnsr{:}]';
for s = 1:size(nCnsr,1)
    nCnsr(s).prcntCnsr = nCnsr(s).nCnsrFrames./nCnsr(s).nFrame*100;
    nCnsr(s).prcntCnsrTot = sum(nCnsr(s).nCnsrFrames)/sum(nCnsr(s).nFrame)*100;
end
nCnsr.prcntCnsr;
nCnsr.prcntCnsrTot;

% QA = rCond(subIndList);
% for s = 1:size(nCnsr,1)
%     QA{s} = QA{s}.vfMRI_dflt_none.QA;
% end
% QA = [QA{:}];
% for s = 1:length(QA)
%     openfig(QA(s).fXCorrDendro);
% end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%
%% Get ROI data
% note: S=6 does not have the same matrix size for vfMRIpc vs vfMRIinflow, screwing up extraction of rois from vfMRIpc since they are defined using vfMRIinflow
roi = cell(size(subList));
for S = 1:size(subList,1)%:size(subList,1)
    disp(['extracting ROI data: ' subList{S}])
    taskTmp = fields(rCond{S}.vfMRI_dflt_none); taskTmp = taskTmp(contains(taskTmp,'task_'));
    label = rCond{S}.vfMRI_dflt_none.(taskTmp{1}).volAnat.label.calcarineVessel;
            
    for A = 1:length(acqList)
        acq  = acqList{A};
        % acq  = 'vfMRI_dflt_none';
        if ~isfield( rCond{S},acq )  ; continue; end
        if ~contains(acq,{'vfMRI'  }); continue; end
        if  contains(acq,{'vfMRIpc'}); continue; end
        for T = 1:length(taskList)
            task = taskList{T};
            if ~isfield(rCond{S}.(acq),task); continue; end

            % rebuild roi but with functional data (resp and act)
            if contains(acq,'vfMRIpc')
                imField = {
                    'base'
                    'basePolyRun'
                    'basePhase'
                    'basePhase_tsAv'
                    'vesselness'
                    'ts'
                    'resp'
                    % 'respSd'
                    % 'respF'
                    % 'respP'
                    % 'respQ'
                    'act'
                    'actF'
                    'actP'
                    'actQ'
                    };
            else
                imField = {
                    'base'
                    'basePolyRun'
                    'basePhase'
                    'basePhase_tsAv'
                    'vesselness'
                    'ts'
                    'resp'
                    'resp2'
                    'respSd'
                    'respF'
                    'respP'
                    'respQ'
                    'act'
                    'actF'
                    'actP'
                    'actQ'
                    };
            end
            
            % define main underlay image
            if isfield(rCond{S}.(acq).(task).volResp.mag.respCat.stats,'fTsAvBase_catAv')
                fBase    = rCond{S}.(acq).(task).volResp.mag.respCat.stats.fTsAvBase_catAv;
            else
                fBase    = char(rCond{S}.(acq).(task).volResp.mag.respCat.stats.fTsAvBase);
            end
            fBasePolyRun = rCond{S}.(acq).(task).volResp.mag.respCat.stats.fPoly0Base;
            
            
            % define secondary underlay image (phase)
            fBasePhase = '';
            fBasePhase_tsAv = '';
            % get baseline phase from fit
            if isfield(rCond{S}.(acq).(task).volResp,'cmplxMag1') && ~isempty(rCond{S}.(acq).(task).volResp.cmplxMag1)
                
                if isfield(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats,'fPoly0Base_catAv') && ~isempty(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fPoly0Base_catAv)
                    ind = contains(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fPoly0Base_catAv,{'part-realImagMag1'})...
                    & contains(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fPoly0Base_catAv,{'poly0basePhase'});
                    fBasePhase = char(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fPoly0Base_catAv(ind));
                else
                    ind = contains(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fPoly0Base,{'part-realImagMag1'})...
                    & contains(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fPoly0Base,{'poly0basePhase'});
                    fBasePhase = char(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fPoly0Base(ind));
                end
            end


            % get baseline phase from time average
            if isfield(rCond{S}.(acq).(task).volResp,'cmplxMag1') && ~isempty(rCond{S}.(acq).(task).volResp.cmplxMag1)
                b = cat(1,rCond{S}.(acq).(task).volResp.cmplxMag1.respRun.fIn);
                c = cat(1,rCond{S}.(acq).(task).volResp.cmplxMag1.respRun.fCnsr);
                for i = 1:size(c,1)
                    % Read the CSV file specified by c{i}
                    c{i} = readtable(c{i});
                    c{i} = logical(c{i}.Var2);
                    for ii = 1:size(b,3)
                        b{i,:,ii} = MRIread(b{i,:,ii});
                        b{i,:,ii} = b{i,:,ii}.vol(:,:,:,c{i});
                    end
                end
                for ii = 1:size(b,3)
                    b{1,:,ii} = mean(cat(4,b{:,:,ii}),4);
                end
                b(2:end,:,:) = [];
                b = complex(b{:,:,1},b{:,:,2});
                fBasePhase_tsAv = MRIread(rCond{S}.(acq).(task).volResp.cmplxMag1.respRun(1).fIn{1},1);
                fBasePhase_tsAv.vol = angle(b);
                fBasePhase_tsAv.fspec = [tempname '.nii.gz'];
                MRIwrite(fBasePhase_tsAv,fBasePhase_tsAv.fspec);
                fBasePhase_tsAv = fBasePhase_tsAv.fspec;
            end
                

            [~,b,~] = fileparts(label.fBaseList);
            fCondCoef = char(rCond{S}.(acq).(task).volResp.mag.actCat.stats.fCondCoef_adj); coefAdjFlag = 1;
            if isempty(fCondCoef); fCondCoef = char(rCond{S}.(acq).(task).volResp.mag.actCat.stats.fCondCoef); coefAdjFlag = 0; end
            
            
            if contains(acq,'vfMRIpc')
                im = {
                    fBase
                    fBasePolyRun
                    fBasePhase
                    fBasePhase_tsAv
                    label.fBaseList{contains(b,'vesselness.nii')}
                    rCond{S}.(acq).(task).fPreprocList(:,5)
                    char(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fResp(3))
                    % char(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fRespStd)
                    % char(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fCondF)
                    % char(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fCondF_pVal)
                    % char(rCond{S}.(acq).(task).volResp.cmplxMag1.respCat.stats.fCondF_qVal)
                    char(fCondCoef)
                    char(rCond{S}.(acq).(task).volResp.mag.actCat.stats.fCondF)
                    char(rCond{S}.(acq).(task).volResp.mag.actCat.stats.fCondF_pVal)
                    char(rCond{S}.(acq).(task).volResp.mag.actCat.stats.fCondF_qVal)
                    };
            else
                % if any(ismember(imField,'ts')) && isempty(rCond{S}.(acq).(task).volTs)
                %     for f = 1:length(rCond{S}.(acq).(task).fPreprocList)
                %         disp(['Loading time series: ' num2str(f) ' of ' num2str(length(rCond{S}.(acq).(task).fPreprocList))])
                %         if f==1
                %             rCond{S}.(acq).(task).volTs = MRIread(rCond{S}.(acq).(task).fPreprocList{f});
                %         else
                %             rCond{S}.(acq).(task).volTs(f,1) = MRIread(rCond{S}.(acq).(task).fPreprocList{f});
                %         end
                %     end
                % end
                fTmp = [rCond{S}.(acq).(task).volResp.mag.respRun.stats];
                im = {
                    fBase
                    fBasePolyRun
                    fBasePhase
                    fBasePhase_tsAv
                    label.fBaseList{contains(b,'vesselness.nii')}
                    rCond{S}.(acq).(task).fPreprocList
                    char(rCond{S}.(acq).(task).volResp.mag.respCat.stats.fResp)
                    [fTmp.fResp]'
                    char(rCond{S}.(acq).(task).volResp.mag.respCat.stats.fRespSd)
                    char(rCond{S}.(acq).(task).volResp.mag.respCat.stats.fCondF)
                    char(rCond{S}.(acq).(task).volResp.mag.respCat.stats.fCondF_pVal)
                    char(rCond{S}.(acq).(task).volResp.mag.respCat.stats.fCondF_qVal)
                    char(fCondCoef)
                    char(rCond{S}.(acq).(task).volResp.mag.actCat.stats.fCondF)
                    char(rCond{S}.(acq).(task).volResp.mag.actCat.stats.fCondF_pVal)
                    char(rCond{S}.(acq).(task).volResp.mag.actCat.stats.fCondF_qVal)
                    };
            end
            cropSz = 10;
            [roi{S}.(acq).(task).vessel,roi{S}.(acq).(task).vesselRegion] = getVesselRoi2(label,imField,im,[cropSz 0]);
            [roi{S}.(acq).(task).vessel.coefAdjFlag] = deal(coefAdjFlag);
            roi{S}.(acq).(task).tsStartTime = rCond{S}.(acq).(task).tsStartTime;  % ts dummy-offset, carried from rCond (see Load section)
            for i = 1:length(roi{S}.(acq).(task).vessel)
                roi{S}.(acq).(task).vessel(i).im.resp.dt = rCond{S}.(acq).(task).volResp.mag.respCat.param.trDecon;
            end


            % modify roi
            roi{S}.(acq).(task).vessel = modifyRoi(roi{S}.(acq).(task).vessel,{'peakVox' 'dilate1' 'dilate1p5' 'dilate2' 'tissue'});
            % roi{S}.(acq).(task).vessel = modifyRoi(roi{S}.(acq).(task).vessel,{'tissue'});



            for i  = 1:length(roi{S}.(acq).(task).vessel)
                % remove background phase if pc data
                if contains(acq,'vfMRIpc')
                    imPhsBase = roi{S}.(acq).(task).vessel(i).im.basePhase.im;
                    [bckgrndMask,f] = getRoiBckgrndMask(imBase,0);
                    if ~isempty(f)
                        f = [f{:}];
                        ax = findobj([f.Children],'Type','axes');
                        title(ax(end),['sub ' subList{S} '; task ' task '; roi' num2str(i)]);
                    end
                    [xBase,yBase] = pol2cart(imPhsBase,1);
                    [bckgrndPhs,~] = cart2pol(mean(xBase(bckgrndMask)),mean(yBase(bckgrndMask)));
                    roi{S}.(acq).(task).vessel(i).im.basePhase.bias.maskBase = roi{S}.(acq).(task).vessel(i).im.basePhase;
                    roi{S}.(acq).(task).vessel(i).im.basePhase.bias.mask     = bckgrndMask;
                    roi{S}.(acq).(task).vessel(i).im.basePhase.bias.offsetIm = imPhsBase;
                    roi{S}.(acq).(task).vessel(i).im.basePhase.bias.offset   = bckgrndPhs;
                    roi{S}.(acq).(task).vessel(i).im.resp.bias.maskBase = roi{S}.(acq).(task).vessel(i).im.basePhase;
                    roi{S}.(acq).(task).vessel(i).im.resp.bias.mask     = bckgrndMask;
                    roi{S}.(acq).(task).vessel(i).im.resp.bias.offsetIm = imPhsBase;
                    roi{S}.(acq).(task).vessel(i).im.resp.bias.offset   = bckgrndPhs;
                    drawnow;
                end
            end


            % add number of runs and trials
            [roi{S}.(acq).(task).vessel.R]      = deal(rCond{S}.(acq).(task).volResp.mag.respCat.R);
            [roi{S}.(acq).(task).vessel.nTrial] = deal(rCond{S}.(acq).(task).volResp.mag.respCat.xMat.nTrial');

            % % modify roi
            % roi{S}.(acq).(task).vessel = modifyRoi(roi{S}.(acq).(task).vessel,{'peakVox' 'dilate1' 'dilate1p5' 'dilate2'});

            % % % summarize rois (vox2roi)
            % % vessels = roi{S}.(acq).(task).vessel;
            % % vessels = {vessels(ismember({vessels.class},'artery')) vessels(ismember({vessels.class},'vein'))};
            % % roi{S}.(acq).(task).vessels = mergeRoi(vessels);


            % add manual annotations
            switch acq
                case 'vfMRI_dflt_none'
                    switch task
                        case 'task_50sPrd5sDur'
                            switch S
                                case 1
                                    artSig = [1 2 3 6];
                                    artCS  = [1 2 3 6];
                                    artLR  = [];
                                    artBlb = [];
                                    veiSig = [1];
                                    veiBlb = [1];
                                case 2
                                    artSig = [1 3 4];
                                    artCS  = [1];
                                    artLR  = [3 4];
                                    artBlb = [];
                                    veiSig = [1 2 3 4 5 6];
                                    veiBlb = [1 2 3 4 5 6];
                                case 4
                                    artSig = [1 2 3];
                                    artCS  = [3];
                                    artLR  = [];
                                    artBlb = [];
                                    veiSig = [1 2 3];
                                    veiBlb = [1 2 3];
                                case 5
                                    artSig = [1 2 3 4];
                                    artCS  = [];
                                    artLR  = [1 4];
                                    artBlb = [3];
                                    veiSig = [1 2 3 5];
                                    veiBlb = [1 2 3];
                                case 7
                                    artSig = [1 2 3 4 5 6 7 8];
                                    artCS  = [7];
                                    artLR  = [1 6];
                                    artBlb = [8];
                                    veiSig = [1 2 3];
                                    veiBlb = [1 2 3];
                                case 8
                                    artSig = [1 2 3 4 6 7];
                                    artCS  = [2 4];
                                    artLR  = [1];
                                    artBlb = [];
                                    veiSig = [1 2];
                                    veiBlb = [1];
                                case 10
                                    artSig = [1 2 3];
                                    artCS  = [];
                                    artLR  = [1 3];
                                    artBlb = [];
                                    veiSig = [1 2];
                                    veiBlb = [1 2];
                                otherwise
                                    artSig = [];
                                    artCS  = [];
                                    artLR  = [];
                                    artBlb = [];
                                    veiSig = [];
                                    veiBlb = [];
                            end
                        otherwise
                            artSig = [];
                            artCS  = [];
                            artLR  = [];
                            artBlb = [];
                            veiSig = [];
                            veiBlb = [];
                    end
                otherwise
                    artSig = [];
                    artCS  = [];
                    artLR  = [];
                    artBlb = [];
                    veiSig = [];
                    veiBlb = [];
            end

            %%% insert manual annotations
            class = {roi{S}.(acq).(task).vessel.class};
            id    = [roi{S}.(acq).(task).vessel.id];
            %%%% significance
            [roi{S}.(acq).(task).vessel.anot_sig]      = deal(false);
            ind   = ismember(class,'artery') & ismember(id,artSig);
            [roi{S}.(acq).(task).vessel(ind).anot_sig] = deal(true );
            ind   = ismember(class,'vein')   & ismember(id,veiSig);
            [roi{S}.(acq).(task).vessel(ind).anot_sig] = deal(true );
            %%%% activation pattern
            [roi{S}.(acq).(task).vessel.anot_actType]      = deal('');
            %%%%% center-surround artery
            ind   = ismember(class,'artery') & ismember(id,artCS);
            [roi{S}.(acq).(task).vessel(ind).anot_actType] = deal('center-surround');
            %%%%% left-right artery
            ind   = ismember(class,'artery') & ismember(id,artLR);
            [roi{S}.(acq).(task).vessel(ind).anot_actType] = deal('left-right');
            %%%%% blob artery
            ind   = ismember(class,'artery') & ismember(id,artBlb);
            [roi{S}.(acq).(task).vessel(ind).anot_actType] = deal('blob');
            %%%%% blob vein
            ind   = ismember(class,'vein')   & ismember(id,veiBlb);
            [roi{S}.(acq).(task).vessel(ind).anot_actType] = deal('blob');
            %%%%% unclear
            ind = cellfun('isempty',{roi{S}.(acq).(task).vessel.anot_actType});
            [roi{S}.(acq).(task).vessel(ind).anot_actType] = deal('unclear');
            %%%%% non-significant
            ind = ~[roi{S}.(acq).(task).vessel.anot_sig];
            [roi{S}.(acq).(task).vessel(ind).anot_actType] = deal('non-sig');
            
            % [{roi{S}.(acq).(task).vessel.anot_actType}'...
            % {roi{S}.(acq).(task).vessel.class}'...
            % {roi{S}.(acq).(task).vessel.anot_sig}']
        end
    end
end
%% %%%%%%%%%%%%






% Save all
% winSz = rCond{S}.vfMRI_dflt_none.task_50sPrd5sDur.volMt.run(1).param.psdTrialGram.dsgn.win(1);
% K;
% filename = ['results20250508_K' strjoin(cellstr(num2str(K(2:3)')),'-') '_winSz' num2str(winSz) 'tPts.mat'];
% filename = fullfile(pwd,'workScript_20260116.mat');
% filename = fullfile(pwd,'workScript_20260606.mat');
filename = fullfile(pwd,'workScript_20260609.mat');
disp(['saving ' filename])
save(filename,'-v7.3')
else
% Load all
% filename = 'results20250505_K4-6_winSz19tPts.mat';
% filename = 'results20250505_K3-5_winSz24tPts.mat';
% filename = 'results20250505_K3-4_winSz26tPts.mat';
% filename = 'results20250505_K3-5_winSz30tPts.mat';
% filename = 'results20250508_K4-5_winSz28tPts.mat';
% filename = fullfile(pwd,'workScript_tmp2.mat');
% filename = fullfile(pwd,'workScript_20260116.mat');
% filename = fullfile(pwd,'workScript_20260606.mat');
filename = fullfile(pwd,'workScript_20260609.mat');
disp(['loading ' filename])
load(filename)
end











% acq = 'vfMRI_dflt_none';
% task = 'task_50sPrd5sDur';
% subIndList = [];
% for S = 1:size(subList,1)
%     if ~isfield(rCond{S},acq) || ~isfield(rCond{S}.(acq),task); continue; end
%     subIndList(end+1) = S;
% end
% for s = 1:length(subIndList)
%     S = subIndList(s);
%     % disp(s)
%     % % rCond{subIndList(s)}.(acq).(task).volAnat.tof
%     % rCond{subIndList(s)}.(acq).(task).volAnat.avMap
%     % rCond{subIndList(s)}.(acq).(task).vol
%     % roi{subIndList(s)}.(acq).(task).vessel(1).polyLabel
    


%     tiling = plotUL3(roi{S}.(acq).(task).vessel,'base'     ,[100 1500],4);
%     hFol   = {}; hAol   = {}; hIol   = {};
%     hFresp = {}; hAresp = {}; hTresp = {};
%     [hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'coef'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
%     threshOL(hIol{end},'off',0);

%     adjPoly(hIol{end},'original','y',-1);
%     adjPoly(hIol{end},'dilate1','w',1);
%     close(tiling.main.hF);
% end







if 0
%%%%%%%%%%%%%%
%% SVD for Jon
%%%%%%%%%%%%%%
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
subIndList = [];
for S = 1:size(subList,1)
    if ~isfield(rCond{S},acq) || ~isfield(rCond{S}.(acq),task); continue; end
    subIndList(end+1) = S;
end
volResp = rCond(subIndList);
for s = 1:size(volResp,1)
    volResp{s} = volResp{s}.(acq).(task).volResp.mag.respCat;
    volResp{s}.subId = subList{subIndList(s)};
end
for s = 1:length(volResp)
    mriResp(s) = MRIread(char(volResp{s}.fResp));
    mriQVal(s) = MRIread(char(volResp{s}.stats.fCondF_qVal));
end

figure('MenuBar','none','ToolBar','none');
ht = tiledlayout(2,ceil(length(volResp)/2)); ht.TileSpacing = 'compact'; ht.Padding = 'compact'; ax = {};
for s = 1:length(volResp)
    ax{end+1} = nexttile;
    t    = linspace(0,(mriResp(s).nframes-1)*mriResp(s).tr/1000,mriResp(s).nframes);
    resp = permute(mriResp(s).vol,[4 1 2 3]);
    resp = resp(:,mriQVal(s).vol<0.05);
    [U,S,V] = svd(resp','econ','vector');
    [~,b] = max(abs(V(:,1))); Vsign = sign(V(b,1));
    V = Vsign .* V;
    U = Vsign .* U;
    hP1 = plot(t,V(:,1).*S(1).*mean(U(:,1))); hold on;                                        % component 1 contribution to the voxel-mean response
    hP2 = plot(t,V(:,2).*S(2).*mean(U(:,2)),'lineStyle','--','Color',hP1.Color); hold on;      % component 2 contribution to the voxel-mean response
    hP3 = plot(t,mean(resp,2)); hold on;
    axis tight; grid on;
    xlabel('time after stimulus onset (s)'); ylabel('MR signal (a.u.)');
    if s == 1
        legend('sVector 1 * sValue 1 * mean(spatial sVector 1)','sVector 2 * sValue 2 * mean(spatial sVector 2)','mean response','Location','best');
    end
    title([{volResp{s}.subId} {[num2str(volResp{s}.R) ' runs; ' num2str(size(resp,2)) 'voxels (model-free fdr<0.05); ']}]);
end
drawnow;
saveas(gcf,fullfile(pwd,'svdResp.fig'));
%% %%%%%%%%%%%
end




% mriResp = mriResp.vol;
% mriQVal = mriQVal.vol;
% mriResp = permute(mriResp,[4 1 2 3]);
% mriQVal = permute(mriQVal,[4 1 2 3]);
% mriResp = mriResp(:,mriQVal<0.05);
% mriQVal = mriQVal(:,mriQVal<0.05);
% mriResp = mriResp(:,mriQVal<0.05);



if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get age and sex from dcm files
age = cell(size(rCond));
sex = cell(size(rCond));
for r = 1:length(rCond)
    tmpField = fields(rCond{r}.vfMRI_dflt_none);
    tmpField = tmpField{find(contains(tmpField,'task_'),1,'first')};
    dcmDir = fileparts(rCond{r}.vfMRI_dflt_none.(tmpField).dirsOrig.bids);
    tmp = dir(fullfile(dcmDir,'dcm/*'));
    if isempty(tmp)
        tmp = dir(fullfile(dcmDir,'dcm2/*'));
    end
    dcmDir = dir(fullfile(tmp(1).folder,tmp(1).name));
    tmp = contains({dcmDir.name},'dcm');
    if nnz(tmp)==1
        dcmDir = dir(fullfile(dcmDir(tmp).folder,dcmDir(tmp).name));
    end
    tmp = contains({dcmDir.name},'Terra-');
    if nnz(tmp)==1
        dcmDir = dir(fullfile(dcmDir(tmp).folder,dcmDir(tmp).name));
    end
    tmp = contains({dcmDir.name},'MR.');
    if any(tmp)
        dcmInfo = dicominfo(fullfile(dcmDir(find(tmp,1,'first')).folder,dcmDir(find(tmp,1,'first')).name));
    end
    age{r} = dcmInfo.PatientAge;
    sex{r} = dcmInfo.PatientSex;
end
age = str2double(replace(age,'Y',''));

acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
subIndList = [];
for S = 1:size(subList,1)
    if ~isfield(rCond{S},acq) || ~isfield(rCond{S}.(acq),task); continue; end
    subIndList(end+1) = S;
end
age = age(subIndList);
sex = sex(subIndList);
std(age)
mean(age)
min(age)
max(age)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

if 0
%%%%%%%%%%%%%%%%%%%%
%% Get behavior data
%%%%%%%%%%%%%%%%%%%%
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
subIndList = [];
for S = 1:size(subList,1)
    if ~isfield(rCond{S},acq) || ~isfield(rCond{S}.(acq),task); continue; end
    subIndList(end+1) = S;
end
bhvr = rCond(subIndList);
for s = 1:size(bhvr,1)
    bhvr{s} = bhvr{s}.vfMRI_dflt_none.task_50sPrd5sDur.bhvr;
end
for s = 1:size(bhvr,1)
    tmp={bhvr{s}.percFalsePositive};
    n(s) = length(tmp);
    tmp=replace(tmp,'%',''); tmp=strrep(tmp,'	',''); tmp=strrep(tmp,' ','');
    fp{s} = str2double(tmp);
    fpAv(s) = mean(fp{s});
    fpEr(s) = std(fp{s});
    tmp={bhvr{s}.percTruePositive};
    tmp=replace(tmp,'%',''); tmp=strrep(tmp,'	',''); tmp=strrep(tmp,' ','');
    tp{s} = str2double(tmp);
    tpAv(s) = mean(tp{s});
    tpEr(s) = std(tp{s});
end



%% %%%%%%%%%%%%%%%%%
end

if 0
%%%%%%%%%%%%%%%%%%%%%%
%% Get FA and TxRefAmp
%%%%%%%%%%%%%%%%%%%%
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
subIndList = [];
for S = 1:size(subList,1)
    if ~isfield(rCond{S},acq) || ~isfield(rCond{S}.(acq),task); continue; end
    subIndList(end+1) = S;
end

dirsOrig = rCond(subIndList);
for s = 1:size(dirsOrig,1)
    [~,b,c] = fileparts(dirsOrig{s}.vfMRI_dflt_none.task_50sPrd5sDur.fList);    
    dirsOrig{s} = fullfile(dirsOrig{s}.vfMRI_dflt_none.task_50sPrd5sDur.dirsOrig.bids,'func',replace(strcat(b,c),'.nii.gz','.json'));
    if isempty(dir(dirsOrig{s}{1}))
        dirsOrig{s} = replace(dirsOrig{s},'_angio.json','*_angio.json');
    end
end

flipAngle = cell(size(dirsOrig));
txRefAmp = cell(size(dirsOrig));
for s = 1:size(dirsOrig,1)
    flipAngle{s} = nan(size(dirsOrig{s}));
    txRefAmp{s}  = nan(size(dirsOrig{s}));
    for r = 1:size(dirsOrig{s},1)
        tmp = dir(dirsOrig{s}{r});
        jsonData = jsondecode(fileread(fullfile(tmp.folder,tmp.name)));
        flipAngle{s}(r) = jsonData.FlipAngle;
        txRefAmp{s}(r) = jsonData.TxRefAmp;
    end
    flipAngle{s} = unique(flipAngle{s});
    txRefAmp{s} = unique(txRefAmp{s});
end
%% %%%%%%%%%%%%%%%%%%%
end



if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get polar coefficients adjustment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
subIndList = [];
for S = 1:size(subList,1)
    if ~isfield(rCond{S},acq) || ~isfield(rCond{S}.(acq),task); continue; end
    subIndList(end+1) = S;
end
hFig = rCond(subIndList);

s = 1;
hFig{s} = openfig(char(hFig{s}.vfMRI_dflt_none.task_50sPrd5sDur.volResp.mag.actCat.stats.fCondCoef_mainVector));
ax = findobj(hFig{s}.Children,'type','axes');
axScatter = ax;  % keep for adding quadrant labels later
xlabel(ax,'SPM canon (coef)'); ylabel(ax,'SPM canon derivative (coef)');
% Prevent legend from updating with subsequent plot commands
set(get(ax,'Legend'),'AutoUpdate','off')
hLine = findobj(ax.Children,'type','Line');
hScatter = findobj(ax.Children,'type','Scatter');
hScatter.MarkerEdgeColor = 'w';
plot(hLine(1).YData,flip(hLine(1).XData),'-r')
drawnow;


% Plot data and SPMG2 fit for each adjusted quandrant
xMat = rCond{S}.(acq).(task).volResp.mag.actCat.xMat.mat;    
mriQval = MRIread(char(           rCond{S}.(acq).(task).volResp.mag.actCat.stats.fCondF_qVal  ));
mriData =                         rCond{S}.(acq).(task).volResp.mag.actCat.fIn                  ; for d = 1:length(mriData); mriData{d} = MRIread(mriData{d}); end; mriData = [mriData{:}];
mriCoefAdj = MRIread(        char(rCond{S}.(acq).(task).volResp.mag.actCat.stats.fCondCoef_adj));    
mriCoef    = afni_getFitCoef(char(rCond{S}.(acq).(task).volResp.mag.actCat.stats.fStat        ));
data    = permute(     cat(4,mriData.vol)   ,[4 1 2 3]);
coefAdj = permute(           mriCoefAdj.vol ,[4 1 2 3]);
coef    = permute(           mriCoef.vol    ,[4 1 2 3]);
data    = data(   :,mriQval.vol<0.05);
coefAdj = coefAdj(:,mriQval.vol<0.05);
coef    = coef(   :,mriQval.vol<0.05);

whos data coefAdj coef xMat

dataFit  = xMat*coef;
dataFit1 = xMat(:,end-1  )*coef(  end-1,:);
dataFit2 = xMat(:,end    )*coef(  end  ,:);
dataBase = xMat(:,1:end-2)*coef(1:end-2,:);
sz = size(dataFit);
dataFitX = permute(mean(reshape(permute(dataFit,[2 1]),[sz(2) sz(1)/length(mriData) length(mriData)]),3),[2 1]);
sz = size(dataFit1);
dataFit1X = permute(mean(reshape(permute(dataFit1,[2 1]),[sz(2) sz(1)/length(mriData) length(mriData)]),3),[2 1]);
sz = size(dataFit2);
dataFit2X = permute(mean(reshape(permute(dataFit2,[2 1]),[sz(2) sz(1)/length(mriData) length(mriData)]),3),[2 1]);
sz = size(dataBase);
dataBaseX = permute(mean(reshape(permute(dataBase,[2 1]),[sz(2) sz(1)/length(mriData) length(mriData)]),3),[2 1]);
sz = size(data);
dataX    = permute(mean(reshape(permute(data   ,[2 1]),[sz(2) sz(1)/length(mriData) length(mriData)]),3),[2 1]);

q1Idx = coefAdj(1,:)<0 & coefAdj(2,:)>0; q1Label = 'late negative';
q2Idx = coefAdj(1,:)>0 & coefAdj(2,:)>0; q2Label = 'early positive';
q3Idx = coefAdj(1,:)<0 & coefAdj(2,:)<0; q3Label = 'early negative';
q4Idx = coefAdj(1,:)>0 & coefAdj(2,:)<0; q4Label = 'late positive';

hF = figure('MenuBar','none','ToolBar','none');
ht = tiledlayout(2,2); ht.TileSpacing = 'compact'; ht.Padding = 'compact'; ax = {};
ax{end+1} = nexttile;
plot(mean(   dataX(:,q1Idx)-dataBaseX(:,q1Idx),2),'-w')
hold on
plot(mean(dataFit1X(:,q1Idx),2),'-c')
plot(mean(dataFit2X(:,q1Idx),2),'-g')
title([q1Label ' voxels (n=' num2str(nnz(q1Idx)) ')'])
legend('data minus fitted baseline','double gamma regressor','temporal derivative regressor','AutoUpdate','off')
xlabel('time (tr)');
ylabel('MR signal (a.u.)');
ax{end+1} = nexttile;
plot(mean(   dataX(:,q2Idx)-dataBaseX(:,q2Idx),2),'-w')
hold on
plot(mean(dataFit1X(:,q2Idx),2),'-c')
plot(mean(dataFit2X(:,q2Idx),2),'-g')
title([q2Label ' voxels (n=' num2str(nnz(q2Idx)) ')'])
xlabel('time (tr)');
ylabel('MR signal (a.u.)');
ax{end+1} = nexttile;
plot(mean(   dataX(:,q3Idx)-dataBaseX(:,q3Idx),2),'-w')
hold on
plot(mean(dataFit1X(:,q3Idx),2),'-c')
plot(mean(dataFit2X(:,q3Idx),2),'-g')
title([q3Label ' voxels (n=' num2str(nnz(q3Idx)) ')'])
xlabel('time (tr)');
ylabel('MR signal (a.u.)');
ax{end+1} = nexttile;
plot(mean(   dataX(:,q4Idx)-dataBaseX(:,q4Idx),2),'-w')
hold on
plot(mean(dataFit1X(:,q4Idx),2),'-c')
plot(mean(dataFit2X(:,q4Idx),2),'-g')
title([q4Label ' voxels (n=' num2str(nnz(q4Idx)) ')'])
xlabel('time (tr)');
ylabel('MR signal (a.u.)');
ax = [ax{:}];
set(ax,'YLim',[-1 1].*max(max(abs(cell2mat(get(ax,'YLim'))))));
ht.Title.String = ['sub-' num2str(s) '; ' num2str(length(mriData)) ' runs'];
drawnow;

% Add quadrant labels to scatter figure hFig{s}
xl = xlim(axScatter); yl = ylim(axScatter);
dx = diff(xl)*0.08; dy = diff(yl)*0.08;
text(axScatter, xl(1)+dx, yl(2)-dy, q1Label, 'VerticalAlignment','top');
text(axScatter, xl(2)-dx, yl(2)-dy, q2Label, 'HorizontalAlignment','right', 'VerticalAlignment','top');
text(axScatter, xl(1)+dx, yl(1)+dy, q3Label, 'VerticalAlignment','bottom');
text(axScatter, xl(2)-dx, yl(1)+dy, q4Label, 'HorizontalAlignment','right', 'VerticalAlignment','bottom');
drawnow;

saveas(hF,'adjustmentForSignedEstimateOfResponseAmplitude_dataFitVsData.fig','fig')
saveas(hFig{s},'adjustmentForSignedEstimateOfResponseAmplitude_responseScatter.fig','fig')


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


if 0
%%%%%%%%%%%%%%%%%%%%%%%
%% Quick replot for Jon
if 0
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
S = 1
roi{S}.(acq).(task).vessel = getVesselResp(roi{S}.(acq).(task).vessel);


tiling = plotUL3(roi{S}.(acq).(task).vessel,'base'     ,[100 1500],4);

hFol   = {}; hAol   = {}; hIol   = {};
hFresp = {}; hAresp = {}; hTresp = {};
[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'coef'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
adjPoly(hIol{end},'original','k',-1); adjPoly(hIol{end},'dilate1','w',1); hFol{end}.Name = 'coef thresholded';

[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respPeakVox',roi{S}.(acq).(task).vessel,tiling.sub.right.hA); hFresp{end}.Name = 'respArea';

figure('MenuBar','none','ToolBar','none');
plot(hAresp{2}(2).Children.XData,hAresp{2}(2).Children.YData)
xlabel('time (s)')
ylabel('MR signal')
title('sub1, artery 2, peak voxel response')
saveas(gcf,'sub1_art2_peakVoxResp','fig')

figure('MenuBar','none','ToolBar','none');
plot(hAresp{2}(2).Children.XData,hAresp{2}(7).Children.YData)
xlabel('time (s)')
ylabel('MR signal')
title('sub1, vein 1, peak voxel response')
saveas(gcf,'sub1_vein1_peakVoxResp','fig')
end
%% %%%%%%%%%%%%%%%%%%%%
end



if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% QA motion correction on vessels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
subIndList = [];
for S = 1:size(subList,1)
    if ~isfield(roi{S},acq) || ~isfield(roi{S}.(acq),task); continue; end
    subIndList(end+1) = S;
end

s = 1; % perferct all over
s = 2; % somewhate rigid movement mostly in the first and 2nd run
s = 3; % ok
s = 4; % minimal possibly non-rigid movement
s = 5; % some non-rigid movement particularly in one vessel on the left on the last run
s = 6; % ok
s = 7; % some movements, not clear if rigid
S=subIndList(s)
tiling = plotUL3(roi{S}.(acq).(task).vesselRegion,'base'     ,[100 1500],4);

fullTs = squeeze(cat(5,roi{S}.(acq).(task).vesselRegion.im.ts.im{:}));
COM = cat(1,roi{S}.(acq).(task).vesselRegion.com{:}); COM = COM - [roi{S}.(acq).(task).vesselRegion.cropXlim(1) roi{S}.(acq).(task).vesselRegion.cropYlim(1)] + 1;
for c = 1:size(COM,1)
    fullTs(round(COM(c,2)),round(COM(c,1)),:,:) = 0;
end
fullTs = uint8(fullTs./max(fullTs(:)).*255);
sz = size(fullTs); sz(3) = 1;
fullTs = cat(3,fullTs,repmat(uint8(128),sz));
earlyLateTs = fullTs(:,:,[1:20 end-20:end],:);

implay(earlyLateTs(:,:,:))
implay(fullTs(:,:,:))
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end



if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Prepare roi and rCond for re-preprocessing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
subIndList = [];
for S = 1:size(subList,1)
    if ~isfield(roi{S},acq) || ~isfield(roi{S}.(acq),task); continue; end
    subIndList(end+1) = S;
end
roi2 = cell(size(subIndList));
subList2 = cell(size(subIndList));
for S = 1:size(subIndList,2)
    roi2{S}.(acq).(task) = roi{subIndList(S)}.(acq).(task);
    roi2{S}.(acq).(task).rCond = rCond{subIndList(S)}.(acq).(task);
    subList2{S} = subList{subIndList(S)};
end
roi = roi2';
subList = subList2';
save dataPointers roi subList acq task
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end



if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Single-vessel responses
%%%%%%%%%%%%%%%%%%%%%%%%%%
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
subIndList = [];
for S = 1:size(subList,1)
    if ~isfield(roi{S},acq) || ~isfield(roi{S}.(acq),task); continue; end
    % vesselRun = repmat(roi{S}.(acq).(task).vessel,[1 2]);
    % for v = 1:size(vesselRun,1)
    %     for r = 1:size(roi{S}.(acq).(task).vessel(v).im.resp2,2)
    %         vesselRun(v,r).im.resp.im = roi{S}.(acq).(task).vessel(v).im.resp2.im{r};
    %     end
    % end
    % roi{S}.(acq).(task).vessel2 = getVesselResp(vesselRun);
    roi{S}.(acq).(task).vessel = getVesselResp(roi{S}.(acq).(task).vessel);
    subIndList(end+1) = S;
end

S=subIndList(3)
rCond{S}.(acq).(task).bhvr.percTruePositive

tiling = plotUL3(roi{S}.(acq).(task).vessel,'base'     ,[100 1500],4);
hFol   = {}; hAol   = {}; hIol   = {};
hFresp = {}; hAresp = {}; hTresp = {};
[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'roi_original'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'roi_tissue'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);

[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'coef'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
adjPoly(hIol{end},'original','k',-1); adjPoly(hIol{end},'dilate1','w',1); hFol{end}.Name = 'coef thresholded';
[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'coef_flat'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
adjPoly(hIol{end},'original','k',-1); adjPoly(hIol{end},'dilate1','w',1); hFol{end}.Name = 'coef';
% set(hAol{end},'CLim',[-1 1].*max(max(abs(cell2mat(get(hAol{end},'CLim'))))));

[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'svSpace_1'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
adjPoly(hIol{end},'original','k',-1); adjPoly(hIol{end},'dilate1','w',1); hFol{end}.Name = 'svSpace_1';
[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'svTime_1',roi{S}.(acq).(task).vessel,tiling.sub.right.hA); hFresp{end}.Name = 'svTime_1';
[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'svSpace_2'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
adjPoly(hIol{end},'original','k',-1); adjPoly(hIol{end},'dilate1','w',1); hFol{end}.Name = 'svSpace_2';
[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'svTime_2',roi{S}.(acq).(task).vessel,tiling.sub.right.hA); hFresp{end}.Name = 'svTime_2';

[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respArea',roi{S}.(acq).(task).vessel,tiling.sub.right.hA); hFresp{end}.Name = 'respArea';
[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respVel',roi{S}.(acq).(task).vessel,tiling.sub.right.hA); hFresp{end}.Name = 'respVel';

[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respSurVox',roi{S}.(acq).(task).vessel,tiling.sub.right.hA); hFresp{end}.Name = 'respSurVox';
[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respPeakVox',roi{S}.(acq).(task).vessel,tiling.sub.right.hA); hFresp{end}.Name = 'respPeakVox';


% [~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respPeakVox',roi{S}.(acq).(task).vessel2(:,1),tiling.sub.right.hA); hFresp{end}.Name = 'respPeakVox';
% [~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respPeakVox',roi{S}.(acq).(task).vessel2(:,2),tiling.sub.right.hA); hFresp{end}.Name = 'respPeakVox';
% [~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respSurVox',roi{S}.(acq).(task).vessel2(:,1),tiling.sub.right.hA); hFresp{end}.Name = 'respSurVox';
% [~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respSurVox',roi{S}.(acq).(task).vessel2(:,2),tiling.sub.right.hA); hFresp{end}.Name = 'respSurVox';


% threshOL(hIol,'actQ_dilate1',0);
threshOL(hIol{end},'off',0);




%% %%%%%%%%%%%%%%%%%%%%%%
end


if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Explore time series in transformed space (timeseries svd)
S=1;
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
R = rCond{S}.(acq).(task).volResp.mag.respCat.R;
dsgn = rCond{S}.(acq).(task).dsgn;
nFrame = rCond{S}.(acq).(task).nFrame;
tr = rCond{S}.(acq).(task).tr;
nDummy = rCond{S}.(acq).(task).nDummy;
fMat = rCond{S}.(acq).(task).volResp.mag.respCat.fMat;

% compute svd on ts
for vs = 1:length(roi{S}.(acq).(task).vessel)
    ts     = [];
    t      = [];
    onsets = [];
    for r = 1:length(roi{S}.(acq).(task).vessel(vs).im.ts.im)
        ts = cat(4,ts,...
        roi{S}.(acq).(task).vessel(vs).im.ts.im{r} - roi{S}.(acq).(task).vessel(vs).im.basePolyRun.im{r});
        t = cat(2,t,...
            (  (1:nFrame(r))+nDummy(r)-1  +  (nDummy(r)+nFrame(r))*(r-1)  )  .*  tr(r)   ...
        );
        onsets = cat(2,onsets,dsgn.onsetList + (nDummy(r)+nFrame(r))*(r-1) .* tr(r));
    end
    t      = permute(t,[2 1 3 4]);
    ts     = permute(ts,[4 1 2 3]);
    onsets = permute(onsets,[2 1 3 4]);
    [U,SS,V] = svd(ts(:,:),'econ','vector');
    V = reshape(permute(V,[2 1]),[size(V,2) size(ts,[2 3 4])]);
    U = permute(U,[2 1]);
    U = U.*SS;
    V = V.*SS;

    % fir
    cmdX = {src.afni}; cmdX{end+1} = ['1dcat ' char(fMat)]; [~,cmdout] = system(strjoin(cmdX,newline));
    mat = str2num(cmdout);
    % mat = mat ./ vecnorm(mat,1,1); % normalize each regressor to 1-norm = 1
    baseRegPerRun = (find(mat(end,:),1,'first')-1)./(R-1);
    baseReg = false(1,size(mat,2));
    baseReg(1,1:(baseRegPerRun*R)) = true;
    respReg = false(1,size(mat,2));
    respReg(1,(baseRegPerRun*R)+1:end) = true;

    % Regress mat onto U: each column of mat is a regressor, rows of mat correspond to rows of U
    % Solve for beta in U = beta * mat'
    beta = U / mat';

    for c = 1:5
        figure('WindowStyle','docked');
        ht = tiledlayout(5,3); ht.TileSpacing = 'compact'; ht.Padding = 'compact'; ax = {};

        ax{end+1} = nexttile([2 1]);
        plot(SS,'k'); ylabel('singular value');
        axis tight; hold on;
        xline(c,'r');

        ax{end+1} = nexttile([2 1]);
        cLim = [-1 1] * max(abs(V(1,:)));
        imagesc(squeeze(V(c,:,:)),cLim);
        axis image; ylabel(colorbar,'spatial singlular vector');
        ax{end}.YAxis.Visible = 'off'; ax{end}.XAxis.Visible = 'off'; colormap(ax{end},'jet');

        ax{end+1} = nexttile([2 1]);
        tt = (1:nnz(respReg)).*dsgn.dt;
        plot(tt,beta(c,respReg),'r');
        grid on; xlabel('post-onset time (s)'); ylabel('fitted MR signal'); axis tight;

        ax{end+1} = nexttile([1 3]);
        resid = U(c,:) - beta(c,:)*mat';
        plot(t,resid,'k'); axis tight; grid on;
        ylabel('residual');
        xline(onsets,'b');
        ax{end}.XTick = [];

        ax{end+1} = nexttile([2 3]);
        plot(t,U(c,:),'k'); axis tight;
        xlabel('time (s)'); ylabel('temporal singlular vector');
        xline(onsets,'b');
        hold on;
        plot(t,beta(c,baseReg)*mat(:,baseReg)',':r');
        plot(t,beta(c,:)*mat','r');

        er = sqrt(  resid.^2 * mat(:,respReg) ./ sum(mat(:,respReg),1)  )  ./  sqrt(sum(mat(:,respReg),1));
        errorbar(ax{3},tt,beta(c,respReg),er,'CapSize',0,'Color','r');
        axis(ax{3},'tight'); grid(ax{3},'on'); ax{3}.YLim = max(abs(ax{3}.YLim)) * [-1 1]; ax{3}.XLim = [0 tt(end)];
        xlabel(ax{3},'post-onset time (s)'); ylabel(ax{3},'fitted MR signal +/- sem');
        if c == 1
            yLim = ax{3}.YLim;
        else
            ax{3}.YLim = yLim;
        end

        title(ht,['component ' num2str(c) ' of ' [roi{S}.(acq).(task).vessel(vs).class ' ' num2str(roi{S}.(acq).(task).vessel(vs).id)]]);
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Explore time series in transformed space (area)
S=1;
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
roi{S}.(acq).(task).vessel = getVesselResp(roi{S}.(acq).(task).vessel);

R = rCond{S}.(acq).(task).volResp.mag.respCat.R;
dsgn = rCond{S}.(acq).(task).dsgn;
nFrame = rCond{S}.(acq).(task).nFrame;
tr = rCond{S}.(acq).(task).tr;
nDummy = rCond{S}.(acq).(task).nDummy;
fMat = rCond{S}.(acq).(task).volResp.mag.respCat.fMat;


roi{S}.(acq).(task).vessel = getVesselResp(roi{S}.(acq).(task).vessel);


for vs = 1:length(roi{S}.(acq).(task).vessel)
    
    roi{S}.(acq).(task).vessel(vs) = getVesselResp(roi{S}.(acq).(task).vessel(vs));

    resp = getVesselResp(roi{S}.(acq).(task).vessel(vs));
    roi{S}.(acq).(task).vessel(vs).resp = resp;
    % [Uresp,Vresp,AreaResp,VelResp,PeakVoxResp,SurrVoxResp] = getVesselResp(roi{S}.(acq).(task).vessel(vs));
    


    whos tt AreaResp VelResp AreaTsResp VelTsResp Uresp Vresp Vts UtsResp AreaTsResp VelTsResp respPeakVox respSurrVox
    
    figure('WindowStyle','docked');
    plot(tt,AreaResp);
    plot(tt,VelResp);
    plot(tt,AreaTsResp);
    plot(tt,VelTsResp);
    plot(tt,Uresp(1,:));
    imagesc(squeeze(Vresp(1,:,:)));
    imagesc(squeeze(UtsResp(1,:,:)));
    plot(tt,VtsResp(1,:));
    
    


    for c = 1:3
        figure('WindowStyle','docked');
        ht = tiledlayout(5,3); ht.TileSpacing = 'compact'; ht.Padding = 'compact'; ax = {};

        ax{end+1} = nexttile([2 1]);
        if c>2
            plot(SS,'k'); ylabel('singular value');
            axis tight; hold on;
            xline(c,'r');
        end

        ax{end+1} = nexttile([2 1]);
        if c>2
            cLim = [-1 1] * max(abs(Vts(1,:)));
            imagesc(squeeze(Vts(c,:,:)),cLim);
            axis image; ylabel(colorbar,'spatial singlular vector');
            ax{end}.YAxis.Visible = 'off'; ax{end}.XAxis.Visible = 'off'; colormap(ax{end},'jet');
        end

        ax{end+1} = nexttile([2 1]);
        tt = (1:nnz(respReg)).*dsgn.dt;
        plot(tt,betaAreaTs(c,respReg),'r');
        grid on; xlabel('post-onset time (s)'); ylabel('vessel area change (pixel)'); axis tight;

        ax{end+1} = nexttile([1 3]);
        resid = Uts(c,:) - betaUts(c,:)*mat';
        plot(t,resid,'k'); axis tight; grid on;
        ylabel('residual');
        xline(onsets,'b');
        ax{end}.XTick = [];

        ax{end+1} = nexttile([2 3]);
        plot(t,betaUts(c,:),'k'); axis tight;
        if c==1
            xlabel('time (s)'); ylabel('vessel area change');
        elseif c==2
            xlabel('time (s)'); ylabel('vessel velocity');
        else
            xlabel('time (s)'); ylabel('temporal singlular vector');
        end
        xline(onsets,'b');
        hold on;
        plot(t,betaUts(c,baseReg)*mat(:,baseReg)',':r');
        plot(t,betaUts(c,:)*mat','r');

        er = sqrt(  resid.^2 * mat(:,respReg) ./ sum(mat(:,respReg),1)  )  ./  sqrt(sum(mat(:,respReg),1));
        errorbar(ax{3},tt,betaUts(c,respReg),er,'CapSize',0,'Color','r');
        axis(ax{3},'tight'); grid(ax{3},'on'); ax{3}.YLim = max(abs(ax{3}.YLim)) * [-1 1]; ax{3}.XLim = [0 tt(end)];
        xlabel(ax{3},'post-onset time (s)'); ylabel(ax{3},'fitted MR signal +/- sem');
        % if c == 1
        %     yLim = ax{3}.YLim;
        % else
        %     ax{3}.YLim = yLim;
        % end

        if c==1
            title(ht,['vessel area']);
        elseif c==2
            title(ht,['vessel velocity']);
        else
            title(ht,['component ' num2str(c-2) ' of ' [roi{S}.(acq).(task).vessel(vs).class ' ' num2str(roi{S}.(acq).(task).vessel(vs).id)]]);
        end
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


if 0
%%%%%%%%%%%%%%%%%%%%%%%%%
%% Explore roi with phase
%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTES:
% - For vfMRIinflow, critical velocity is ~14.3cm/s (1.2mm slice thickness / 8.4ms TR)
% - For vfMRIpc, critical velocity is     ~18.2cm/s (1.2mm slice thickness / 6.593ms TR   OR   0.12cm / 0.006593s)

% S = 6;
% acq = 'vfMRI_dflt_none'; % vfMRIpc_dflt_pcVenc7ap 
% task = 'task_50sPrd10sDur';
S = 10;
task = 'task_50sPrd5sDur';
acqMag = 'vfMRI_dflt_none';
tilingMagInflow = plotUL3(roi{S}.(acqMag).(task).vessel,'base'     ,[100 1500],4);
[hFol,hAol,hIol] = plotOL( [],{'coef'},roi{S}.(acqMag).(task).vessel,tilingMagInflow.sub.right.hA);
% threshOL(hIol,'actQ_dilate1',0);
adjPoly(hIol,'original','k',-1);
adjPoly(hIol,'dilate1','w',1);
venc = 14;
acqPhs = ['vfMRIpc_dflt_pcVenc' num2str(venc) 'ap'];
tilingPhs      = plotUL3(roi{S}.(acqPhs).(task).vessel,'basePhase'     ,[]        ,4);
tilingPhs_tsAv = plotUL3(roi{S}.(acqPhs).(task).vessel,'basePhase_tsAv',[]        ,4);
tilingMag      = plotUL3(roi{S}.(acqPhs).(task).vessel,'base'     ,[100 1500],4);
[hFol,hAol,hIol] = plotOL( [],{'coef'},roi{S}.(acqPhs).(task).vessel,tilingMag.sub.right.hA);
vesselTmp = roi{S}.(acqPhs).(task).vessel;
for i = 1:length(vesselTmp)
    vesselTmp(i).im = [];
    vesselTmp(i).im.bckgrndMask = roi{S}.(acqPhs).(task).vessel(i).im.basePhase;
    vesselTmp(i).im.bckgrndMask.im = roi{S}.(acqPhs).(task).vessel(i).im.basePhase.bias.mask;
end
tilingBckgrndMask = plotUL3(vesselTmp,'bckgrndMask'     ,[],4);


pcMagBase        = cell(1,length(roi{S}.(acqPhs).(task).vessel));
pcPhsBase        = cell(1,length(roi{S}.(acqPhs).(task).vessel));
pcPhsBase_tsAv   = cell(1,length(roi{S}.(acqPhs).(task).vessel));
pcPhsWrapHigh    = cell(1,length(roi{S}.(acqPhs).(task).vessel));
pcPhsWrapLow     = cell(1,length(roi{S}.(acqPhs).(task).vessel));
pcPhsResp        = cell(1,length(roi{S}.(acqPhs).(task).vessel));
inflowMagBase    = cell(1,length(roi{S}.(acqMag).(task).vessel)); 
inflowMagResp    = cell(1,length(roi{S}.(acqMag).(task).vessel));
inflowMagActCoef = cell(1,length(roi{S}.(acqMag).(task).vessel));
inflowMagActP    = cell(1,length(roi{S}.(acqMag).(task).vessel));
for i = 1:length(roi{S}.(acqPhs).(task).vessel)
    pcMagBase{i}     = roi{S}.(acqPhs).(task).vessel(i).im.base.im;
    sz = [size(pcMagBase{i}) 1 size(roi{S}.(acqPhs).(task).vessel(i).im.resp.im,4)];
    pcPhsWrapHigh{i} = ones(sz) .* ( pi - roi{S}.(acqPhs).(task).vessel(i).im.basePhase.bias.offset);
    pcPhsWrapLow{i}  = ones(sz) .* (-pi - roi{S}.(acqPhs).(task).vessel(i).im.basePhase.bias.offset);
    pcPhsBase{i}     = roi{S}.(acqPhs).(task).vessel(i).im.basePhase.im - roi{S}.(acqPhs).(task).vessel(i).im.basePhase.bias.offset;
    pcPhsBase_tsAv{i} = roi{S}.(acqPhs).(task).vessel(i).im.basePhase_tsAv.im - roi{S}.(acqPhs).(task).vessel(i).im.basePhase.bias.offset;
    pcPhsResp{i}     = roi{S}.(acqPhs).(task).vessel(i).im.resp.im - roi{S}.(acqPhs).(task).vessel(i).im.resp.bias.offset;
    
    pcPhsWrapHigh{i} = pcPhsWrapHigh{i}/pi*venc;
    pcPhsWrapLow{i}  = pcPhsWrapLow{i}/pi*venc;
    pcPhsBase{i} = pcPhsBase{i}/pi*venc;
    pcPhsBase_tsAv{i} = pcPhsBase_tsAv{i}/pi*venc;
    pcPhsResp{i} = pcPhsResp{i}/pi*venc;
    
    inflowMagBase{i}    = roi{S}.(acqMag).(task).vessel(i).im.base.im;
    inflowMagResp{i}    = roi{S}.(acqMag).(task).vessel(i).im.resp.im;
    inflowMagActCoef{i} = roi{S}.(acqMag).(task).vessel(i).im.act.im;
    inflowMagActP{i}    = roi{S}.(acqMag).(task).vessel(i).im.actP.im;
end
pcMagBase        = tileImages(pcMagBase);
pcPhsBase        = tileImages(pcPhsBase);
pcPhsBase_tsAv   = tileImages(pcPhsBase_tsAv);
pcPhsWrapHigh    = tileImages(pcPhsWrapHigh);
pcPhsWrapLow     = tileImages(pcPhsWrapLow);
pcPhsResp        = tileImages(pcPhsResp);
inflowMagBase    = tileImages(inflowMagBase);
inflowMagResp    = tileImages(inflowMagResp);
inflowMagActCoef = tileImages(inflowMagActCoef);
inflowMagActP    = tileImages(inflowMagActP);

mri = MRIread(roi{S}.(acqPhs).(task).vessel(1).im.base.fName,1);
tempDir = fullfile(scratchDir,replace(workScript,'doIt_','')); mkdir(tempDir);
tempDir = fullfile(tempDir,['freeview_phsRoi_s' num2str(S) '_a' acqPhs '_t' task]); mkdir(tempDir);


fileList = {};
mri.vol = pcMagBase;
MRIwrite(mri,fullfile(tempDir,'pcMagBase.nii.gz'));
fileList{end+1} = fullfile(tempDir,'pcMagBase.nii.gz');
disp(fullfile(tempDir,'pcMagBase.nii.gz'));
mri.vol = pcPhsBase;
MRIwrite(mri,fullfile(tempDir,'pcPhsBase.nii.gz'));
fileList{end+1} = fullfile(tempDir,'pcPhsBase.nii.gz');
disp(fullfile(tempDir,'pcPhsBase.nii.gz'));
mri.vol = pcPhsBase_tsAv;
MRIwrite(mri,fullfile(tempDir,'pcPhsBase_tsAv.nii.gz'));
fileList{end+1} = fullfile(tempDir,'pcPhsBase_tsAv.nii.gz');
disp(fullfile(tempDir,'pcPhsBase_tsAv.nii.gz'));
mri.vol = pcPhsWrapHigh;
MRIwrite(mri,fullfile(tempDir,'pcPhsWrapHigh.nii.gz'));
fileList{end+1} = fullfile(tempDir,'pcPhsWrapHigh.nii.gz');
disp(fullfile(tempDir,'pcPhsWrapHigh.nii.gz'));
mri.vol = pcPhsWrapLow;
MRIwrite(mri,fullfile(tempDir,'pcPhsWrapLow.nii.gz'));
fileList{end+1} = fullfile(tempDir,'pcPhsWrapLow.nii.gz');
disp(fullfile(tempDir,'pcPhsWrapLow.nii.gz'));
mri.vol = pcPhsResp;
MRIwrite(mri,fullfile(tempDir,'pcPhsResp.nii.gz'));
fileList{end+1} = fullfile(tempDir,'pcPhsResp.nii.gz');
disp(fullfile(tempDir,'pcPhsResp.nii.gz'));
mri.vol = inflowMagBase;
MRIwrite(mri,fullfile(tempDir,'inflowMagBase.nii.gz'));
fileList{end+1} = fullfile(tempDir,'inflowMagBase.nii.gz');
disp(fullfile(tempDir,'inflowMagBase.nii.gz'));
mri.vol = inflowMagResp;
MRIwrite(mri,fullfile(tempDir,'inflowMagResp.nii.gz'));
fileList{end+1} = fullfile(tempDir,'inflowMagResp.nii.gz');
disp(fullfile(tempDir,'inflowMagResp.nii.gz'));
mri.vol = inflowMagActCoef;
MRIwrite(mri,fullfile(tempDir,'inflowMagActCoef.nii.gz'));
fileList{end+1} = fullfile(tempDir,'inflowMagActCoef.nii.gz');
disp(fullfile(tempDir,'inflowMagActCoef.nii.gz'));
mri.vol = inflowMagActP;
MRIwrite(mri,fullfile(tempDir,'inflowMagActP.nii.gz'));
fileList{end+1} = fullfile(tempDir,'inflowMagActP.nii.gz');
disp(fullfile(tempDir,'inflowMagActP.nii.gz'));

scratchDir2 = '/home/jovyan/scratch/Proulx-S/';
fileList = replace(fileList,scratchDir,scratchDir2);

cmd = [{'freeview'} fileList]
cmd = strjoin(cmd,[' \\' newline]);
cmd = [src.fs newline cmd];
cmdFile = fullfile(tempDir,['cmd.sh']);
fid = fopen(cmdFile,'w');
fprintf(fid,'%s\n',cmd);
fclose(fid);
disp(cmdFile);

return

% rCond{S}.vfMRIpc_dflt_pcVenc14ap.task_50sPrd5sDur.volResp.cmplxMag1.respCat.stats.fRespOnPoly0Base
memprage = rCond{S}.vfMRIpc_dflt_pcVenc14ap.task_50sPrd5sDur.volAnat.memprage(end);
memprage = fullfile(memprage.folder,memprage.name);
tof = rCond{S}.vfMRIpc_dflt_pcVenc14ap.task_50sPrd5sDur.volAnat.tof;
tof = fullfile(tof.folder,tof.name);
% pc = rCond{S}.vfMRIpc_dflt_pcVenc14ap.task_50sPrd5sDur.volResp.cmplxMag1.respRun.stats
pc = roi{S}.vfMRIpc_dflt_pcVenc14ap.task_50sPrd5sDur.vessel(1).im.basePhase_tsAv.fName;
%blood T1 @7T = 2.1s
% baseline parabolo
% wider parabola
% same parabola faster flow

replace(strjoin({pc tof memprage},[' \\' newline]),'users/','')


[~,hF,hA] = smrRoi2(rCond{S}.(acq).(task),{'respPhs_peakBasePhsInDilate1' },roi{S}.(acq).(task).vessel,tilingPhs.sub.right.hA);



for S = 1:size(subList,1)
    if (~isfield(rCond{S},'vfMRIpc_dflt_pcVenc7ap' ) || isempty(rCond{S}.vfMRIpc_dflt_pcVenc7ap)) ...
        && (~isfield(rCond{S},'vfMRIpc_dflt_pcVenc14ap') || isempty(rCond{S}.vfMRIpc_dflt_pcVenc14ap)) ...
        || isempty(roi{S}) ...
        continue; end
    for A = 1:length(acqList)
        acq = acqList{A};
        if ~isfield(rCond{S},acq) || isempty(rCond{S}.(acq)); continue; end
        if contains(acq,'bold'); continue; end
        for T = 1:length(taskList)
            task = taskList{T};
            if ~isfield(rCond{S}.(acq),task) || isempty(rCond{S}.(acq).(task)); continue; end
            tilingMag = plotUL3(roi{S}.(acq).(task).vessel,'base'     ,[100 1500],4);
        end
    end
end


%% %%%%%%%%%%%%%%%%%%%%%%
end




if 0
%%%%%%%%%%%%%%%%%%%%%%%%%
%% Explore maps with afni
%%%%%%%%%%%%%%%%%%%%%%%%%

% acq = 'bold_dflt_none';
acq = 'vfMRIpc_dflt_pcVenc7ap';  
fAfni = fullfile(storageDir,workScript); if ~exist(fAfni,'dir'); mkdir(fAfni); end
fAfni = fullfile(fAfni,'afni_vfMRIpc7ap.sh');
delete(fAfni);
fid = fopen(fAfni,'w');
for S = 1:size(subList,1)
    if ~isfield(rCond{S},acq); continue; end
    curTaskList = fields(rCond{S}.(acq)); curTaskList = curTaskList(contains(curTaskList,'task_'));
    curTaskList(contains(curTaskList,'fixOnly')) = [];
    for T = 1:length(curTaskList)
        cmd = {src.afni};
        cmd{end+1} = ['afni \'                                                                                                             ];
        cmd{end+1} = [        char(rCond{S}.(acq).(curTaskList{T}).volResp.mag.respCat.stats.fRespOnPoly0Base)                          ' \'];
        cmd{end+1} = [replace(char(rCond{S}.(acq).(curTaskList{T}).volResp.mag.respCat.fStat)                  ,'_stats','_stats+orig') ' \'];
        if isfield(rCond{S},acq)
        cmd{end+1} = [        char(rCond{S}.(acq).(curTaskList{T}).volResp.cmplxMag1.respCat.stats.fResp{3})                            ' \'];
        cmd{end+1} = [replace(char(rCond{S}.(acq).(curTaskList{T}).volResp.cmplxMag1.respCat.fStat)            ,'_stats','_stats+orig')     ];
        end
        

        nRun = size(rCond{S}.(acq).(curTaskList{T}).fPreprocList,1);
        fprintf(fid,'# Subject: %s, Task: %s, Number of runs: %d\n', subList{S}, curTaskList{T}, nRun);
        fprintf(fid,'%s\n\n',strjoin(cmd,newline));
    end
end
fclose(fid);
fAfni



% S = 10;
% disp(strjoin(...
% [rCond{S}.vfMRIpc_dflt_pcVenc14ap.task_50sPrd5sDur.volResp.mag.respRun.stats.fPoly0Base
% rCond{S}.vfMRIpc_dflt_pcVenc14ap.task_50sPrd5sDur.volResp.cmplxMag1.respRun.stats.fResp(:,:,3)
% rCond{S}.vfMRIpc_dflt_pcVenc14ap.task_50sPrd5sDur.volResp.cmplxMag1.respRun.stats.fPoly0Base(:,3)
% {[char(rCond{S}.vfMRIpc_dflt_pcVenc14ap.task_50sPrd5sDur.volResp.cmplxMag1.respRun.stats.fStat) '+orig']}],...
%     ' '))


% rCond{S}.vfMRIpc_dflt_pcVenc7ap.task_50sPrd5sDur.volResp.cmplxMag1.respRun

% rCond{S}.(acqList{1}).(taskList{1}).volResp.mag.respCat.xMat.nTrial'

%% %%%%%%%%%%%%%%%%%%%%%%
end


if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Time-frequency analysis -- of BOLD data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for S = 1:size(subList,1)
    acq  = 'bold_dflt_none'; if ~isfield(rCond{S},acq) || isempty(rCond{S}.(acq)); continue; end
    for T = 1:length(taskList)
        task = taskList{T}; if ~isfield(rCond{S}.(acq),task) || isempty(rCond{S}.(acq).(task)); continue; end
        disp('--------------------------------');
        disp('--------------------------------');
        disp(['SUB ' subList{S} ' ACQ ' acq ' TASK ' task]);
        disp('--------------------------------');
        disp('--------------------------------');

        % dir(fullfile(rCond{S}.(acq).(task).dirs.bidsDeriv,'acq-vfMRI_prsc-dflt','sub-vsmDrivenP1_ses-1_task-50sPrd5sDur_acq-vfMRIinflow_run-1_angio'))

        K   = [1 4 5]; % K(end)->full timeseries, K(1)->time-resolved, K(2)->trial-triggered based on missing data
        W   = [];
        win = [47.88/2 0.840]; % in seconds [lenght, step]
        skipSVD = 0;
        skipPSD = 0;
        dsgn    = rCond{S}.(acq).(task).dsgn;
        % fMask   = rCond{S}.(acq).(task).volAnat.label.calcarineVessel.f;
        mask    = char(rCond{S}.(acq).(task).volResp.mag.respCat.fMask);
        rCond{S}.(acq).(task) = runFullMT6(rCond{S}.(acq).(task),W,K,win,dsgn,mask,skipSVD,skipPSD);

% rCond_s1_bold = rCond{S}.(acq).(task);
% save rCond_s1_bold rCond_s1_bold -v7.3

        % figure('WindowStyle','docked');
        % f = squeeze(rCond{S}.(acq).(task).volMt.run(1).svd.f);
        % vec = squeeze(rCond{S}.(acq).(task).volMt.run(1).svd.COH(:,:,:,:,:,:,:,1));
        % plot(f,vec)

        % figure('WindowStyle','docked');
        % t = mean(squeeze(rCond{S}.(acq).(task).volMt.run(1).svdTrialGramMD.t - rCond{S}.(acq).(task).volMt.run(1).svdTrialGramMD.onsetList'),2);
        % t = permute(mean(t,1),[1 3 2]);
        % f = squeeze(rCond{S}.(acq).(task).volMt.run(1).svdTrialGramMD.f);
        % vec = squeeze(rCond{S}.(acq).(task).volMt.run(1).svdTrialGramMD.vec.cohEPC(:,:,:,:,:,:,:,1));
        % imagesc(t,f,vec)

        % figure('WindowStyle','docked');
        % mask = MRIread(mask); mask = logical(mask.vol);
        % spSVim = zeros(size(mask));
        % [~,b] = min(abs(rCond{S}.(acq).(task).volMt.run(1).svd.f - 0.0209));
        % spSVim(mask) = rCond{S}.(acq).(task).volMt.run(1).svd.spSV(:,:,:,:,b,:,:,1);
        % imagesc(abs(spSVim(:,:,1)))
        % axis image
        
        % figure('WindowStyle','docked');
        % imagesc(angle(spSVim))
        % colormap(hsv)
        % axis image

        % lims = axis;
        % axis(lims)

        

    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

if 0
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Time-frequency analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%
for S = 1:size(subList,1)
    for A = 1%:length(acqList)
        acq  = acqList{A}; if ~isfield(rCond{S},acq) || isempty(rCond{S}.(acq)); continue; end
        if contains(acq,{'bold'}); continue; end
        for T = 1%:length(taskList)
            task = taskList{T}; if ~isfield(rCond{S}.(acq),task) || isempty(rCond{S}.(acq).(task)); continue; end
            disp('--------------------------------');
            disp('--------------------------------');
            disp(['SUB ' subList{S} ' ACQ ' acq ' TASK ' task]);
            disp('--------------------------------');
            disp('--------------------------------');

            % dir(fullfile(rCond{S}.(acq).(task).dirs.bidsDeriv,'acq-vfMRI_prsc-dflt','sub-vsmDrivenP1_ses-1_task-50sPrd5sDur_acq-vfMRIinflow_run-1_angio'))

            K   = [1 4 5]; % K(end)->full timeseries, K(1)->time-resolved, K(2)->trial-triggered based on missing data
            W   = [];
            win = [47.88/2 0.840]; % in seconds [lenght, step]
            skipSVD = 1;
            skipPSD = 0;
            dsgn    = rCond{S}.(acq).(task).dsgn;
            % fMask   = rCond{S}.(acq).(task).volAnat.label.calcarineVessel.f;
            mask    = any(cat(4,roi{S}.(acq).(task).vessel.cropMask),4);
            rCond{S}.(acq).(task) = runFullMT6(rCond{S}.(acq).(task),W,K,win,dsgn,mask,skipSVD,skipPSD);


            % figure('WindowStyle','docked');
            % f = squeeze(rCond{S}.(acq).(task).volMt.run(1).svd.f);
            % vec = squeeze(rCond{S}.(acq).(task).volMt.run(1).svd.COH(:,:,:,:,:,:,:,1));
            % plot(f,vec)

            % figure('WindowStyle','docked');
            % t = mean(squeeze(rCond{S}.(acq).(task).volMt.run(1).svdTrialGramMD.t - rCond{S}.(acq).(task).volMt.run(1).svdTrialGramMD.onsetList'),2);
            % t = permute(mean(t,1),[1 3 2]);
            % f = squeeze(rCond{S}.(acq).(task).volMt.run(1).svdTrialGramMD.f);
            % vec = squeeze(rCond{S}.(acq).(task).volMt.run(1).svdTrialGramMD.vec.cohEPC(:,:,:,:,:,:,:,1));
            % imagesc(t,f,vec)

            % figure('WindowStyle','docked');
            % spSVim = zeros(size(mask));
            % [~,b] = min(abs(rCond{S}.(acq).(task).volMt.run(1).svd.f - 0.098));
            % spSVim(mask) = rCond{S}.(acq).(task).volMt.run(1).svd.spSV(:,:,:,:,b,:,:,1);
            % imagesc(abs(spSVim))
            % axis image
            
            % figure('WindowStyle','docked');
            % imagesc(angle(spSVim))
            % colormap(hsv)
            % axis image

            % lims = axis;
            % axis(lims)

            

        end
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%
end



if 0
%%%%%%%%%%%%%%%%%%%%%%%
%% Add mt to vessel roi
%%%%%%%%%%%%%%%%%%%%%%%
for S = 1:size(subList,1)
    disp(['adding mt to roi: ' subList{S}])
    for A = 1%:length(acqList)
        acq  = acqList{A};
        if ~isfield(rCond{S},acq)          ; continue; end
        if contains(acq,{'bold' 'vfMRIpc'}); continue; end
        for T = 1%:length(taskList)
            task = taskList{T};
            if ~isfield(rCond{S}.(acq),task) || isempty(rCond{S}.(acq).(task)); continue; end

            % add mt to vessel roi (computed on each run then averaged)
            roi{S}.(acq).(task).vessel = volPsd2roi(rCond{S}.(acq).(task).volMt.run,roi{S}.(acq).(task).vessel);

            % save rCond
            rCondOrig{S}.(acq).(task).volMt.run = rCond{S}.(acq).(task).volMt.run;
        end
    end
end
%% %%%%%%%%%%%%%%%%%%%%
end




% % summarize rois (vox2roi)
% vessels = roi{S}.(acq).(task).vessel;
% ismember({vessels.class},'artery')
% ismember({vessels.class},'vein')
% vessels.anot_actType
% vessels = {vessels(ismember({vessels.class},'artery')) vessels(ismember({vessels.class},'vein'))};
% roi{S}.(acq).(task).vessels = mergeRoi2(vessels);

if 0
%%%%%%%%%%%%%%%%
%% Summarize roi
%%%%%%%%%%%%%%%%


%%%
%%%
%%%
%%%
if 0
    S=1;
    dt      = rCond{S}.vfMRI_dflt_none.task_50sPrd5sDur.volResp.mag.actCat.param.dsgn.dt;
    dur     = mean(diff(rCond{S}.vfMRI_dflt_none.task_50sPrd5sDur.volResp.mag.actCat.param.dsgn.onsetList));
    stimDur = mean(rCond{S}.vfMRI_dflt_none.task_50sPrd5sDur.volResp.mag.actCat.param.dsgn.ondurList);

    dtt   = 0.1;
    ttDur = dur;
    ttN   = round(dur/dtt);
    tt    = linspace(0,dtt*(ttN-1),ttN);
    cmd = {src.afni};
    cmd{end+1} = ['3dDeconvolve -nodata ' num2str(ttN) ' ' num2str(dtt) ' \'];
    cmd{end+1} = '-polort -1 -num_stimts 1 \';
    cmd{end+1} = ['-stim_times 1 ''1D: 0'' ''SPMG2(' num2str(stimDur) ')'' \']; % one event at time 0, SPMG2 with stimDur-s boxcar
    cmd{end+1} = ['-x1D SPMG2.x1D -x1D_stop'];          % write design matrix, skip the (empty) solve
    system(strjoin(cmd,newline));
    spmg2 = readmatrix('SPMG2.x1D','FileType','text','CommentStyle','#'); % col1 = canonical HRF, col2 = temporal derivative
    figure
    plot(tt,spmg2); hold on
    plot(tt,sum(spmg2,2),'w');
    legend({'gamma' 'derivative' 'sum'})
    grid on;

    polyMask   = {};
    polyShape  = polyshape.empty;
    cropOrigin = {};
    actMask    = {};
    coefs1_adj = {};
    coefs1     = {};
    coefs2_adj = {};
    coefs2     = {};
    tsResp     = {};
    base       = {};
end
%%%
%%%
%%%
%%%




plotIt  = 1;
saveIt  = 0;
printIt = 0;
if plotIt
    close all
    figure('WindowStyle','docked');
    drawnow;
end
for S = 1:size(subList,1)
    for A = 1:length(acqList)
        acq  = acqList{A};
        if ~isfield(rCond{S},acq)          ; continue; end
        if contains(acq,{'bold' 'vfMRIpc'}); continue; end
        for T = 1:length(taskList)
            task = taskList{T};
            if ~strcmp(task,'task_50sPrd5sDur'); continue; end
            if ~isfield(rCond{S}.(acq),task); continue; end
            
            % plot vessel roi
            if plotIt
                tiling = plotUL3(roi{S}.(acq).(task).vessel,[],[],4);
                hF = {}; hA = {};
                [hFol,hAol,hIol] = plotOL( [],{'coef'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
% threshOL(hIol,'on');
% threshOL(hIol,'off');
% threshOL(hIol,'actQ_original',0);
threshOL(hIol,'actQ_dilate1',0);
% threshOL(hIol,'actQ_dilate1p5',0);
% threshOL(hIol,'actQ_dilate2',0);
% threshOL(hIol,'actQ_crop',0);

% adjPoly(hIol,'on');
% adjPoly(findobj([tiling.sub.right.hA.Children],'Type','image'),'original','k',-1);
% adjPoly(findobj([tiling.sub.right.hA.Children],'Type','image'),'dilate1','w',1);
adjPoly(hIol,'original','k',-1);
adjPoly(hIol,'dilate1','w',1);
% adjPoly(hIol,'dilate1p5','w',1);
% adjPoly(hIol,'dilate2','w',1);
                % [~,hF{end+1},hA{end+1}] = smrRoi(rCond{S}.(acq).(task),{'resp_dilate1_actQ_actSgn' },roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
                % [~,hF{end+1},hA{end+1}] = smrRoi(rCond{S}.(acq).(task),{'psd_dilate1_actQ'         },roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
                % [~,hF{end+1},hA{end+1}] = smrRoi(rCond{S}.(acq).(task),{'psdTrialGram_dilate1_actQ'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
                % [~,hF{end+1},hA{end+1}] = smrRoi2(rCond{S}.(acq).(task),{'resp_dilate1_actQ_actSgn' },roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
                % [~,hF{end+1},hA{end+1}] = smrRoi2(rCond{S}.(acq).(task),{'psd_dilate1_actQ'         },roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
                % [~,hF{end+1},hA{end+1}] = smrRoi2(rCond{S}.(acq).(task),{'psdTrialGram_dilate1_actQ'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
                % [~,hF{end+1},hA{end+1}] = smrRoi2(rCond{S}.(acq).(task),{'resp_original_actQ_actSgn' },roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
                % [~,hF{end+1},hA{end+1}] = smrRoi2(rCond{S}.(acq).(task),{'psd_original_actQ'         },roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
                % [~,hF{end+1},hA{end+1}] = smrRoi2(rCond{S}.(acq).(task),{'psdTrialGram_original_actQ'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);

                % [~,hF{end+1},hA{end+1}] = smrRoi2(rCond{S}.(acq).(task),{'coh_dilate1' 'cohTrialGram_dilate1'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
                
                
                if saveIt
                    saveas(tiling.main.hF,[subList{S},'_UL.fig']);
                    saveas(hFol,[subList{S},'_OL.fig']);
                    saveas(hF{1}{1},[subList{S},'_resp.fig']);
                    saveas(hF{2}{1},[subList{S},'_psd.fig']);
                    saveas(hF{3}{1},[subList{S},'_psdTrialGram.fig']);
                    saveas(hF{4}{1},[subList{S},'_coh.fig']);
                    saveas(hF{4}{2},[subList{S},'_cohTrialGram.fig']);
                    
                end
                if printIt
                    print(tiling.main.hF, [subList{S}, '_UL.svg'], '-dsvg', '-painters');
                    print(hFol, [subList{S}, '_OL.svg'], '-dsvg', '-painters');
                    print(hF{1}{1}, [subList{S}, '_resp.svg'], '-dsvg', '-painters');
                    print(hF{2}{1}, [subList{S}, '_psd.svg'], '-dsvg', '-painters');
                    print(hF{3}{1}, [subList{S}, '_psdTrialGram.svg'], '-dsvg', '-painters');
                    print(hF{4}{1}, [subList{S}, '_coh.svg'], '-dsvg', '-painters');
                    print(hF{4}{2}, [subList{S}, '_cohTrialGram.svg'], '-dsvg', '-painters');
                    hF = [hF{:}];
                    close([tiling.main.hF hFol hF{:}])
                end
            end



            %%%
            %%%
            %%%
            %%%
            if 0
                %%% compile for assessing coef validity %%%
                for v = 1:length(roi{S}.(acq).(task).vessel)
                    if ~strcmp(roi{S}.(acq).(task).vessel(v).class       ,'artery'         ); continue; end
                    if        ~roi{S}.(acq).(task).vessel(v).anot_sig                       ; continue; end
                    if ~strcmp(roi{S}.(acq).(task).vessel(v).anot_actType,'center-surround'); continue; end
                    
                    
                    sz = size(roi{S}.(acq).(task).vessel(v).polyMask{1});

                    polyShape(end+1) = roi{S}.(acq).(task).vessel(v).poly(ismember(roi{S}.(acq).(task).vessel(v).polyLabel,'dilate1'));
                    polyMask{end+1} = roi{S}.(acq).(task).vessel(v).polyMask{ismember(roi{S}.(acq).(task).vessel(v).polyLabel,'dilate1')};
                    actMask{end+1}  = false(sz);
                    vec = roi{S}.(acq).(task).vessel(v).im.actP.im(polyMask{end});
                    actMask{end}(polyMask{end}) = mafdr(vec,'BHFDR',true)<0.05;

                    coefs1_adj{end+1} = roi{S}.(acq).(task).vessel(v).im.act.im(:,:,:,1);
                    % coefs1_adj_vec{end+1}   = coefs1_adj{end}(actMask{end});
                    coefs2_adj{end+1} = roi{S}.(acq).(task).vessel(v).im.act.im(:,:,:,2);
                    % coefs2_adj_vec{end+1}   = coefs2_adj{end}(actMask{end});
                    
                    coefs1{end+1} = nan(sz);
                    coefs2{end+1} = nan(sz);
                    mri = MRIread(replace(roi{S}.(acq).(task).vessel(v).im.act.fName,'_coefsAdj.nii.gz','_coefs.nii.gz'));
                    tmp = permute(mri.vol,[4 1 2 3]);
                    coefs1{end}(:) = tmp(1,roi{S}.(acq).(task).vessel(v).cropMask);
                    coefs2{end}(:) = tmp(2,roi{S}.(acq).(task).vessel(v).cropMask);
                    [cropR,cropC] = find(roi{S}.(acq).(task).vessel(v).cropMask);
                    cropOrigin{end+1} = [min(cropR) min(cropC)]; % [row col] of crop top-left in full-image space
                    % coefs1_vec{end}(:) = coefs1{end}(1,roi{S}.(acq).(task).vessel(v).cropMask);
                    % coefs2{end}(:) = tmp(2,roi{S}.(acq).(task).vessel(v).cropMask);
                    % coefs1{end} = coefs1{end}(actMask{end});
                    % coefs2{end} = coefs2{end}(actMask{end});
                    
                    tsResp{end+1} = roi{S}.(acq).(task).vessel(v).im.resp.im;
                    % ts{end+1} = permute(roi{S}.(acq).(task).vessel(v).im.resp.im,[4 1 2 3]);
                    % ts{end}   = ts{end}(:,actMask{end})';
                    
                    base{end+1} = roi{S}.(acq).(task).vessel(v).im.base.im;



                    % figure;
                    % imA = sqrt(coefs1_adj.^2+coefs2_adj.^2);
                    % imB = sqrt(coefs1.^2    +coefs2.^2    );
                    % % imA = atan(coefs2_adj./coefs1_adj);
                    % % imB = atan(coefs2    ./coefs1    );
                    % cLim = [-1 1].*max(abs([imA(:) imB(:)]));
                    % subplot(1,2,1); imagesc(imA,cLim); axis image; title('imA'); colorbar
                    % subplot(1,2,2); imagesc(imB,cLim); axis image; title('imB'); colorbar



                    
                        
                        


                end
            end
            %%%
            %%%
            %%%
            %%%






            % get data
            % roi{S}.(acq).(task).vessel = smrRoi(rCond{S}.(acq).(task),{'resp_dilate1_actQ_actSgn'  'psd_dilate1_actQ'  'psdTrialGram_dilate1_actQ' },roi{S}.(acq).(task).vessel);
            % roi{S}.(acq).(task).vessel = smrRoi2(rCond{S}.(acq).(task),{'resp_original_actQ_actSgn' 'psd_original_actQ' 'psdTrialGram_original_actQ' 'resp_dilate1_actQ_actSgn'  'psd_dilate1_actQ'  'psdTrialGram_dilate1_actQ'},roi{S}.(acq).(task).vessel);
            % roi{S}.(acq).(task).vessel = smrRoi2(rCond{S}.(acq).(task),{'resp_dilate1_actQ_actSgn' 'psd_dilate1_actQ' 'psdTrialGram_dilate1_actQ' 'coh_dilate1' 'cohTrialGram_dilate1'},roi{S}.(acq).(task).vessel);
        end
    end
end



%%%%
%%%%
%%%%
%%%%
if 0
    return
    close all

    polyShape;
    polyMask;
    actMask;
    base;

    coefs1_adj_vec = cell(size(coefs1_adj));
    coefs2_adj_vec = cell(size(coefs2_adj));
    coefs1_vec = cell(size(coefs1));
    coefs2_vec = cell(size(coefs2));
    tsResp_vec = cell(size(tsResp));
    vv_vec     = cell(size(tsResp));
    vx_vec     = cell(size(tsResp));
    for v = 1:length(coefs1_adj)
        coefs1_adj_vec{v} = coefs1_adj{v}(actMask{v});
        coefs2_adj_vec{v} = coefs2_adj{v}(actMask{v});
        coefs1_vec{v}     = coefs1{v}(actMask{v});
        coefs2_vec{v}     = coefs2{v}(actMask{v});
        tmp = permute(tsResp{v},[4 1 2 3]);
        tsResp_vec{v}     = tmp(:,actMask{v})';
        vv_vec{v}         = repmat(v,[size(tsResp_vec{v},1) 1]);
        vx_vec{v}         = find(actMask{v});
    end


    coefs1_adj_vec = cat(1,coefs1_adj_vec{:});
    coefs1_vec     = cat(1,coefs1_vec{:}    );
    coefs2_adj_vec = cat(1,coefs2_adj_vec{:});
    coefs2_vec     = cat(1,coefs2_vec{:}    );
    tsResp_vec     = cat(1,tsResp_vec{:}    );
    vv_vec         = cat(1,vv_vec{:}        );
    vx_vec         = cat(1,vx_vec{:}        );

    tsFit1     = coefs1_vec.*spmg2(:,1)';
    tsFit2     = coefs2_vec.*spmg2(:,2)';
    tsFit      = tsFit1+tsFit2;

    t = linspace(0,dt*(size(tsResp_vec,2)-1),size(tsResp_vec,2));

    [~,b] = max(abs(tsFit),[],2);
    maxAmp = tsFit(sub2ind(size(tsFit),(1:size(tsFit,1))',b));

    % whos coefs* ts* tsFit* spmg2 maxAmp



    % i=8;
    i=29;
    % i=45;
    figure;
    hT = tiledlayout(1,3); hT.TileSpacing = 'compact'; hT.Padding = 'compact'; ax = {};
    ax{end+1} = nexttile;
    imagesc([1 size(tsFit,1)],[0 dtt*(ttN-1)],(tsFit./max(abs(tsFit),[],2))');
    colormap('jet'); axis square; colorbar
    hold on
    plot(dtt*(b-1),'o','MarkerFaceColor','w','MarkerEdgeColor','k');
    ax{end+1} = nexttile;
    plot(coefs1_adj_vec,maxAmp,'o','MarkerFaceColor','w','MarkerEdgeColor','k'); hold on
    xlabel('coefs1_adj'); ylabel('maxAmp');
    lim = [-1 1].*max(abs([coefs1_adj_vec(:); maxAmp(:)]));
    ylim(lim); xlim(lim);
    axis square
    grid on
    plot(ax{1},i,dtt*(b(i)-1),'o','MarkerFaceColor','m','MarkerEdgeColor','k');
    plot(ax{2},coefs1_adj_vec(i),maxAmp(i),'o','MarkerFaceColor','m','MarkerEdgeColor','k');
    xline(0,'w'); yline(0,'w');

    ax{end+1} = nexttile;
    plot(tt,tsFit1(i,:)); hold on
    plot(tt,tsFit2(i,:));
    plot(tt,tsFit(i,:),'w');
    plot(t,tsResp_vec(i,:),'--w');
    axis tight square
    xlabel('time (s)'); ylabel('MR signal');
    grid on
    legend('double-gamma','derivatives','sum','data');


    %%% Test svd
    [~,vx_baseMax] = max(base{vv_vec(i)}(:)); % global (linear) index of the max value in base
    % vx_cur = vx_vec(i);
    vx_cur = vx_baseMax;
    % curMask = true(sz);
    curMask = polyMask{vv_vec(i)};
    vxSel = find(find(curMask)==vx_cur); % full-grid linear idx vx_cur -> row in masked svd (U/V) space
    X = permute(tsResp{vv_vec(i)},[4 1 2 3]);
    [U,S,V] = svd(X(:,curMask),'econ'); % V: spatial singular vector, U: temporal singular vector
    % whos U S V
    % A = U*S*V'
    Sx = permute(diag(S),[2 3 1]);
    Vx = zeros([size(S,1) sz]);
    Vx(:,curMask) = permute(V,[2 1]);
    Vx = permute(Vx,[2 3 1]);
    Ux = permute(U,[1 3 2]); % U: temporal singular vector

    whos U  S  V
    whos Ux Sx Vx

    figure;
    hT = tiledlayout(3,5); hT.TileSpacing = 'compact'; hT.Padding = 'compact'; ax = {};
    ax{end+1} = nexttile;
    hIm = imagesc(base{vv_vec(i)}); hold on
    colormap(ax{end},'gray'); axis image
    ax{end}.XTick = []; ax{end}.YTick = [];
    polyRoi = translate(polyShape(vv_vec(i)),-(cropOrigin{vv_vec(i)}(2)-1),-(cropOrigin{vv_vec(i)}(1)-1)); % full-image -> roi (11x11) space: shift by -(col-1),-(row-1)
    hPoly = plot(polyRoi);
    hPoly.FaceColor = 'none'; hPoly.EdgeColor = 'r';


    ax{end+1} = nexttile;
    hIm = imagesc(coefs1{vv_vec(i)});
    ax{end}.CLim = [-1 1].*max(abs(ax{end}.CLim));
    colormap(ax{end},'jet'); ylabel(colorbar,'coefs1');
    axis image
    hold on
    [vxRow,vxCol] = ind2sub(size(coefs1{vv_vec(i)}),vx_cur); % linear voxel index -> image subscripts
    plot(vxCol,vxRow,'x','MarkerEdgeColor','k'); % mark voxel vx_cur
    hIm.AlphaData = actMask{vv_vec(i)}~=0; % hide non-significant voxels (mask==0) via transparency
    polyRoi = translate(polyShape(vv_vec(i)),-(cropOrigin{vv_vec(i)}(2)-1),-(cropOrigin{vv_vec(i)}(1)-1)); % full-image -> roi (11x11) space: shift by -(col-1),-(row-1)
    hPoly = plot(polyRoi);
    hPoly.FaceColor = 'none'; hPoly.EdgeColor = 0.5.*[1 1 1];
    title(num2str(coefs1{vv_vec(i)}(vx_cur)))
    ax{end}.YTick = []; ax{end}.XTick = [];

    ax{end+1} = nexttile;
    hIm = imagesc(coefs1_adj{vv_vec(i)});
    ax{end}.CLim = [-1 1].*max(abs(ax{end}.CLim));
    colormap(ax{end},'jet'); ylabel(colorbar,'coefs1_adj');
    axis image
    hold on
    [vxRow,vxCol] = ind2sub(size(coefs1{vv_vec(i)}),vx_cur); % linear voxel index -> image subscripts
    plot(vxCol,vxRow,'x','MarkerEdgeColor','k'); % mark voxel vx_cur
    hIm.AlphaData = actMask{vv_vec(i)}~=0; % hide non-significant voxels (mask==0) via transparency
    polyRoi = translate(polyShape(vv_vec(i)),-(cropOrigin{vv_vec(i)}(2)-1),-(cropOrigin{vv_vec(i)}(1)-1)); % full-image -> roi (11x11) space: shift by -(col-1),-(row-1)
    hPoly = plot(polyRoi);
    hPoly.FaceColor = 'none'; hPoly.EdgeColor = 0.5.*[1 1 1];
    title(num2str(coefs1_adj{vv_vec(i)}(vx_cur)))
    ax{end}.YTick = []; ax{end}.XTick = [];

    % coefs1_adj{vv_vec(i)}(vx_cur)
    % coefs1{vv_vec(i)}(vx_cur)
    % coefs1_vec(i)


    ax{end+1} = nexttile(6);
    plot(squeeze(Sx),'.-w'); axis square tight
    ylabel('singluar value');
    xlabel('component idx');


    cmpN = 2;
    for cmpIdx = 1:cmpN
        ax{end+1} = nexttile(6+cmpIdx);
        imagesc(Vx(:,:,cmpIdx)); hold on
        cLim = [-1 1].*max(abs(ax{end}.CLim));
        ax{end}.CLim = cLim;
        axis image; colormap(ax{end},'jet');
        ylabel(colorbar,['sv' num2str(cmpIdx)]);
        polyRoi = translate(polyShape(vv_vec(i)),-(cropOrigin{vv_vec(i)}(2)-1),-(cropOrigin{vv_vec(i)}(1)-1)); % full-image -> roi (11x11) space: shift by -(col-1),-(row-1)
        hPoly = plot(polyRoi);
        hPoly.FaceColor = 'none'; hPoly.EdgeColor = 0.5.*[1 1 1];
        [vxRow,vxCol] = ind2sub(size(coefs1{vv_vec(i)}),vx_cur); % linear voxel index -> image subscripts
        plot(vxCol,vxRow,'x','MarkerEdgeColor','k'); % mark voxel vx_cur
        tmp = Vx(:,:,cmpIdx);
        title(num2str(tmp(vx_cur)))
        ax{end}.YTick = []; ax{end}.XTick = [];
    end


    ax{end+1} = nexttile(11);
    % scl = reshape(Sx(1:cmpN),1,[]) .* reshape(mean(Vx(:,:,1:cmpN),[1 2]),1,[]); % sValue * mean(spatial sVector): component contribution to the space-mean response
    scl = reshape(Sx(1:cmpN),1,[])
    plot(t,squeeze(Ux(:,:,1:cmpN)).*scl)
    legend(arrayfun(@(c) sprintf('sVector %d',c),1:cmpN,'UniformOutput',false),'autoUpdate','off');
    grid on
    axis square tight

    % hold on
    % plot(t,tsResp_vec(i,:),'--w')
    % % tmp = permute(tsResp{vv_vec(i)},[4 1 2 3]);
    % % plot(t,tmp(:,vx_cur),'--m')


    ax{end+1} = nexttile([2 2]);
    cmpN = 2;
    for cmpIdx = 1:cmpN
        A = U(:,cmpIdx)*S(cmpIdx,cmpIdx)*V(vxSel,cmpIdx)';
        plot(t,A); hold on
    end
    A = U(:,1:cmpN)*S(1:cmpN,1:cmpN)*V(vxSel,1:cmpN)';
    plot(t,A,'w');
    tmp = permute(tsResp{vv_vec(i)},[4 1 2 3]);
    plot(t,tmp(:,vx_cur),'--w');
    axis tight square
    xlabel('time (s)'); ylabel('MR signal'); grid on
    % cmpIdx = 2;
    % A = U(:,1:cmpIdx)*S(1:cmpIdx,1:cmpIdx)*V(vxSel,1:cmpIdx)';
    % plot(t,A);
    V(vxSel,1:10)'.*squeeze(Sx(1:10))
end
%%%%
%%%%
%%%%
%%%%










if 0
metricList = {};
task = 'task_50sPrd5sDur';
for m = 1:length(roi{S}.(acq).(task).vessel(1).smr)
    metricList{m} = roi{S}.(acq).(task).vessel(1).smr{m}.metric;
end

save tmp -v7.3
return
load tmp

% grpAvPlt2(roi,subList,acq,task,'psdTrialGram_dilate1_actQ' ,'timeFreq','bNa15sec');
% grpAvPlt2(roi,subList,acq,task,'psdTrialGram_original_actQ','timeFreq','bNa15sec');

% grpAvPlt(roi,subList,acq,task,'psdTrialGram_dilate1_actQ' ,'freq','bNa15sec');
% grpAvPlt(roi,subList,acq,task,'psdTrialGram_original_actQ','freq','bNa15sec');


% grpAvPlt(roi,subList,acq,task,'resp_dilate1_actQ_actSgn');
% hFfull = grpAvPlt(roi,subList,acq,task,'psd_dilate1_actQ');
% grpAvPlt(roi,subList,acq,task,'psdTrialGram_dilate1_actQ','timeFreq','bNa15sec');
% hFmd = grpAvPlt(roi,subList,acq,task,'psdTrialGram_dilate1_actQ','freq','bNa15sec');

%          grpAvPlt2(roi,subList,acq,task,'resp_dilate1_actQ_actSgn' ,[]        ,[]        );
% hFfull = grpAvPlt2(roi,subList,acq,task,'psd_dilate1_actQ'         ,[]        ,[]        );
%          grpAvPlt2(roi,subList,acq,task,'psdTrialGram_dilate1_actQ','timeFreq','bNa15sec');
% hFmd   = grpAvPlt2(roi,subList,acq,task,'psdTrialGram_dilate1_actQ','freq'    ,'bNa15sec');

grpAvPlt2(roi,subList,acq,task,'resp_dilate1_actQ_actSgn' ,[]        ,[]        ,'avVox-catVes');

hFfull = grpAvPlt2(roi,subList,acq,task,'coh_dilate1'         ,[]        ,[]        ,'avVox-catVes');
         grpAvPlt2(roi,subList,acq,task,'cohTrialGram_dilate1','timeFreq','bNa15sec','avVox-catVes');
hFmd   = grpAvPlt2(roi,subList,acq,task,'cohTrialGram_dilate1','freq'    ,'bNa15sec','avVox-catVes');
grpAvRePlt(hFfull,hFmd)

hFfull = grpAvPlt2(roi,subList,acq,task,'psd_dilate1_actQ'         ,[]        ,[]        ,'avVox-catVes');
         grpAvPlt2(roi,subList,acq,task,'psdTrialGram_dilate1_actQ','timeFreq','bNa15sec','avVox-catVes');
hFmd   = grpAvPlt2(roi,subList,acq,task,'psdTrialGram_dilate1_actQ','freq'    ,'bNa15sec','avVox-catVes');
grpAvRePlt(hFfull,hFmd)
end
%% %%%%%%%%%%%%%
end







printIt = 1;   % figure export level: 0:none  1:png  2:png+fig  3:png+fig+svg+eps
intType = 'Qexact';   % right-axis timecourse: 'X'/'Y' fit intercept, or 'Qexact'/'Qaprx' = dQ/Q flow (exact / 1st-order)
intCI   = [];         % intercept right-axis range: central intCI%% of pooled values; 100 = full min-max; [] = auto
scatCI  = 100;         % scatter dD/D-dV/V half-range: central scatCI%% of pooled |values|; 100 or [] = full (max)
showLeg = false;       % false -> drop all dV/dD legends so data fills the panels in the png; true -> keep them
showTs  = true;        % true -> overlay the ts-based (windowed, faa-grid) dD/D, dV/V & dQ/Q as dotted lines on the resp-based timecourses
dN      = 0;
acq = 'vfMRI_dflt_none'; task = 'task_50sPrd5sDur';
dsgn = rCond{1}.(acq).(task).dsgn;
dtTs = mean(rCond{1}.(acq).(task).tr);
iStartStim = 0; % here 0 is the index of the ts frame that starts at stimulus onset
iEndStim   = iStartStim + round(mean(dsgn.ondurList)./dtTs-1)-1; % dsgn.ondurList is in real-valued (non-discretized) time, so -1 to get the frame that lasts until the stimulus offset time, and another -1 for the 0-index convention here
iStartStim = iStartStim+2; iEndStim = iEndStim+2; % +2 for physilogical delay
iStartPost = 24; % end of post-stim under/overshoot
iEndPost   = Inf;
%%%%%%%%
%% dV/dD
%%%%%%%%

for S = 1:size(subList,1)
    for A = 1:length(acqList)
        acq  = acqList{A};
        if ~isfield(rCond{S},acq)          ; continue; end
        if contains(acq,{'bold' 'vfMRIpc'}); continue; end
        for T = 1:length(taskList)
            task = taskList{T};
            if ~strcmp(task,'task_50sPrd5sDur'); continue; end
            if ~isfield(rCond{S}.(acq),task); continue; end

            %%% Extract area, diameter, velocity flow proxies
            roi{S}.(acq).(task).vessel = getAreaDiamVelFlowProxy(roi{S}.(acq).(task).vessel,'peakVox','dilate1p5',{'resp','ts'},0);
            %%% Compute Faa
            roi{S}.(acq).(task).vessel = getFaa(roi{S}.(acq).(task).vessel,rCond{S}.(acq).(task),dN);
            %%% ts-based windowed proxies (dX/X & dQ/Q on the faa grid) + faa2 (see getAreaDiamVelFlowFaaProxyFromTs)
            roi{S}.(acq).(task).vessel = getAreaDiamVelFlowFaaProxyFromTs(roi{S}.(acq).(task).vessel,rCond{S}.(acq).(task),dN);

        end
    end
end



% Extract relevant vessels
vessel = {};
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
for S = 1:size(subList,1)
    if ~isfield(roi{S},acq) || ~isfield(roi{S}.(acq),task); continue; end
    for v = 1:length(roi{S}.(acq).(task).vessel)
        if ~strcmp(roi{S}.(acq).(task).vessel(v).class       ,'artery'         ); continue; end
        if        ~roi{S}.(acq).(task).vessel(v).anot_sig                       ; continue; end
        if ~strcmp(roi{S}.(acq).(task).vessel(v).anot_actType,'center-surround'); continue; end
        vessel{end+1} = roi{S}.(acq).(task).vessel(v);
        vessel{end}.sId = subList{S};
    end
end
vessel = cat(1,vessel{:});


% design (onset list / stim duration) for this acq/task
dsgn = []; tsStartTime = [];
for S = 1:size(subList,1)
    if isfield(roi{S},acq) && isfield(roi{S}.(acq),task)
        dsgn = rCond{S}.(acq).(task).dsgn;
        % ts dummy-offset (s): time of the first preprocessed (dummy-removed) ts frame relative
        % to the full-ts 0s start. Set in the "Load preprocessed data" and "Get ROI data"
        % sections; required here (no fallback -- a stale checkpoint must fail loudly).
        if ~isfield(roi{S}.(acq).(task),'tsStartTime') || isempty(roi{S}.(acq).(task).tsStartTime)
            error('dVdD:noTsStartTime', ['roi{%d}.%s.%s.tsStartTime is missing/empty. It is set in the ' ...
                '"%% Load preprocessed data" and "%% Get ROI data" sections, which live inside the checkpoint ' ...
                'if-block -- a workScript_*.mat saved before this field existed does not carry it. ' ...
                'Regenerate the checkpoint so those sections run, then reload.'], S, acq, task);
        end
        tsStartTime = roi{S}.(acq).(task).tsStartTime;
        break
    end
end


% faa pre-, during- and post-stim windows, in TRUE onset-relative time points

% dtTs = mean(rCond{1}.vfMRI_dflt_none.task_50sPrd5sDur.tr);
% iStartStim = 0;          iEndStim = mean(dsgn.ondurList)./dtTs-1;
% iStartPost = iEndStim+1; iEndPost = Inf;

% pre-stim window: from the first ts frame (true onset-relative time of the run start,
% = -(onset - tsStartTime), the left edge of the faa timecourse) up to just before onset.
iStartPre  = round(-(dsgn.onsetList(1)-tsStartTime)./dtTs); iEndPre = -1;
% getFaa's getAlign places the onset marker at dsgn.onsetList on a 0-based ts grid, i.e. nDS
% frames LATE (the dummy-removed ts grid actually starts at tsStartTime). Shift the windows by
% -nDS so they still select the intended true-onset-relative periods relative to that marker.
nDS = round(tsStartTime./dtTs);
winStim = [iStartStim iEndStim] - nDS;
winPost = [iStartPost iEndPost] - nDS;   % Inf-nDS stays Inf (capped at the inter-onset bound in getFaa)
winPre  = [iStartPre  iEndPre]  - nDS;
vessel  = getFaa(vessel,[],winStim); % append during-stim faa to faa.res
vessel  = getFaa(vessel,[],winPost); % append post-stim  faa to faa.res
vessel  = getFaa(vessel,[],winPre);  % append pre-stim   faa to faa.res

% account for the ts dummy-offset for the getFaa path ONLY: getFaa's getAlign builds its grid
% on a 0-based ts grid (marker nDS frames late), so its onset-relative times are early by
% tsStartTime -- shift faa.res to true-onset time so the faa timecourse/markers align with the
% resp grid. (fromTs/faa2 come from indexTs2Trial, which now builds the grid at tsStartTime, so
% they are already true-onset-relative -- do NOT shift them. resp times are untouched.)
% See dXoX_resp_vs_ts_timeshift.md.
for v = 1:numel(vessel)
    for k = 1:numel(vessel(v).faa.res)
        vessel(v).faa.res(k).t      = vessel(v).faa.res(k).t      + tsStartTime;
        vessel(v).faa.res(k).tStart = vessel(v).faa.res(k).tStart + tsStartTime;
        vessel(v).faa.res(k).tEnd   = vessel(v).faa.res(k).tEnd   + tsStartTime;
    end
end



%%% Plot each vessel
ax1 = {}; ax2 = {}; ax4 = {}; ax5 = {}; axPre = {}; axQ = {};
dDoDc = {}; dVoVc = {}; dQoQec = {}; dQoQac = {}; tc = {};  % tile-1 response timecourse (+ dQ/Q exact & 1st-order)
TTc = {}; FFc = {}; IItc = {}; IIstim = {}; IIpost = {};    % faa timecourse + selected green timecourse & its during/post-window averages
fTSt = {}; fDoDc = {}; fVoVc = {}; fIItc = {};              % ts-based windowed dD/D, dV/V & selected green timecourse (faa grid; showTs)
fFAA2t = {}; fFAA2c = {};                                  % faa from getFaa2 (via indexTs2Trial) for the dotted faa-panel overlay (showTs)
FFall = {}; FFpre = {}; FFstim = {}; FFpost = {};% faa scalars
YIall = {}; YIpre = {}; YIstim = {}; YIpost = {};% scatter fit y-intercepts (dV/V at dD/D=0)
XIall = {}; XIpre = {}; XIstim = {}; XIpost = {};% scatter fit x-intercepts (dD/D at dV/V=0)
% scatter axis half-range (dD/D, dV/V): symmetric (x & y share scale so the
% slope/faa reads geometrically), set to the central scatCI% interval of the
% pooled |dD/D| & |dV/V| values -- same percentile strategy as intCI; clips outliers.
vSc = [];
for vv = 1:length(vessel)
    Vts = cat(1,vessel(vv).im.tsVel.vec{:});
    Dts = cat(1,vessel(vv).im.tsDiam.vec{:});
    dV  = (Vts - mean(Vts,2,'omitnan'))./mean(Vts,2,'omitnan');
    dD  = (Dts - mean(Dts,2,'omitnan'))./mean(Dts,2,'omitnan');
    vSc = [vSc; dV(:); dD(:)];
end
vSc = vSc(isfinite(vSc));
if isempty(scatCI); scatLim = max(abs(vSc)); else; scatLim = prctile(abs(vSc),scatCI); end
intCol  = [0.30 0.85 0.40];                       % right-axis intercept timecourse color
switch upper(intType)                             % select the right-axis timecourse (intType flag)
    case 'X';      intFld='xint'; intLbl='Xint (dD/D at dV/V=0)'; intPreLbl='Xint - Xint_{pre}'; intLeg='Xint';
    case 'Y';      intFld='yint'; intLbl='Yint (dV/V at dD/D=0)'; intPreLbl='Yint - Yint_{pre}'; intLeg='Yint';
    case 'QEXACT'; intFld='';     intLbl='dQ/Q (exact)';     intPreLbl='dQ/Q (exact) - pre';     intLeg='dQ/Q exact';
    case 'QAPRX';  intFld='';     intLbl='dQ/Q (1st-order)'; intPreLbl='dQ/Q (1st-order) - pre'; intLeg='dQ/Q approx';
    otherwise; error('intType must be ''X'', ''Y'', ''Qexact'' or ''Qaprx''');
end
isQ    = startsWith(upper(intType),'Q');  % any Q variant -> right axis shows the dQ/Q response timecourse
qExact = strcmpi(intType,'Qexact');       % exact (V*A) vs first-order (dV/V+dA/A) dQ/Q
for v = 1:length(vessel)
    res   = vessel(v).faa.res;
    kTc   = find(arrayfun(@(x) isscalar(x.dN)        ,res),1,'last'); % timecourse
    kStim = find(arrayfun(@(x) isequal(x.dN,winStim) ,res),1,'last');
    kPost = find(arrayfun(@(x) isequal(x.dN,winPost) ,res),1,'last');
    kPre  = find(arrayfun(@(x) isequal(x.dN,winPre)  ,res),1,'last');

    % tile-1 data: trial-averaged response dX/X & dQ/Q (folded into getAreaDiamVelFlowProxy;
    % resp baseline = first frame)
    dDoD  = vessel(v).im.respDoD.vec;
    dVoV  = vessel(v).im.respVoV.vec;
    dAoA  = vessel(v).im.respAoA.vec;
    dQoQe = vessel(v).im.respQoQe.vec;
    dQoQa = vessel(v).im.respQoQa.vec;
    if qExact; dQoQ = dQoQe; else; dQoQ = dQoQa; end   % the one selected for display (used when isQ)
    dt   = vessel(v).im.respArea.dt;
    t    = linspace(0,(numel(dDoD)-1)*dt,numel(dDoD));
    dDoDc{v,1} = dDoD; dVoVc{v,1} = dVoV; dQoQec{v,1} = dQoQe; dQoQac{v,1} = dQoQa; tc{v,1} = t;

    % tile-3 data: full ts fractional changes (folded into getAreaDiamVelFlowProxy;
    % ts baseline = per-run temporal mean), pooled across runs
    dVoVts = cat(1,vessel(v).im.tsVoV.vec{:});
    dDoDts = cat(1,vessel(v).im.tsDoD.vec{:});

    % during/post-stim time columns: same selection as getFaa's [n1 n2] window
    % (getIdx). The mask is over (trial x time); pooling all runs at those
    % columns reproduces the exact points used for the during/post-stim faa.
    align   = vessel(v).faa.align;
    isi     = -unique(diff(align.idxTrialOnset(:,1),[],1));     % inter-onset interval (pts)
    capStim = winStim; if isinf(capStim(2)); capStim(2) = isi-1; end
    capPost = winPost; if isinf(capPost(2)); capPost(2) = isi-1; end
    capPre  = winPre;  if isinf(capPre(2));  capPre(2)  = isi-1; end
    selCols  = @(w) align.idxRunOnset(align.idxTrialOnset>=w(1) & align.idxTrialOnset<=w(2));
    colsStim = selCols(capStim);
    colsPost = selCols(capPost);
    colsPre  = selCols(capPre);

    % faa values
    TTc{v,1}    = res(kTc).t;   FFc{v,1} = res(kTc).ts;
    if isQ; IItc{v,1} = dQoQ; else; IItc{v,1} = res(kTc).(intFld); end   % right-axis timecourse (intercept or dQ/Q)
    FFall{v,1}  = vessel(v).faa.all;
    FFpre{v,1}  = res(kPre).ts;
    FFstim{v,1} = res(kStim).ts;
    FFpost{v,1} = res(kPost).ts;

    % ts-based windowed timecourses on the faa grid (for the dotted showTs overlays).
    % dD/D & dV/V from fromTs; the green timecourse is dQ/Q (isQ) or the faa2 fit
    % intercept (X/Y), matching intType.
    fTSt{v,1}  = vessel(v).fromTs.t;
    fDoDc{v,1} = vessel(v).fromTs.DoD.mean;
    fVoVc{v,1} = vessel(v).fromTs.VoV.mean;
    kTc2 = find(arrayfun(@(x) isscalar(x.dN), vessel(v).faa2.res),1,'last');  % faa2 timecourse window set
    if isQ
        if qExact; fIItc{v,1} = vessel(v).fromTs.QoQe.mean; else; fIItc{v,1} = vessel(v).fromTs.QoQa.mean; end
    elseif strcmpi(intType,'Y'); fIItc{v,1} = vessel(v).faa2.res(kTc2).yint;
    else;                        fIItc{v,1} = vessel(v).faa2.res(kTc2).xint;
    end
    % faa from getFaa2 (indexTs2Trial source grid, already true-onset) for the dotted overlay
    fFAA2t{v,1} = vessel(v).faa2.res(kTc2).t;
    fFAA2c{v,1} = vessel(v).faa2.res(kTc2).ts;

    % scatter-fit intercepts (variables of interest, parallel to faa)
    YIall{v,1}  = vessel(v).faa.allYint; XIall{v,1}  = vessel(v).faa.allXint;
    YIpre{v,1}  = res(kPre).yint;        XIpre{v,1}  = res(kPre).xint;
    YIstim{v,1} = res(kStim).yint;       XIstim{v,1} = res(kStim).xint;
    YIpost{v,1} = res(kPost).yint;       XIpost{v,1} = res(kPost).xint;

    nRun   = size(dVoVts,1);
    nTrial = nRun.*length(dsgn.onsetList);

    figs(v) = figure; ht = tiledlayout(3,3); ht.Padding = 'compact'; ht.TileSpacing = 'compact';
    % title(ht,'subjId=' + string(vessel(v).sId) + '; vesselId=' + string(vessel(v).id) + ...
            %   '; Ntrials=' + string(nTrial) + '; Nrun=' + string(nRun))

    % dD/D and dV/V timecourse
    ax1{end+1} = nexttile; hold on
    hP1 = plot(t,dDoD,'c-');
    hP2 = plot(t,dVoV,'y-');
    if showTs   % ts-based (windowed, faa-grid) dD/D & dV/V as dotted lines of matching color
        plot(fTSt{v,1},fDoDc{v,1},'c:');
        plot(fTSt{v,1},fVoVc{v,1},'y:');
    end
    ylabel('dX/X'); xlabel('post stim onset time (s)')
    grid on; axis tight
    yLim = ylim; yLim = [-1 1].*max(abs(yLim)); ylim(yLim);
    axis square
    hP3 = patch([0 1 1 0].*mean(dsgn.ondurList), [1 1 1 1].*yLim(1) + [0 0 0.025 0.025].*range(yLim), 0.5.*[1 1 1], 'EdgeColor','none');
    legend([hP1 hP2 hP3],{'dD/D','dV/V','stimulus duration'},'Location','northeast')

    % faa timecourse (single axis; bottom-left). The green dQ/Q timecourse has its own panel.
    ax2{end+1} = nexttile(7); hold on
    hP1 = plot(TTc{v,1},FFc{v,1},'w-'); axis tight square
    if showTs; plot(fFAA2t{v,1},fFAA2c{v,1},'w:'); end   % faa from getFaa2 (ts source grid), dotted -- match check vs getFaa
    dtTs = vessel(v).faa.align.dt; dNtc = res(kTc).dN;
    winLbl = [num2str((dNtc*2+1)*dtTs,3) '-sec sliding window'];   % window annotation (folded into ylabel; was a title)
    ylabel(['faa (' winLbl ')']); xlabel('post stim onset time (s)')
    ax1{end}.XLim = xlim; grid on
    % faa pre/during/post stim, magenta error bars (single vessel -> no vertical SEM;
    % horizontal error bar spans the window).
    tPre  = [res(kPre).tStart  res(kPre).tEnd+dtTs];
    hB0 = errorbar(mean(tPre),FFpre{v,1},0,0,range(tPre)/2,range(tPre)/2,'mo','CapSize',0);
    hB0.MarkerFaceColor = hB0.MarkerEdgeColor;
    tStim = [res(kStim).tStart res(kStim).tEnd+dtTs];
    hB1 = errorbar(mean(tStim),FFstim{v,1},0,0,range(tStim)/2,range(tStim)/2,'mo','CapSize',0);
    hB1.MarkerFaceColor = hB1.MarkerEdgeColor;
    tPost = [res(kPost).tStart res(kPost).tEnd];
    hB2 = errorbar(mean(tPost),FFpost{v,1},0,0,range(tPost)/2,range(tPost)/2,'mo','CapSize',0);
    hB2.MarkerFaceColor = hB2.MarkerEdgeColor;
    % during/post-stim averages of the green timecourse (dQ/Q or selected intercept) over the
    % same time windows as the faa markers -- feeds the green-panel markers & dQ/Q categorical.
    % dQ/Q has no pre-stim window (response grid), so only during/post are defined here.
    gGrid = TTc{v,1}; if isQ; gGrid = t; end
    IIstim{v,1} = mean(IItc{v,1}(gGrid>=tStim(1) & gGrid<=tStim(2)),'omitnan');
    IIpost{v,1} = mean(IItc{v,1}(gGrid>=tPost(1) & gGrid<=tPost(2)),'omitnan');

    % green response timecourse (dQ/Q, or the selected fit intercept) -- its own panel (mid-left)
    axQ{end+1} = nexttile(4); hold on
    if isQ; plot(t,dQoQ,'-','Color',intCol);
    else;   plot(TTc{v,1},res(kTc).(intFld),'-','Color',intCol); end
    if showTs; plot(fTSt{v,1},fIItc{v,1},':','Color',intCol); end   % ts-based (windowed, faa-grid) dotted overlay
    if isQ; ylabel(intLbl); else; ylabel([intLbl ' (' winLbl ')']); end   % X/Y intercept is windowed; dQ/Q is not
    xlabel('post stim onset time (s)')
    grid on; axis square; xlim(ax1{end}.XLim)

    % faa using pre-stim time points only (same points as the faa-panel pre-stim marker)
    axPre{end+1} = nexttile(2); hold on
    Xs = dDoDts(:,colsPre); Ys = dVoVts(:,colsPre);
    hP1 = scatter(Xs(:),Ys(:),'filled','o','MarkerFaceColor','w','MarkerEdgeColor','none');
    alpha(hP1,0.1); axis square
    lim = [-1 1].*max(abs([Xs(:); Ys(:)]));
    xlim(lim); ylim(lim); grid minor
    xlabel('dD/D (pre stim)'); ylabel('dV/V (pre stim)')
    ok   = ~isnan(Xs) & ~isnan(Ys);
    fit1 = fit(Xs(ok),Ys(ok),'poly1'); % intercept + slope, as in getFaa
    X    = [min([Xs(ok);0;XIpre{v,1}]) max([Xs(ok);0;XIpre{v,1}])];
    hFit = plot(axPre{end},X,fit1(X),'r-');
    plot(axPre{end},[0 -scatLim],[1 1].*YIpre{v,1},'r--'); % Y-intercept -> dV/V axis (dV/V at dD/D=0)
    plot(axPre{end},[1 1].*XIpre{v,1},[0 -scatLim],'r--'); % X-intercept -> dD/D axis (dD/D at dV/V=0)
    legend([hP1 hFit],'pre-stim tPts','faa = ' + string(FFpre{v,1}),'Location','northeast')

    % faa using during-stim time points only (same points as the faa-panel during-stim marker)
    ax4{end+1} = nexttile(5); hold on
    Xs = dDoDts(:,colsStim); Ys = dVoVts(:,colsStim);
    hP1 = scatter(Xs(:),Ys(:),'filled','o','MarkerFaceColor','w','MarkerEdgeColor','none');
    alpha(hP1,0.1); axis square
    lim = [-1 1].*max(abs([Xs(:); Ys(:)]));
    xlim(lim); ylim(lim); grid minor
    xlabel('dD/D (during stim)'); ylabel('dV/V (during stim)')
    ok   = ~isnan(Xs) & ~isnan(Ys);
    fit1 = fit(Xs(ok),Ys(ok),'poly1'); % intercept + slope, as in getFaa
    X    = [min([Xs(ok);0;XIstim{v,1}]) max([Xs(ok);0;XIstim{v,1}])];
    hFit = plot(ax4{end},X,fit1(X),'r-');
    plot(ax4{end},[0 -scatLim],[1 1].*YIstim{v,1},'r--'); % Y-intercept -> dV/V axis (dV/V at dD/D=0)
    plot(ax4{end},[1 1].*XIstim{v,1},[0 -scatLim],'r--'); % X-intercept -> dD/D axis (dD/D at dV/V=0)
    legend([hP1 hFit],'during-stim tPts','faa = ' + string(FFstim{v,1}),'Location','northeast')

    % faa using post-stim time points only (same points as the faa-panel post-stim marker)
    ax5{end+1} = nexttile(8); hold on
    Xs = dDoDts(:,colsPost); Ys = dVoVts(:,colsPost);
    hP1 = scatter(Xs(:),Ys(:),'filled','o','MarkerFaceColor','w','MarkerEdgeColor','none');
    alpha(hP1,0.1); axis square
    lim = [-1 1].*max(abs([Xs(:); Ys(:)]));
    xlim(lim); ylim(lim); grid minor
    xlabel('dD/D (post stim)'); ylabel('dV/V (post stim)')
    ok   = ~isnan(Xs) & ~isnan(Ys);
    fit1 = fit(Xs(ok),Ys(ok),'poly1'); % intercept + slope, as in getFaa
    X    = [min([Xs(ok);0;XIpost{v,1}]) max([Xs(ok);0;XIpost{v,1}])];
    hFit = plot(ax5{end},X,fit1(X),'r-');
    plot(ax5{end},[0 -scatLim],[1 1].*YIpost{v,1},'r--'); % Y-intercept -> dV/V axis (dV/V at dD/D=0)
    plot(ax5{end},[1 1].*XIpost{v,1},[0 -scatLim],'r--'); % X-intercept -> dD/D axis (dD/D at dV/V=0)
    legend([hP1 hFit],'post-stim tPts','faa = ' + string(FFpost{v,1}),'Location','northeast')
end
dDoD   = cat(1,dDoDc{:}); dVoV = cat(1,dVoVc{:}); t = cat(1,tc{:});
dQoQe  = cat(1,dQoQec{:}); dQoQa = cat(1,dQoQac{:});   % both flow-change variants (variables of interest)
TT     = cat(1,TTc{:});   FF   = cat(1,FFc{:});   IItc = cat(1,IItc{:});
IIstim = cat(1,IIstim{:}); IIpost = cat(1,IIpost{:});   % per-vessel during/post green-window averages
RTt    = TT(1,:); if isQ; RTt = t(1,:); end   % right-axis timecourse grid (faa grid, or response grid for dQ/Q)
fTSg   = fTSt{1}; fDoD = cat(1,fDoDc{:}); fVoV = cat(1,fVoVc{:}); fIIm = cat(1,fIItc{:});  % ts-based windowed (faa grid)
fFAA2g = fFAA2t{1}; fFAA2 = cat(1,fFAA2c{:});   % faa from getFaa2 (for the dotted faa-panel overlay)
FFall  = cat(1,FFall{:});
FFpre  = cat(1,FFpre{:});
FFstim = cat(1,FFstim{:});
FFpost = cat(1,FFpost{:});
YIall  = cat(1,YIall{:});  XIall  = cat(1,XIall{:});
YIpre  = cat(1,YIpre{:});  XIpre  = cat(1,XIpre{:});
YIstim = cat(1,YIstim{:}); XIstim = cat(1,XIstim{:});
YIpost = cat(1,YIpost{:}); XIpost = cat(1,XIpost{:});
% pre-stim value of the green variable (for the pre-stim-normalized panel). dQ/Q is
% already baseline-relative (no pre-stim window on the response grid), so its pre value is 0.
if isQ; IIpre = zeros(numel(vessel),1); elseif strcmpi(intType,'Y'); IIpre = YIpre; else; IIpre = XIpre; end
% y-ranges for the raw (intYLim) and pre-normalized (intYLimN) green panels = central intCI%
% interval of the pooled values (clips blow-ups). intCI=100 -> exact [min max]; intCI=[] -> auto.
if isempty(intCI)
    intYLim = []; intYLimN = [];
else
    pcII = [(100-intCI)/2  100-(100-intCI)/2];
    vII  = IItc(isfinite(IItc));                       intYLim  = prctile(vII ,pcII);
    vIIn = IItc - IIpre; vIIn = vIIn(isfinite(vIIn));  intYLimN = prctile(vIIn,pcII);
end

% Harmonize across vessels
ax1 = [ax1{:}]; ax2 = [ax2{:}]; ax4 = [ax4{:}]; ax5 = [ax5{:}]; axPre = [axPre{:}]; axQ = [axQ{:}];
yLim = get(ax1,'YLim'); yLim = [-1 1].*max(abs([yLim{:}])); set(ax1,'YLim',yLim);
% faa (ax2) -> common range across vessels
yLim = get(ax2,'YLim'); yLim = cat(1,yLim{:}); yLim = [min(yLim(:,1)) max(yLim(:,2))]; set(ax2,'YLim',yLim);
% green dQ/Q (or intercept) panel (axQ) -> intCI percentile range, else common range
if ~isempty(intYLim)
    set(axQ,'YLim',intYLim);
else
    yLimQ = get(axQ,'YLim'); yLimQ = cat(1,yLimQ{:}); set(axQ,'YLim',[min(yLimQ(:,1)) max(yLimQ(:,2))]);
end
set([ax4 ax5 axPre],'YLim',[-1 1].*scatLim,'XLim',[-1 1].*scatLim);
% salient white x=0 / y=0 lines (more opaque + thicker than the grid)
for axsc = [ax4 ax5 axPre]
    xline(axsc,0,'w-','LineWidth',1,'Alpha',0.7,'HandleVisibility','off');
    yline(axsc,0,'w-','LineWidth',1,'Alpha',0.7,'HandleVisibility','off');
end
% stim-duration patch at the bottom of each timecourse panel (dX/X, faa, dQ/Q)
for i = 1:length(ax1)
    hP = findobj(ax1(i).Children,'Type','patch');
    yLim = ax1(i).YLim;
    hP.Vertices = [[0 1 1 0]'.*mean(dsgn.ondurList) ([1 1 1 1].*yLim(1) + [0 0 0.025 0.025].*range(yLim))'];
    for ax = [ax2(i) axQ(i)]
        yLim = ax.YLim;
        patch(ax,[0 1 1 0].*mean(dsgn.ondurList), [1 1 1 1].*yLim(1) + [0 0 0.025 0.025].*range(yLim), 0.5.*[1 1 1], 'EdgeColor','none');
    end
end



%%% Summary across vessels
figs(end+1) = figure; ht = tiledlayout(3,3); ht.Padding = 'compact'; ht.TileSpacing = 'compact';
title(ht,'summary across vessels (N=' + string(size(dDoD,1)) + ' vessels)')

ax11 = nexttile(1); hold on
hP1 = shplot(t(1,:),mean(dDoD,1),std(dDoD,[],1)./sqrt(size(dDoD,1)));
delete([hP1.upper hP1.lower]);
hP1.line.Color = 'c'; hP1.patch.FaceColor = 'c'; hP1.patch.FaceAlpha = 0.25; hP1.patch.EdgeColor = 'none';
hP2 = shplot(t(1,:),mean(dVoV,1),std(dVoV,[],1)./sqrt(size(dVoV,1)));
delete([hP2.upper hP2.lower]);
hP2.line.Color = 'y'; hP2.patch.FaceColor = 'y'; hP2.patch.FaceAlpha = 0.25; hP2.patch.EdgeColor = 'none';
if showTs   % ts-based (windowed, faa-grid) dD/D & dV/V means as dotted lines
    plot(fTSg,mean(fDoD,1),'c:');
    plot(fTSg,mean(fVoV,1),'y:');
end
ylabel('dX/X'); xlabel('post stim onset time (s)')
grid on; axis tight
yLim = ylim; yLim = [-1 1].*max(abs(yLim)); ylim(yLim);
axis square
hP3 = patch([0 1 1 0].*mean(dsgn.ondurList), [1 1 1 1].*yLim(1) + [0 0 0.025 0.025].*range(yLim), 0.5.*[1 1 1], 'EdgeColor','none');
legend([hP1.line hP2.line hP3],{'dD/D','dV/V','stimulus duration'},'Location','northeast')

ax22 = nexttile(7); hold on   % faa timecourse (single axis): bottom-left
hP1 = shplot(TT(1,:),mean(FF,1),std(FF,[],1)./sqrt(size(FF,1)));
delete([hP1.upper hP1.lower]);
hP1.line.Color = 'w'; hP1.patch.FaceColor = 'w'; hP1.patch.FaceAlpha = 0.25; hP1.patch.EdgeColor = 'none';
if showTs; plot(fFAA2g,mean(fFAA2,1),'w:'); end   % faa from getFaa2 (ts source grid) mean, dotted -- match check vs getFaa
ylabel(['faa (' winLbl ')']); xlabel('post stim onset time (s)')
grid on;
yLim = ylim;
patch([0 1 1 0].*mean(dsgn.ondurList), [1 1 1 1].*yLim(1) + [0 0 0.025 0.025].*range(yLim), 0.5.*[1 1 1], 'EdgeColor','none');
axis square tight
ax11.XLim = xlim;
tPre = [vessel(1).faa.res(kPre).tStart vessel(1).faa.res(kPre).tEnd+dtTs];
hB = errorbar(mean(tPre),mean(FFpre),std(FFpre)./sqrt(length(FFpre)),std(FFpre)./sqrt(length(FFpre)),range(tPre)/2,range(tPre)/2,'mo','CapSize',0);
hB.MarkerFaceColor = hB.MarkerEdgeColor;
tStim = [vessel(1).faa.res(kStim).tStart vessel(1).faa.res(kStim).tEnd+dtTs];
hB = errorbar(mean(tStim),mean(FFstim),std(FFstim)./sqrt(length(FFstim)),std(FFstim)./sqrt(length(FFstim)),range(tStim)/2,range(tStim)/2,'mo','CapSize',0);
hB.MarkerFaceColor = hB.MarkerEdgeColor;
tPost = [vessel(1).faa.res(kPost).tStart vessel(1).faa.res(kPost).tEnd];
hB = errorbar(mean(tPost),mean(FFpost),std(FFpost)./sqrt(length(FFpost)),std(FFpost)./sqrt(length(FFpost)),range(tPost)/2,range(tPost)/2,'mo','CapSize',0);
hB.MarkerFaceColor = hB.MarkerEdgeColor;

ax33 = nexttile(9); hold on   % faa during-vs-post categorical: bottom-right
Y = [FFall FFpre FFstim FFpost];
% all data -> pre stim drawn dotted ('all data' is the pooled fit, not part of
% the pre/during/post temporal sequence); pre -> during -> post solid.
plot(1:2,Y(:,1:2)','w','LineStyle',':','Marker','.');
plot(2:4,Y(:,2:4)','w','LineStyle','-','Marker','.');
axis square
set(gca,'XTick',1:4,'XTickLabel',{'all data','pre stim','during stim','post stim'})
ylabel('faa'); xlim([0.5 4.5])
ax33.YGrid = 'on';
[h,p,ci,stats] = ttest(FFstim,FFpost);
fprintf('[dV/dD stats] faa during vs. post stim: p=%g; t=%g\n',p,stats.tstat)   % pushed off the panel title to terminal

%%% Pre-stim-normalized faa timecourse (bottom-middle): each vessel's faa minus its
%%% own pre-stim window value (FFpre), then mean +/- SEM
ax44  = nexttile(8); hold on
FFn   = FF - FFpre;     % faa timecourse - pre-stim faa (per-vessel, implicit expansion)
hP1 = shplot(TT(1,:),mean(FFn,1),std(FFn,[],1)./sqrt(size(FFn,1)));
delete([hP1.upper hP1.lower]);
hP1.line.Color = 'w'; hP1.patch.FaceColor = 'w'; hP1.patch.FaceAlpha = 0.25; hP1.patch.EdgeColor = 'none';
ylabel(['faa - faa_{pre} (' winLbl ')']); xlabel('post stim onset time (s)')
grid on;
yLim = ylim;
patch([0 1 1 0].*mean(dsgn.ondurList), [1 1 1 1].*yLim(1) + [0 0 0.025 0.025].*range(yLim), 0.5.*[1 1 1], 'EdgeColor','none');
axis square tight
ax44.XLim = ax11.XLim;
% during/post markers (pre-stim-normalized, per vessel)
dStim = FFstim - FFpre;
hB = errorbar(mean(tStim),mean(dStim),std(dStim)./sqrt(length(dStim)),std(dStim)./sqrt(length(dStim)),range(tStim)/2,range(tStim)/2,'mo','CapSize',0);
hB.MarkerFaceColor = hB.MarkerEdgeColor;
dPost = FFpost - FFpre;
hB = errorbar(mean(tPost),mean(dPost),std(dPost)./sqrt(length(dPost)),std(dPost)./sqrt(length(dPost)),range(tPost)/2,range(tPost)/2,'mo','CapSize',0);
hB.MarkerFaceColor = hB.MarkerEdgeColor;

%%% Green response timecourse (dQ/Q, or selected fit intercept) summary -- its own panel (mid-left)
axQs = nexttile(4); hold on
xx = RTt; ym = mean(IItc,1); ye = std(IItc,[],1)./sqrt(size(IItc,1));
patch([xx fliplr(xx)],[ym-ye fliplr(ym+ye)],intCol,'FaceAlpha',0.25,'EdgeColor','none');
plot(xx,ym,'-','Color',intCol);
if showTs; plot(fTSg,mean(fIIm,1),':','Color',intCol); end   % ts-based (windowed, faa-grid) green mean, dotted
if isQ; ylabel(intLbl); else; ylabel([intLbl ' (' winLbl ')']); end   % X/Y intercept is windowed; dQ/Q is not
xlabel('post stim onset time (s)')
grid on; axis square; xlim(ax11.XLim)
if ~isempty(intYLim); ylim(intYLim); end
yLim = ylim;
patch([0 1 1 0].*mean(dsgn.ondurList), [1 1 1 1].*yLim(1) + [0 0 0.025 0.025].*range(yLim), 0.5.*[1 1 1], 'EdgeColor','none');
% during/post markers: green-window averages, mean +/- SEM (magenta, like the faa panel)
hB = errorbar(mean(tStim),mean(IIstim),std(IIstim)./sqrt(length(IIstim)),std(IIstim)./sqrt(length(IIstim)),range(tStim)/2,range(tStim)/2,'mo','CapSize',0);
hB.MarkerFaceColor = hB.MarkerEdgeColor;
hB = errorbar(mean(tPost),mean(IIpost),std(IIpost)./sqrt(length(IIpost)),std(IIpost)./sqrt(length(IIpost)),range(tPost)/2,range(tPost)/2,'mo','CapSize',0);
hB.MarkerFaceColor = hB.MarkerEdgeColor;

%%% Pre-stim-normalized green response timecourse -- mid-middle. Only meaningful for the
%%% fit-intercept variables (X/Y), which have a non-trivial pre-stim value; dQ/Q is already
%%% baseline-relative (pre value = 0), so its normalized panel duplicates the raw one -> omitted.
if ~isQ
    axQsn = nexttile(5); hold on
    IItcn = IItc - IIpre;   % green timecourse - per-vessel pre-stim value
    xx = RTt; ym = mean(IItcn,1); ye = std(IItcn,[],1)./sqrt(size(IItcn,1));
    patch([xx fliplr(xx)],[ym-ye fliplr(ym+ye)],intCol,'FaceAlpha',0.25,'EdgeColor','none');
    plot(xx,ym,'-','Color',intCol);
    ylabel([intPreLbl ' (' winLbl ')'])
    xlabel('post stim onset time (s)')
    grid on; axis square; xlim(ax11.XLim)
    if ~isempty(intYLimN); ylim(intYLimN); end
    yLim = ylim;
    patch([0 1 1 0].*mean(dsgn.ondurList), [1 1 1 1].*yLim(1) + [0 0 0.025 0.025].*range(yLim), 0.5.*[1 1 1], 'EdgeColor','none');
    % during/post markers (pre-stim-normalized green-window averages, per vessel)
    dIIstim = IIstim - IIpre; dIIpost = IIpost - IIpre;
    hB = errorbar(mean(tStim),mean(dIIstim),std(dIIstim)./sqrt(length(dIIstim)),std(dIIstim)./sqrt(length(dIIstim)),range(tStim)/2,range(tStim)/2,'mo','CapSize',0);
    hB.MarkerFaceColor = hB.MarkerEdgeColor;
    hB = errorbar(mean(tPost),mean(dIIpost),std(dIIpost)./sqrt(length(dIIpost)),std(dIIpost)./sqrt(length(dIIpost)),range(tPost)/2,range(tPost)/2,'mo','CapSize',0);
    hB.MarkerFaceColor = hB.MarkerEdgeColor;
end

%%% dQ/Q (green variable) during vs. post categorical summary -- mid-right (to the right of
%%% the two dQ/Q panels). NB no 'all data' (there is no pooled all-data fit for dQ/Q) and no
%%% pre-stim period; during/post are simple averages over the corresponding time windows.
ax33Q = nexttile(6); hold on
YQ = [IIstim IIpost];
plot(1:2,YQ','-','Color',intCol,'Marker','.');
axis square
set(gca,'XTick',1:2,'XTickLabel',{'during stim','post stim'})
ylabel(intLbl); xlim([0.5 2.5])
ax33Q.YGrid = 'on';
[hq,pq,ciq,statsq] = ttest(IIstim,IIpost);
fprintf('[dV/dD stats] %s during vs. post stim: p=%g; t=%g\n',intLeg,pq,statsq.tstat)   % pushed off the panel title to terminal


%%% optionally drop all legends (showLeg flag) so the data fills the panels in the png
if ~showLeg; delete(findobj(figs,'Type','legend')); end


%%% Export figures (printIt level set before the section heading; see tools/util/printFigs.m)
if printIt
    fNames = strings(1,numel(figs)); % figs(1:end-1) per vessel (in plot order), figs(end) the summary
    for k = 1:numel(figs)-1
        fNames(k) = "subject-" + string(vessel(k).sId) + "_vessel-" + string(vessel(k).id);
    end
    fNames(end) = "vesselSummary";
    printFigs(figs, fNames, fullfile(workDir,'dVdD'), printIt);
end


%% %%%%%
