function hF = grpAvPlt2(roi,subList,acq,task,metric,pltType,winIndLabel,avMode)
    if ~exist('pltType','var'); pltType = []; end
    if ~exist('winIndLabel','var');   winIndLabel = []; end
    if ~exist('avMode','var');       avMode = []; end
    if isempty(avMode);              avMode = 'catVes-avVox-catSub'; end % 'avVox-catVes' 'avVox-catVes-avVes-catSub' 'catVes-avVox-catSub'
        
    saveFlag = 1;

    vessels       = [];
    vesselsSub    = {};
    vesselsAcq    = {};
    vesselsTask   = {};
    K = [];
    for S = 1:size(subList,1)
        if ~isfield(roi{S},acq) || isempty(roi{S}.(acq)); continue; end
        if ~isfield(roi{S}.(acq),task) || isempty(roi{S}.(acq).(task)); continue; end
        sigInd = [roi{S}.(acq).(task).vessel.anot_sig];
        vessels = cat(1,vessels,roi{S}.(acq).(task).vessel(sigInd));
        vesselsSub = cat(1,vesselsSub,repmat(subList(S),size(roi{S}.(acq).(task).vessel(sigInd))));
        vesselsAcq = cat(1,vesselsAcq,repmat({acq},size(roi{S}.(acq).(task).vessel(sigInd))));
        vesselsTask = cat(1,vesselsTask,repmat({task},size(roi{S}.(acq).(task).vessel(sigInd))));
        % {roi{S}.(acq).(task).vessel.class}
        % [roi{S}.(acq).(task).vessel.anot_sig]
        % {roi{S}.(acq).(task).vessel.anot_actType}
        if contains(metric,'coh')
            K = cat(1,K,[roi{S}.(acq).(task).vessel(1).mt.svdTrialGram.K roi{S}.(acq).(task).vessel(1).mt.svd.K]);
        else
            K = cat(1,K,[roi{S}.(acq).(task).vessel(1).mt.psdTrialGram.K roi{S}.(acq).(task).vessel(1).mt.psd.K]);
        end
    end
    if nnz(diff(K,[],1)); error('K values are not the same'); end
    K = K(1,:);
    [vessels.sub]  = deal(vesselsSub{:});  clear vesselsSub
    [vessels.acq]  = deal(vesselsAcq{:});  clear vesselsAcq
    [vessels.task] = deal(vesselsTask{:}); clear vesselsTask
    
    % extract metric
    metricList = {};
    for m = 1:length(roi{S}.(acq).(task).vessel(1).smr)
        metricList{m} = roi{S}.(acq).(task).vessel(1).smr{m}.metric;
    end

    ind = ismember(metricList,metric);
    smr = cat(1,vessels.smr);
    smr = cat(1,smr{:,ind});
    [smr.class] = deal(vessels.class);
    [smr.anot_actType] = deal(vessels.anot_actType);
    [smr.sub] = deal(vessels.sub);
    [smr.acq] = deal(vessels.acq);
    [smr.task] = deal(vessels.task);


    onsetList = roi{1}.(acq).(task).vessel(1).mt.psdTrialGram.onsetList;

    roi{1}.vfMRI_dflt_none.task_50sPrd5sDur.vessel(1).mt.svdTrialGram.K
    vessels(1).mt.psdTrialGram.K

    switch avMode
        case 'avVox-catVes'
            %% Colate data across N vessels -- each vessel is the average of n voxels
            artAct   = smrSubject(smr,ismember({smr.class},'artery') & ~ismember({smr.anot_actType},'non-sig')        ,'avVox-catVes');
            artCS    = smrSubject(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'center-surround'),'avVox-catVes');
            artLR    = smrSubject(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'left-right')     ,'avVox-catVes');
            veiAct   = smrSubject(smr,ismember({smr.class},'vein'  ) & ~ismember({smr.anot_actType},'non-sig')        ,'avVox-catVes');
            artAct.info{ismember(artAct.info,'sub')} = 'vessel'; artAct.info = strjoin(artAct.info,' x ');
            artCS.info{ismember(artCS.info,'sub')} = 'vessel'; artCS.info = strjoin(artCS.info,' x ');
            artLR.info{ismember(artLR.info,'sub')} = 'vessel'; artLR.info = strjoin(artLR.info,' x ');
            veiAct.info{ismember(veiAct.info,'sub')} = 'vessel'; veiAct.info = strjoin(veiAct.info,' x ');

            % artAct   = smrVessel(smr,ismember({smr.class},'artery') & ~ismember({smr.anot_actType},'non-sig')        );
            % artCS    = smrVessel(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'center-surround'));
            % artLR    = smrVessel(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'left-right')     );
            % artInact = smrVessel(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'non-sig')        );
            % veiAct   = smrVessel(smr,ismember({smr.class},'vein'  ) & ~ismember({smr.anot_actType},'non-sig')        );
            % % veiInact = smrVessel(smr,ismember({smr.class},'vein'  ) &  ismember({smr.anot_actType},'non-sig')        );
        
        case 'avVox-catVes-avVes-catSub'
            %% Colate data across N subjects -- each subject is the average of n vessels
            artAct   = smrSubject(smr,ismember({smr.class},'artery') & ~ismember({smr.anot_actType},'non-sig')        ,'avVox-catVes-avVes');
            artCS    = smrSubject(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'center-surround'),'avVox-catVes-avVes');
            artLR    = smrSubject(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'left-right')     ,'avVox-catVes-avVes');
            veiAct   = smrSubject(smr,ismember({smr.class},'vein'  ) & ~ismember({smr.anot_actType},'non-sig')        ,'avVox-catVes-avVes');
            % veiInact = smrSubject(smr,ismember({smr.class},'vein'  ) &  ismember({smr.anot_actType},'non-sig')        ,'avVox-catVes-avVes');

        case 'catVes-avVox-catSub'
            %% Colate data across N subjects -- each subject is the average of n voxels (pooled across vessels)
            artAct   = smrSubject(smr,ismember({smr.class},'artery') & ~ismember({smr.anot_actType},'non-sig')        ,'catVes-avVox');
            artCS    = smrSubject(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'center-surround'),'catVes-avVox');
            artLR    = smrSubject(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'left-right')     ,'catVes-avVox');
            veiAct   = smrSubject(smr,ismember({smr.class},'vein'  ) & ~ismember({smr.anot_actType},'non-sig')        ,'catVes-avVox');
            % veiInact = smrSubject(smr,ismember({smr.class},'vein'  ) &  ismember({smr.anot_actType},'non-sig')        ,'catVes-avVox');        
        otherwise
            error('Invalid averaging mode');
    end

    switch metric
        case {'psdTrialGram_dilate1_actQ' 'psdTrialGram_original_actQ' 'cohTrialGram_dilate1' 'cohTrialGram_original'}
            %% Trial-triggered time-frequency PSD responses
            hF = figure('WindowStyle','docked');
            ht = tiledlayout(2,3);
            ht.TileSpacing = 'tight';
            ht.Padding = 'tight';

            ax = {};

            if isempty(pltType)
                pltType = 'timeFreq';
            end
            switch pltType
                case 'timeFreq'
                    ord = [5 1 3 4 6 7 2 8];

                    % Active arteries subplot
                    dat = artAct;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t    ,ord);
                    y   =  permute(dat.f    ,ord);
                    zAv =  permute(dat.vecAv,ord);
                    zEr =  permute(dat.vecEr,ord);

                    winSz = mean(diff(x,[],7));
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    if isempty(winIndLabel)
                        % window 1 starts at stim onset and window 2 is that last one
                        winInd = [b size(x,2)];
                    elseif strcmp(winIndLabel,'bNa15sec')
                        % window 1 ends at 15 seconds and window 2 starts at 15 seconds
                        [a,b1] = min(abs(x(1,:,1,1,1,1,2)-15));
                        [a,b2] = min(abs(x(1,:,1,1,1,1,1)-15));
                        winInd = [b1 b2];
                    else
                        error('Invalid window index');
                    end
                    x = mean(x,7);

                    h = imagesc(ax{end},x,y,zAv);
                    xline(ax{end},x(winInd(1)),'--k');
                    xline(ax{end},x(winInd(2)),'-k');
                    title(ax{end},['All Active Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    ylabel('Frequency (Hz)');
                    xlabel('time post-stim onset (s)');
                    grid on;
                    axis tight;
                    yLim = ylim;
                    line(ax{end},x(winInd(1))  +[-0.5 0.5].*winSz,yLim(2)*[0.99 0.99],'linestyle','-','color','k','linewidth',3);
                    line(ax{end},x(winInd(2))+[-0.5 0.5].*winSz,yLim(2)*[0.97 0.97],'linestyle','-','color','k','linewidth',3);
                    


                    % CS arteries subplot
                    dat = artCS;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,ord);
                    y   =  permute(dat.f,ord);
                    zAv =  permute(dat.vecAv ,ord);
                    zEr =  permute(dat.vecEr,ord);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);
                    h = imagesc(ax{end},x,y,zAv);
                    xline(ax{end},x(winInd(1)),'--k');
                    xline(ax{end},x(winInd(2)),'-k');
                    title(ax{end},['Center-Surround Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    ylabel('Frequency (Hz)');
                    xlabel('time post-stim onset (s)');
                    grid on;
                    axis tight;
                    yLim = ylim;
                    line(ax{end},x(winInd(1))  +[-0.5 0.5].*winSz,yLim(2)*[0.99 0.99],'linestyle','-','color','k','linewidth',3);
                    line(ax{end},x(winInd(2))+[-0.5 0.5].*winSz,yLim(2)*[0.97 0.97],'linestyle','-','color','k','linewidth',3);
                    

                    % LR arteries subplot
                    dat = artLR;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,ord);
                    y   =  permute(dat.f,ord);
                    zAv =  permute(dat.vecAv ,ord);
                    zEr =  permute(dat.vecEr,ord);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);
                    h = imagesc(ax{end},x,y,zAv);
                    xline(ax{end},x(winInd(1)),'--k');
                    xline(ax{end},x(winInd(2)),'-k');
                    title(ax{end},['Left-Right Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    ylabel('Frequency (Hz)');
                    xlabel('time post-stim onset (s)');
                    grid on;
                    axis tight;
                    yLim = ylim;
                    line(ax{end},x(winInd(1))  +[-0.5 0.5].*winSz,yLim(2)*[0.99 0.99],'linestyle','-','color','k','linewidth',3);
                    line(ax{end},x(winInd(2))+[-0.5 0.5].*winSz,yLim(2)*[0.97 0.97],'linestyle','-','color','k','linewidth',3);
                    

                    % Active veins subplot
                    dat = veiAct;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,ord);
                    y   =  permute(dat.f,ord);
                    zAv =  permute(dat.vecAv ,ord);
                    zEr =  permute(dat.vecEr,ord);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);
                    h = imagesc(ax{end},x,y,zAv);
                    xline(ax{end},x(winInd(1)),'--k');
                    xline(ax{end},x(winInd(2)),'-k');
                    title(ax{end},['All Active Vein (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'vein'))) ')']);
                    ylabel('Frequency (Hz)');
                    xlabel('time post-stim onset (s)');
                    grid on;
                    axis tight;
                    yLim = ylim;
                    line(ax{end},x(winInd(1))  +[-0.5 0.5].*winSz,yLim(2)*[0.99 0.99],'linestyle','-','color','k','linewidth',3);
                    line(ax{end},x(winInd(2))+[-0.5 0.5].*winSz,yLim(2)*[0.97 0.97],'linestyle','-','color','k','linewidth',3);
                    


                    axis([ax{:}],'tight');
                    cLim = get([ax{:}],'CLim'); if iscell(cLim); cLim = cat(1,cLim{:}); end; cLim = [min(cLim(:,1)) max(cLim(:,2))];
                    xLim = get([ax{:}],'XLim'); if iscell(xLim); xLim = cat(1,xLim{:}); end; xLim = [min(xLim(:,1)) max(xLim(:,2))];
                    xLim(2) = mean(diff(onsetList));
                    if contains(metric,'coh')
                        % cLim(1) = 1/K(1);
                        set([ax{:}],'CLim',cLim,'ColorScale','linear','YDir','normal','XLim',xLim);
                    else
                        set([ax{:}],'CLim',cLim,'ColorScale','log','YDir','normal','XLim',xLim);
                    end


                    % K     = roi{1}.(acq).(task).vessel(1).mt.psdTrialGram.K;
                    param = roi{1}.(acq).(task).vessel(1).mt.psdTrialGram.param;
                    winSz = param.dsgn.win(1);
                    N     = length(param.dsgn.onsetList)*winSz;
                    Fs    = param.Fs;
                    T     = N/Fs;
                    [TW,W,K] = K2W(T,K(1),0);

                    line(ax{end},x(winInd(1))  .* [1 1],yLim(2)+[-2*W 0],'linestyle','-','color','r','linewidth',2);
                    line(ax{end},x(winInd(2)).* [1 1],yLim(2)+[-2*W 0],'linestyle','-','color','r','linewidth',2);
                                        

                    if saveFlag
                        filename = ['smrVesselTimeFreqPSD_K' num2str(K) '_winSz' num2str(winSz) 'tPts_' winIndLabel];
                        disp(['Saving ' filename '.fig and ' filename '.png']);
                        saveas(hF,[filename '.fig']);
                        saveas(hF,[filename '.png']);
                        print(hF, [filename '.svg'], '-dsvg', '-painters');
                    end
            

                case 'freq'
                    ord = [5 1 3 4 6 7 2 8];
                    % Active arteries subplot
                    dat = artAct;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,ord);
                    y   =  permute(dat.f,ord);
                    zAv =  permute(dat.vecAv ,ord);
                    zEr =  permute(dat.vecEr,ord);

                    winSz = mean(diff(x,[],7));
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    if isempty(winIndLabel)
                        % window 1 starts at stim onset and window 2 is that last one
                        winInd = [b size(x,2)];
                    elseif strcmp(winIndLabel,'bNa15sec')
                        % window 1 ends at 15 seconds and window 2 starts at 15 seconds
                        [a,b1] = min(abs(x(1,:,1,1,1,1,2)-15));
                        [a,b2] = min(abs(x(1,:,1,1,1,1,1)-15));
                        winInd = [b1 b2];
                    else
                        error('Invalid window index');
                    end
                    x = mean(x,7);
                    

                    
                    
                    hHyper     = shplot2(y, zAv(:,winInd(1)), zEr(:,winInd(1)), ax{end}, '-k'); delete([hHyper.upper hHyper.lower]);
                    hold on;
                    hPostHyper = shplot2(y, zAv(:,winInd(2)), zEr(:,winInd(2)), ax{end}, '--k'); delete([hPostHyper.upper hPostHyper.lower]);
                    
                    title(ax{end},['All Active Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    xlabel('Frequency (Hz)');
                    if contains(metric,'coh')
                        ylabel('coherence');
                    else
                        ylabel('PSD');
                    end
                    % legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
                    grid on;
                    axis tight;
                    hHyper.patch.FaceAlpha = 0.2;
                    hHyper.patch.FaceColor = 'k';
                    hPostHyper.patch.FaceAlpha = 0.2;
                    hPostHyper.patch.FaceColor = 'k';


                    % CS arteries subplot
                    dat = artCS;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,ord);
                    y   =  permute(dat.f,ord);
                    zAv =  permute(dat.vecAv ,ord);
                    zEr =  permute(dat.vecEr,ord);
                    % [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    % winSz = mean(diff(x,[],7));
                    x = mean(x,7);

                    hHyper     = shplot2(y, zAv(:,winInd(1)), zEr(:,winInd(1)), ax{end}, '-k'); delete([hHyper.upper hHyper.lower]);
                    hold on;
                    hPostHyper = shplot2(y, zAv(:,winInd(2)), zEr(:,winInd(2)), ax{end}, '--k'); delete([hPostHyper.upper hPostHyper.lower]);
                    
                    title(ax{end},['Center-Surround Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    xlabel('Frequency (Hz)');
                    if contains(metric,'coh')
                        ylabel('coherence');
                    else
                        ylabel('PSD');
                    end
                    % legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
                    grid on;
                    axis tight;
                    hHyper.patch.FaceAlpha = 0.2;
                    hHyper.patch.FaceColor = 'k';
                    hPostHyper.patch.FaceAlpha = 0.2;
                    hPostHyper.patch.FaceColor = 'k';

                    % LR arteries subplot
                    dat = artLR;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,ord);
                    y   =  permute(dat.f,ord);
                    zAv =  permute(dat.vecAv ,ord);
                    zEr =  permute(dat.vecEr,ord);
                    % [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    % winSz = mean(diff(x,[],7));
                    x = mean(x,7);

                    hHyper     = shplot2(y, zAv(:,winInd(1)), zEr(:,winInd(1)), ax{end}, '-k'); delete([hHyper.upper hHyper.lower]);
                    hold on;
                    hPostHyper = shplot2(y, zAv(:,winInd(2)), zEr(:,winInd(2)), ax{end}, '--k'); delete([hPostHyper.upper hPostHyper.lower]);
                    
                    title(ax{end},['Left-Right Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    xlabel('Frequency (Hz)');
                    if contains(metric,'coh')
                        ylabel('coherence');
                    else
                        ylabel('PSD');
                    end
                    % legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
                    grid on;
                    axis tight;
                    hHyper.patch.FaceAlpha = 0.2;
                    hHyper.patch.FaceColor = 'k';
                    hPostHyper.patch.FaceAlpha = 0.2;
                    hPostHyper.patch.FaceColor = 'k';

                    % Active veins subplot
                    dat = veiAct;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,ord);
                    y   =  permute(dat.f,ord);
                    zAv =  permute(dat.vecAv ,ord);
                    zEr =  permute(dat.vecEr,ord);
                    % [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    % winSz = mean(diff(x,[],7));
                    x = mean(x,7);

                    hHyper     = shplot2(y, zAv(:,winInd(1)), zEr(:,winInd(1)), ax{end}, '-k'); delete([hHyper.upper hHyper.lower]);
                    hold on;
                    hPostHyper = shplot2(y, zAv(:,winInd(2)), zEr(:,winInd(2)), ax{end}, '--k'); delete([hPostHyper.upper hPostHyper.lower]);
                    
                    title(ax{end},['All Active Veins (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'vein'))) ')']);
                    xlabel('Frequency (Hz)');
                    if contains(metric,'coh')
                        ylabel('coherence');
                    else
                        ylabel('PSD');
                    end
                    % legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
                    grid on;
                    axis tight;
                    hHyper.patch.FaceAlpha = 0.2;
                    hHyper.patch.FaceColor = 'k';
                    hPostHyper.patch.FaceAlpha = 0.2;
                    hPostHyper.patch.FaceColor = 'k';


                    axis([ax{:}],'tight');
                    yLim = get([ax{:}],'YLim'); if iscell(yLim); yLim = cat(1,yLim{:}); end; yLim = [min(yLim(:,1)) max(yLim(:,2))];
                    if contains(metric,'coh')
                        set([ax{:}],'YLim',yLim,'YScale','linear');
                    else
                        set([ax{:}],'YLim',yLim,'YScale','log');
                    end

                    legend([hHyper.line hPostHyper.line], {'hyperhemia' 'post-hyperhemia'}, 'Location', 'northeast','AutoUpdate','off');
                    

                    

                    % K     = roi{1}.(acq).(task).vessel(1).mt.psdTrialGram.K;
                    param = roi{1}.(acq).(task).vessel(1).mt.psdTrialGram.param;
                    winSz = param.dsgn.win(1);
                    N     = length(param.dsgn.onsetList)*winSz;
                    Fs    = param.Fs;
                    T     = N/Fs;
                    [TW,W,K] = K2W(T,K(1),0);

                    xLim = xlim;
                    yLim = ylim;
                    line(ax{end},mean(xLim) + [-W W],yLim(2).*[1 1],'linestyle','-','color','r','linewidth',2);
                    
                    if saveFlag
                        filename = ['smrVesselPrePostPSD_K' num2str(K) '_winSz' num2str(winSz) 'tPts_' winIndLabel];
                        disp(['Saving ' filename '.fig and ' filename '.png']);
                        saveas(hF,[filename '.fig']);
                        saveas(hF,[filename '.png']);
                        print(hF, [filename '.svg'], '-dsvg', '-painters');
                    end
        

                otherwise
                    error('Invalid plot type');
            end

            
            


        case {'psd_dilate1_actQ' 'psd_original_actQ' 'coh_dilate1' 'coh_original'}
            %% PSD responses
            hF = figure('WindowStyle','docked');
            ht = tiledlayout(2,3);
            ht.TileSpacing = 'tight';
            ht.Padding = 'tight';

            ax = {};
            % Active arteries subplot
            dat = artAct;
            ax{end+1} = nexttile(ht);
            x   = permute(dat.f     ,[5 1 3 2 4 6 7 8]);
            yAv = permute(dat.vecAv ,[5 1 3 2 4 6 7 8]);
            yEr = permute(dat.vecEr,[5 1 3 2 4 6 7 8]);
            h = shplot2(x, yAv, yEr, ax{end}, '-r'); delete([h.upper h.lower]);
            title(ax{end},['All Active Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
            xlabel('Frequency (Hz)');
            if contains(metric,'psd')
                ylabel('PSD');
            elseif contains(metric,'coh')
                ylabel('coherence');
            end
            % legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
            grid on;
            axis tight;
            h.patch.FaceAlpha = 0.2;
            h.patch.FaceColor = 'r';

            % CS arteries subplot
            dat = artCS;
            ax{end+1} = nexttile(ht);
            x   = permute(dat.f     ,[5 1 3 2 4 6 7 8]);
            yAv = permute(dat.vecAv ,[5 1 3 2 4 6 7 8]);
            yEr = permute(dat.vecEr,[5 1 3 2 4 6 7 8]);
            h = shplot2(x, yAv, yEr, ax{end}, '-r'); delete([h.upper h.lower]);
            title(ax{end},['Center-Surround Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
            xlabel('Frequency (Hz)');
            if contains(metric,'psd')
                ylabel('PSD');
            elseif contains(metric,'coh')
                ylabel('coherence');
            end
            % legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
            grid on;
            axis tight;
            h.patch.FaceAlpha = 0.2;
            h.patch.FaceColor = 'r';



            % LR arteries subplot
            dat = artLR;
            ax{end+1} = nexttile(ht);
            x   = permute(dat.f     ,[5 1 3 2 4 6 7 8]);
            yAv = permute(dat.vecAv ,[5 1 3 2 4 6 7 8]);
            yEr = permute(dat.vecEr,[5 1 3 2 4 6 7 8]);
            h = shplot2(x, yAv, yEr, ax{end}, '-r'); delete([h.upper h.lower]);
            title(ax{end},['Left-Right Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
            xlabel('Frequency (Hz)');
            if contains(metric,'psd')
                ylabel('PSD');
            elseif contains(metric,'coh')
                ylabel('coherence');
            end
            % legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
            grid on;
            axis tight;
            h.patch.FaceAlpha = 0.2;
            h.patch.FaceColor = 'r';



            % Active veins subplot
            dat = veiAct;
            ax{end+1} = nexttile(ht);
            x   = permute(dat.f     ,[5 1 3 2 4 6 7 8]);
            yAv = permute(dat.vecAv ,[5 1 3 2 4 6 7 8]);
            yEr = permute(dat.vecEr,[5 1 3 2 4 6 7 8]);
            h = shplot2(x, yAv, yEr, ax{end}, '-b'); delete([h.upper h.lower]);
            title(ax{end},['All Active Veins (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'vein'))) ')']);
            xlabel('Frequency (Hz)');
            if contains(metric,'psd')
                ylabel('PSD');
            elseif contains(metric,'coh')
                ylabel('coherence');
            end
            % legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
            grid on;
            axis tight;
            h.patch.FaceAlpha = 0.2;
            h.patch.FaceColor = 'b';

            axis([ax{:}],'tight');
            yLim = get([ax{:}],'YLim'); if iscell(yLim); yLim = cat(1,yLim{:}); end; yLim = [min(yLim(:,1)) max(yLim(:,2))];
            set([ax{:}],'YLim',yLim,'YScale','log');
            



            K     = roi{1}.(acq).(task).vessel(1).mt.psd.K;
            param = roi{1}.(acq).(task).vessel(1).mt.psd.param;
            N     = 300;
            Fs    = param.Fs;
            T     = N/Fs;
            [TW,W,K] = K2W(T,K,0);

            xLim = xlim;
            yLim = ylim;
            line(ax{end},mean(xLim) + [-W W],yLim(2).*[1 1],'linestyle','-','color','r','linewidth',2);
            




            if saveFlag
                if contains(metric,'psd')
                    filename = ['smrVesselFullPSD_K' num2str(K)];
                elseif contains(metric,'coh')
                    filename = ['smrVesselFullCOH_K' num2str(K)];
                end
                disp(['Saving ' filename '.fig and ' filename '.png']);
                saveas(hF,[filename '.fig']);
                saveas(hF,[filename '.png']);
                print(hF, [filename '.svg'], '-dsvg', '-painters');
            end
            

        case {'resp_dilate1_actQ_actSgn' 'resp_original_actQ_actSgn'}
            %% Time-domain responses
            hF = figure('WindowStyle','docked');
            ht = tiledlayout(2,3);
            ht.TileSpacing = 'tight';
            ht.Padding = 'tight';

            % Active arteries subplot
            axArtAct = nexttile(ht);
            hArtActNeg = shplot2(artAct.t, artAct.vecAv(:,1), artAct.vecEr(:,1), axArtAct, '-.r'); delete([hArtActNeg.upper hArtActNeg.lower]);
            hold on;
            hArtActPos = shplot2(artAct.t, artAct.vecAv(:,2), artAct.vecEr(:,2), axArtAct, '-r'); delete([hArtActPos.upper hArtActPos.lower]);
            title(axArtAct,['All Active Arteries (n=' num2str(size(artAct.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
            xlabel('time post-stim onset (s)');
            ylabel('MR signal change');
            legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
            grid on;
            axis tight;
            hArtActNeg.patch.FaceAlpha = 0.2;
            hArtActPos.patch.FaceAlpha = 0.2;
            hArtActNeg.patch.FaceColor = 'r';
            hArtActPos.patch.FaceColor = 'r';

            % CS arteries subplot
            axArtCS = nexttile(ht);
            hArtCSNeg = shplot2(artCS.t, artCS.vecAv(:,1), artCS.vecEr(:,1), axArtCS, '-.r'); delete([hArtCSNeg.upper hArtCSNeg.lower]);
            hold on;
            hArtCSPos = shplot2(artCS.t, artCS.vecAv(:,2), artCS.vecEr(:,2), axArtCS, '-r'); delete([hArtCSPos.upper hArtCSPos.lower]);
            title(axArtCS,['Center-Surround Arteries (n=' num2str(size(artCS.vec,3)) ')']);
            xlabel('time post-stim onset (s)');
            ylabel('MR signal change');
            legend([hArtCSNeg.line, hArtCSPos.line], strcat(artCS.label,'Vox'), 'Location', 'best');
            grid on;
            axis tight;
            hArtCSNeg.patch.FaceAlpha = 0.2;
            hArtCSPos.patch.FaceAlpha = 0.2;
            hArtCSNeg.patch.FaceColor = 'r';
            hArtCSPos.patch.FaceColor = 'r';


            % LR arteries subplot
            axArtLR = nexttile(ht);
            hArtLRNeg = shplot2(artLR.t, artLR.vecAv(:,1), artLR.vecEr(:,1), axArtLR, '-.r'); delete([hArtLRNeg.upper hArtLRNeg.lower]);
            hold on;
            hArtLRPos = shplot2(artLR.t, artLR.vecAv(:,2), artLR.vecEr(:,2), axArtLR, '-r'); delete([hArtLRPos.upper hArtLRPos.lower]);
            title(axArtLR,['Left-Right Arteries (n=' num2str(size(artLR.vec,3)) ')']);
            xlabel('time post-stim onset (s)');
            ylabel('MR signal change');
            legend([hArtLRNeg.line, hArtLRPos.line], strcat(artLR.label,'Vox'), 'Location', 'best');
            grid on;
            axis tight;
            hArtLRNeg.patch.FaceAlpha = 0.2;
            hArtLRPos.patch.FaceAlpha = 0.2;
            hArtLRNeg.patch.FaceColor = 'r';
            hArtLRPos.patch.FaceColor = 'r';

            % Active veins subplot
            axVeiAct = nexttile(ht);
            hVeiActPos = shplot2(veiAct.t, veiAct.vecAv(:,2), veiAct.vecEr(:,2), axVeiAct, '-b'); delete([hVeiActPos.upper hVeiActPos.lower]);
            title(axVeiAct,['All Active Veins (n=' num2str(size(veiAct.vec,3)) '/' num2str(nnz(ismember({smr.class},'vein'))) ')']);
            xlabel('time post-stim onset (s)');
            ylabel('MR signal change');
            grid on;
            axis tight;
            hVeiActPos.patch.FaceAlpha = 0.2;
            hVeiActPos.patch.FaceColor = 'b';

            set([axArtAct axArtCS axArtLR axVeiAct],'YLim',[-1 1].*max(abs([axArtAct.YLim axArtCS.YLim axArtLR.YLim axVeiAct.YLim])));

            if saveFlag
                filename = 'smrVesselResponses';
                disp(['Saving ' filename '.fig and ' filename '.png']);
                saveas(hF,[filename '.fig']);
                saveas(hF,[filename '.png']);
                print(hF, [filename '.svg'], '-dsvg', '-painters');
            end






        otherwise
            error('Metric not found');
    end








    function smr = smrVessel(smr,ind,avMode)
        if ~exist('avMode','var'); avMode = ''; end
        if isempty(avMode);        avMode = 'avVox'; end
        smr = smr(ind);
        if isempty(smr); return; end

        % resp       = [];
        voxDim = ismember(strsplit(smr(1).info,' x '),'vox');
        % resp.vec = {smr(ind).vec};
        % if strcmp(avMode,'avVox')
        %     for r = 1:length(resp.vec)
        %         resp.vec{r} = mean(resp.vec{r},find(voxDim));
        %     end
        % end
        % resp.vec = cat(find(voxDim),resp.vec{:});
        vec = {smr.vec};
        neg = {smr.neg};
        if strcmp(avMode,'avVox')
            for r = 1:length(vec)
                if contains(smr(r).metric,'resp_')
                    vec{r} = cat(2,...
                    mean(vec{r}(:,:,neg{r}(:)),find(voxDim)),...
                    mean(vec{r}(:,:,~neg{r}(:)),find(voxDim))...
                    )
                    neg{r} = mean(neg{r},find(voxDim));
                else
                    vec{r} = mean(vec{r},find(voxDim));
                    neg{r} = mean(neg{r},find(voxDim));
                end
            end
        end
        ind = ~cellfun('isempty',vec);
        vec = cat(find(voxDim),vec{ind});
        neg = cat(find(voxDim),neg{ind});
        
        nVox     = cat(8,smr(ind).nVox);
        nVoxNeg  = nVox(:,1,:,:,:,:,:,:,:);
        nVoxPos  = nVox(:,2,:,:,:,:,:,:,:);
        nVox     = sum(nVox,2);
        nVoxOrig = cat(8,smr(ind).nVoxRoi);

        class        = {smr.class};
        anot_actType = {smr.anot_actType};
        sub          = {smr.sub};

        
        smr = smr(1);
        smr.vec    = vec;
        smr.neg    = neg;
        smr.vecNeg = neg;
        smr.nVox = nVox;
        smr.nVoxNeg = nVoxNeg;
        smr.nVoxPos      = nVoxPos;
        smr.nVoxOrig     = nVoxOrig;
        smr.class        = permute(class,[1 3 4 5 6 7 8 2]);
        smr.anot_actType = permute(anot_actType,[1 3 4 5 6 7 8 2]);
        smr.sub          = permute(sub,[1 3 4 5 6 7 8 2]);

        if strcmp(avMode,'avVox')
            smr.info = strsplit(smr.info,' x ');
            avDim = find(ismember(smr.info,'vox'));
            smr.info{avDim} = 'vessel';
            smr.info = strjoin(smr.info,' x ');
            
            sz = repmat({'1'},1,length(size(smr.vec))); sz{avDim} = ':'; sz = strjoin(sz,',');
            okInd = eval(['~isnan(smr.vec(' sz '))']);
            smr.vecAv = mean(smr.vec,avDim,"omitnan");
            smr.vecEr = std(smr.vec,[],avDim,"omitnan")./sqrt(nnz(okInd));
        end






        % if isfield(smr(ind),'t')

        %     resp.t     = cat(3,smr(ind).t);
        %     if contains(smr(1).metric,'TrialGram')
        %         dt = abs(diff(resp.t,[],3));
        %         T = max(resp.t(end,end,:,:,:,:,end));
        %         dt = max(dt(:))./T;
        %         if dt>1e-4; error('time vector mismatch'); end
        %         % resp.t = mean(mean(resp.t - onsetList',3),2);
        %         resp.t = mean(mean(resp.t,3),2);
        %     else
        %         if any(any(diff(resp.t,[],3),3),2); error('time vector mismatch'); end
        %         resp.t     = resp.t(:,:,1);        
        %     end
        % else
        %     resp.t     = [];
        % end
        % if isfield(smr(ind),'f')
        %     resp.f     = cat(3,smr(ind).f);
        %     % resp.f(:,:,:,:,end)
        %     xVessel =      diff(resp.f(:,:,:,:,end),[],3)   ; xVessel = max(abs(xVessel(:)));
        %     xFreq   = mean(diff(resp.f             ,[],5),5); xFreq   = max(abs(xFreq(:)  ));
        %     if xVessel/xFreq>0.005; error('frequency vector mismatch'); end
        %     resp.f     = mean(resp.f,3);        
        % else
        %     resp.f     = [];
        % end
        % resp.label = cat(3,smr(ind).label);
        % if any(1~=[length(unique(resp.label(:,1,:))) length(unique(resp.label(:,2,:)))]); error('label length mismatch'); end
        % resp.label = resp.label(:,:,1);
        
        % resp.vecAv  = mean(resp.vec,3,"omitnan");
        % resp.vecN   = sum(~isnan(resp.vec),3);
        % resp.vecEr = std(resp.vec,[],3,"omitnan")./sqrt(resp.vecN);

        % resp.info = {'time' '?' 'vessel' '?' 'freq' '?'};


    function resp = smrSubject(smr,ind,avMode)
        if isempty(avMode); avMode = 'catVes-avVox'; end
        avVoxFlag = strsplit(avMode,'-');
        subList = unique({smr.sub});
        resp    = cell(length(subList),1);
        for S = 1:length(subList)
            subInd = ismember({smr.sub},subList{S});
            switch avVoxFlag{1}
                case 'avVox'
                    resp{S} = smrVessel(smr,ind&subInd,'avVox');
                    % resp{S}
                otherwise
                    resp{S} = smrVessel(smr,ind&subInd,'catVox');
            end
            if isempty(resp{S}); continue; end
            if contains(resp{S}.metric,'resp_')
                vec = [];
                voxDim = 3;
                vInd = resp{S}.neg;
                vec(:,1,:) = mean(resp{S}.vec(:,:,vInd),voxDim,"omitnan");
                vInd = ~resp{S}.neg;
                vec(:,2,:) = mean(resp{S}.vec(:,:,vInd),voxDim,"omitnan");
                resp{S}.vec = vec;
                % resp{S}.vec = permute(resp{S}.vec,[7 1 2 3 5 4 6 8]);
            else
                if strcmp(avVoxFlag{2},'catVes')
                    % resp{S}.vec = permute(resp{S}.vec,[1 2 6 4 5 3 7 8]);
                    resp{S}.vec = permute(resp{S}.vec,[7 1 6 3 5 4 2 8]);

                else
                    voxDim = 6;
                    resp{S}.vec = mean(resp{S}.vec,voxDim,"omitnan");
                    resp{S}.vec = permute(resp{S}.vec,[7 1 2 3 5 4 6 8]);
                end
            end
        end
        subInd = ~cellfun('isempty',resp);
        resp(~subInd) = [];
        
        resp = [resp{:}];
        vec = cat(3,resp.vec);
        resp(2:end) = [];
        resp.vec = vec;
        resp.vecAv = mean(resp.vec,3,"omitnan");
        resp.vecN  = sum(~isnan(resp.vec),3);
        resp.vecEr = std(resp.vec,[],3,"omitnan")./sqrt(resp.vecN);
        resp.sub = subList(subInd);
        % resp.t   = permute(resp.t,[7 1 3 5 4 6 2 8]);
        if isfield(resp,'t') && ~contains(resp.metric,'resp_')
            resp.t   = permute(resp.t,[7 1 3 5 4 6 2 8])
        end
        resp.info = {'time' 'compartment' 'sub' '???' 'freq' '???'};