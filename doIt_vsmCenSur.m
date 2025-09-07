clear all
close all

% dataIndexFile = '~/work/generalPreproc/doIt_generalPreproc/vsmDiamCenSur_indexFile.mat';
dataIndexFile = '~/work/generalPreproc/doIt_generalPreproc/vsmDiamCenSur_indexFile20250630.mat'; % after reprocessing of vfMRIpc
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
    toolDir    = fullfile(getenv('HOME'),'tools');
    workScript = mfilename;
    workFile   = [workScript '.mat'];
    workDir    = fullfile(getenv('HOME'),'/work/vsmCenSur/',workScript); if ~exist(workDir,'dir'); mkdir(workDir); end
    workFile   = fullfile(fileparts(workDir),workFile);
    envId      = 1;
    setenv('SINGULARITY_BINDPATH',strjoin({storageDir scratchDir toolDir workDir},','));
else
    dbstack; error('not implemented')
end

% Load dependencies
%%% matlab
addpath(genpath(         workDir                                 ))
tool = 'vasomoTools'; toolURL = 'https://github.com/Proulx-S/vasomoTools.git';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,tool)))
tool = 'bassReg2'; toolURL = 'https://github.com/Proulx-S/vasomoTools.git';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,tool)))
tool = 'util'; toolURL = 'https://github.com/Proulx-S/util.git';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,tool)))
tool = 'chronux'; toolURL = 'https://github.com/Proulx-S/chronux';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,'chronux/chronux_2_12/modified')))
tool = 'fieldtrip'; toolURL = 'https://github.com/fieldtrip/fieldtrip';
if ~exist(fullfile(toolDir, tool), 'dir'); system(['git clone ' toolURL ' ' fullfile(toolDir, tool)]); end
addpath(genpath(fullfile(toolDir,'fieldtrip/external/freesurfer')))
% tool = 'shplot'; toolURL = 'https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/64990/versions/6/download/zip';
% if ~exist(fullfile(toolDir, tool), 'dir'); tmpZip = fullfile(tempdir, 'shplot.zip'); websave(tmpZip, toolURL); unzip(tmpZip, fullfile(toolDir, tool)); delete(tmpZip); end
% addpath(genpath(fullfile(toolDir,tool)))
tool = 'multigradient'; toolURL = 'https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/4dc86a0f-886b-488c-9318-59a1c9fb0f3e/e5d982ae-3ddd-4768-8b34-8d71d956d893/packages/zip';
if ~exist(fullfile(toolDir, tool), 'dir'); tmpZip = fullfile(tempdir, 'shplot.zip'); websave(tmpZip, toolURL); unzip(tmpZip, fullfile(toolDir, tool)); delete(tmpZip); end
addpath(genpath(fullfile(toolDir,tool)))



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
        if contains(acqList{A},{'vfMRIpc' 'bold'}); continue; end
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




% Save all
% winSz = rCond{S}.vfMRI_dflt_none.task_50sPrd5sDur.volMt.run(1).param.psdTrialGram.dsgn.win(1);
% K;
% filename = ['results20250508_K' strjoin(cellstr(num2str(K(2:3)')),'-') '_winSz' num2str(winSz) 'tPts.mat'];
filename = fullfile(pwd,'workScript_tmp.mat');
disp(['saving ' filename])
save(filename,'-v7.3')
else
% Load all
% filename = 'results20250505_K4-6_winSz19tPts.mat';
% filename = 'results20250505_K3-5_winSz24tPts.mat';
% filename = 'results20250505_K3-4_winSz26tPts.mat';
% filename = 'results20250505_K3-5_winSz30tPts.mat';
% filename = 'results20250508_K4-5_winSz28tPts.mat';
filename = fullfile(pwd,'workScript_tmp.mat');
disp(['loading ' filename])
load(filename)
end



%%%%%%%%%%%%%%%
%% Get ROI data
% note: S=6 does not have the same matrix size for vfMRIpc vs vfMRIinflow, screwing up extraction of rois from vfMRIpc since they are defined using vfMRIinflow
roi = cell(size(subList));
for S = 1;%size(subList,1)%:size(subList,1)
    disp(['extracting ROI data: ' subList{S}])
    taskTmp = fields(rCond{S}.vfMRI_dflt_none); taskTmp = taskTmp(contains(taskTmp,'task_'));
    label = rCond{S}.vfMRI_dflt_none.(taskTmp{1}).volAnat.label.calcarineVessel;
            
    for A = 1:length(acqList)
        acq  = acqList{A};
        % acq  = 'vfMRI_dflt_none';
        if ~isfield(rCond{S},acq)  ; continue; end
        if ~contains(acq,{'vfMRI'}); continue; end
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
                im = {
                    fBase
                    fBasePolyRun
                    fBasePhase
                    fBasePhase_tsAv
                    label.fBaseList{contains(b,'vesselness.nii')}
                    rCond{S}.(acq).(task).fPreprocList
                    char(rCond{S}.(acq).(task).volResp.mag.respCat.stats.fResp)
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
            roi{S}.(acq).(task).vessel = getVesselRoi2(label,imField,im,cropSz);
            [roi{S}.(acq).(task).vessel.coefAdjFlag] = deal(coefAdjFlag);
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

            % modify roi
            roi{S}.(acq).(task).vessel = modifyRoi(roi{S}.(acq).(task).vessel,{'peakVox' 'dilate1' 'dilate1p5' 'dilate2'});

            % % summarize rois (vox2roi)
            % vessels = roi{S}.(acq).(task).vessel;
            % vessels = {vessels(ismember({vessels.class},'artery')) vessels(ismember({vessels.class},'vein'))};
            % roi{S}.(acq).(task).vessels = mergeRoi(vessels);


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

%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Single-vessel responses
%%%%%%%%%%%%%%%%%%%%%%%%%%
S=1;
acq = 'vfMRI_dflt_none';
task = 'task_50sPrd5sDur';
roi{S}.(acq).(task).vessel = getVesselResp(roi{S}.(acq).(task).vessel);

tiling = plotUL3(roi{S}.(acq).(task).vessel,'base'     ,[100 1500],4);
hFol   = {}; hAol   = {}; hIol   = {};
hFresp = {}; hAresp = {}; hTresp = {};
[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'coef'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
adjPoly(hIol{end},'original','k',-1); adjPoly(hIol{end},'dilate1','w',1);
[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'coef_flat'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
adjPoly(hIol{end},'original','k',-1); adjPoly(hIol{end},'dilate1','w',1);

[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'svSpace_1'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
adjPoly(hIol{end},'original','k',-1); adjPoly(hIol{end},'dilate1','w',1);
[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'svTime_1',roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
[hFol{end+1},hAol{end+1},hIol{end+1}] = plotOL( [],{'svSpace_2'},roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
adjPoly(hIol{end},'original','k',-1); adjPoly(hIol{end},'dilate1','w',1);
[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'svTime_2',roi{S}.(acq).(task).vessel,tiling.sub.right.hA);

[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respArea',roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respVel',roi{S}.(acq).(task).vessel,tiling.sub.right.hA);

[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respSurVox',roi{S}.(acq).(task).vessel,tiling.sub.right.hA);
[~,hFresp{end+1},hAresp{end+1},hTresp{end+1}] = plotResp([],'respPeakVox',roi{S}.(acq).(task).vessel,tiling.sub.right.hA);

[roi,hF,hA,rCond] = smrRoi2(rCond,'respSurVox',roi,H)
% threshOL(hIol,'actQ_dilate1',0);




%% %%%%%%%%%%%%%%%%%%%%%%

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

return

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

return


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





return

% % summarize rois (vox2roi)
% vessels = roi{S}.(acq).(task).vessel;
% ismember({vessels.class},'artery')
% ismember({vessels.class},'vein')
% vessels.anot_actType
% vessels = {vessels(ismember({vessels.class},'artery')) vessels(ismember({vessels.class},'vein'))};
% roi{S}.(acq).(task).vessels = mergeRoi2(vessels);


%% Summarize roi

plotIt  = 1;
saveIt  = 0;
printIt = 0;
if plotIt
    close all
    figure('WindowStyle','docked');
    drawnow;
end
for S = 1:size(subList,1)
    for A = 1%:length(acqList)
        acq  = acqList{A};
        if ~isfield(rCond{S},acq)          ; continue; end
        if contains(acq,{'bold' 'vfMRIpc'}); continue; end
        for T = 1:length(taskList)
            task = taskList{T};
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

            % get data
            % roi{S}.(acq).(task).vessel = smrRoi(rCond{S}.(acq).(task),{'resp_dilate1_actQ_actSgn'  'psd_dilate1_actQ'  'psdTrialGram_dilate1_actQ' },roi{S}.(acq).(task).vessel);
            % roi{S}.(acq).(task).vessel = smrRoi2(rCond{S}.(acq).(task),{'resp_original_actQ_actSgn' 'psd_original_actQ' 'psdTrialGram_original_actQ' 'resp_dilate1_actQ_actSgn'  'psd_dilate1_actQ'  'psdTrialGram_dilate1_actQ'},roi{S}.(acq).(task).vessel);
            % roi{S}.(acq).(task).vessel = smrRoi2(rCond{S}.(acq).(task),{'resp_dilate1_actQ_actSgn' 'psd_dilate1_actQ' 'psdTrialGram_dilate1_actQ' 'coh_dilate1' 'cohTrialGram_dilate1'},roi{S}.(acq).(task).vessel);
        end
    end
end


metricList = {};
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



return



