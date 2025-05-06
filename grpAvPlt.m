function grpAvPlt(roi,subList,acq,task,metric,pltType)
    if ~exist('pltType','var'); pltType = []; end

    vessels       = [];
    vesselsSub    = {};
    vesselsAcq    = {};
    vesselsTask   = {};
    for S = 1:size(subList,1)
        if ~isfield(roi{S},acq) || isempty(roi{S}.(acq)); continue; end
        if ~isfield(roi{S}.(acq),task) || isempty(roi{S}.(acq).(task)); continue; end
        vessels = cat(1,vessels,roi{S}.(acq).(task).vessel);
        vesselsSub = cat(1,vesselsSub,repmat(subList(S),size(roi{S}.(acq).(task).vessel)));
        vesselsAcq = cat(1,vesselsAcq,repmat({acq},size(roi{S}.(acq).(task).vessel)));
        vesselsTask = cat(1,vesselsTask,repmat({task},size(roi{S}.(acq).(task).vessel)));
        % {roi{S}.(acq).(task).vessel.class}
        % [roi{S}.(acq).(task).vessel.anot_sig]
        % {roi{S}.(acq).(task).vessel.anot_actType}
    end
    [vessels.sub]  = deal(vesselsSub{:});  clear vesselsSub
    [vessels.acq]  = deal(vesselsAcq{:});  clear vesselsAcq
    [vessels.task] = deal(vesselsTask{:}); clear vesselsTask
    % %%% remove inactive vessels
    % vessels(~[vessels.anot_sig]) = [];

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

    %% Colate data across vessels
    artAct   = smrVessel(smr,ismember({smr.class},'artery') & ~ismember({smr.anot_actType},'non-sig')        ,onsetList);
    artCS    = smrVessel(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'center-surround'),onsetList);
    artLR    = smrVessel(smr,ismember({smr.class},'artery') &  ismember({smr.anot_actType},'left-right')     ,onsetList);
    artInact = smrVessel(smr,ismember({smr.class},'artery') & ~ismember({smr.anot_actType},'non-sig')        ,onsetList);
    veiAct   = smrVessel(smr,ismember({smr.class},'vein'  ) & ~ismember({smr.anot_actType},'non-sig')        ,onsetList);
    veiInact = smrVessel(smr,ismember({smr.class},'vein'  ) &  ismember({smr.anot_actType},'non-sig')        ,onsetList);

    

    switch metric
        case 'psdTrialGram_dilate1_actQ'
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
                    % Active arteries subplot
                    dat = artAct;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,[5 7 3 2 4 6 1 8]);
                    y   =  permute(dat.f,[5 7 3 2 4 6 1 8]);
                    zAv =  permute(dat.vecAv ,[5 7 3 2 4 6 1 8]);
                    zEr =  permute(dat.vecErr,[5 7 3 2 4 6 1 8]);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);
                    h = imagesc(ax{end},x,y,zAv);
                    xline(ax{end},x(b),'--k');
                    xline(ax{end},x(end),'--k');
                    title(ax{end},['All Active Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    ylabel('Frequency (Hz)');
                    xlabel('time post-stim onset (s)');
                    grid on;
                    axis tight;
                    yLim = ylim;
                    line(ax{end},x(b)  +[-0.5 0.5].*winSz,yLim(2)*[0.99 0.99],'linestyle','-','color','k','linewidth',3);
                    line(ax{end},x(end)+[-0.5 0.5].*winSz,yLim(2)*[0.97 0.97],'linestyle','-','color','k','linewidth',3);
                    


                    % CS arteries subplot
                    dat = artCS;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,[5 7 3 2 4 6 1 8]);
                    y   =  permute(dat.f,[5 7 3 2 4 6 1 8]);
                    zAv =  permute(dat.vecAv ,[5 7 3 2 4 6 1 8]);
                    zEr =  permute(dat.vecErr,[5 7 3 2 4 6 1 8]);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);
                    h = imagesc(ax{end},x,y,zAv);
                    xline(ax{end},x(b),'--k');
                    xline(ax{end},x(end),'--k');
                    title(ax{end},['Center-Surround Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    ylabel('Frequency (Hz)');
                    xlabel('time post-stim onset (s)');
                    grid on;
                    axis tight;
                    yLim = ylim;
                    line(ax{end},x(b)  +[-0.5 0.5].*winSz,yLim(2)*[0.99 0.99],'linestyle','-','color','k','linewidth',3);
                    line(ax{end},x(end)+[-0.5 0.5].*winSz,yLim(2)*[0.97 0.97],'linestyle','-','color','k','linewidth',3);
                    

                    % LR arteries subplot
                    dat = artLR;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,[5 7 3 2 4 6 1 8]);
                    y   =  permute(dat.f,[5 7 3 2 4 6 1 8]);
                    zAv =  permute(dat.vecAv ,[5 7 3 2 4 6 1 8]);
                    zEr =  permute(dat.vecErr,[5 7 3 2 4 6 1 8]);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);
                    h = imagesc(ax{end},x,y,zAv);
                    xline(ax{end},x(b),'--k');
                    xline(ax{end},x(end),'--k');
                    title(ax{end},['Left-Right Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    ylabel('Frequency (Hz)');
                    xlabel('time post-stim onset (s)');
                    grid on;
                    axis tight;
                    yLim = ylim;
                    line(ax{end},x(b)  +[-0.5 0.5].*winSz,yLim(2)*[0.99 0.99],'linestyle','-','color','k','linewidth',3);
                    line(ax{end},x(end)+[-0.5 0.5].*winSz,yLim(2)*[0.97 0.97],'linestyle','-','color','k','linewidth',3);
                    

                    % Active veins subplot
                    dat = veiAct;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,[5 7 3 2 4 6 1 8]);
                    y   =  permute(dat.f,[5 7 3 2 4 6 1 8]);
                    zAv =  permute(dat.vecAv ,[5 7 3 2 4 6 1 8]);
                    zEr =  permute(dat.vecErr,[5 7 3 2 4 6 1 8]);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);
                    h = imagesc(ax{end},x,y,zAv);
                    xline(ax{end},x(b),'--k');
                    xline(ax{end},x(end),'--k');
                    title(ax{end},['All Active Vein (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'vein'))) ')']);
                    ylabel('Frequency (Hz)');
                    xlabel('time post-stim onset (s)');
                    grid on;
                    axis tight;
                    yLim = ylim;
                    line(ax{end},x(b)  +[-0.5 0.5].*winSz,yLim(2)*[0.99 0.99],'linestyle','-','color','k','linewidth',3);
                    line(ax{end},x(end)+[-0.5 0.5].*winSz,yLim(2)*[0.97 0.97],'linestyle','-','color','k','linewidth',3);
                    


                    ax = [ax{:}];
                    axis(ax,'tight');
                    cLim = get(ax,'CLim'); if iscell(cLim); cLim = cat(1,cLim{:}); end; cLim = [min(cLim(:,1)) max(cLim(:,2))];
                    set(ax,'CLim',cLim,'ColorScale','log','YDir','normal','XLim',[0 mean(diff(onsetList))]);



                    size(dat.t)
                    roi{1}.(acq).(task).vessel(1).mt.psdTrialGram.param.dsgn
                    
                    K     = roi{1}.(acq).(task).vessel(1).mt.psdTrialGram.K;
                    param = roi{1}.(acq).(task).vessel(1).mt.psdTrialGram.param;
                    N     = length(param.dsgn.onsetList)*param.dsgn.win(1);
                    Fs    = param.Fs;
                    T     = N/Fs;
                    [TW,W,K] = K2W(T,K);

                    line(ax(end),x(b)  .* [1 1],yLim(2)+[-2*W 0],'linestyle','-','color','r','linewidth',2);
                    line(ax(end),x(end).* [1 1],yLim(2)+[-2*W 0],'linestyle','-','color','r','linewidth',2);
                                        

                    saveas(hF,'smrVesselTimeFreqPSD.fig');
                    saveas(hF,'smrVesselTimeFreqPSD.png');
            

                case 'freq'
                    % Active arteries subplot
                    dat = artAct;
                    ax{end+1} = nexttile(ht);
                    x   =  permute(dat.t,[5 7 3 2 4 6 1 8]);
                    y   =  permute(dat.f,[5 7 3 2 4 6 1 8]);
                    zAv =  permute(dat.vecAv ,[5 7 3 2 4 6 1 8]);
                    zEr =  permute(dat.vecErr,[5 7 3 2 4 6 1 8]);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);

                    hHyper     = shplot2(y, zAv(:,b), zEr(:,b), ax{end}, '-k'); delete([hHyper.upper hHyper.lower]);
                    hold on;
                    hPostHyper = shplot2(y, zAv(:,end), zEr(:,end), ax{end}, '--k'); delete([hPostHyper.upper hPostHyper.lower]);
                    
                    title(ax{end},['All Active Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    xlabel('Frequency (Hz)');
                    ylabel('PSD');
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
                    x   =  permute(dat.t,[5 7 3 2 4 6 1 8]);
                    y   =  permute(dat.f,[5 7 3 2 4 6 1 8]);
                    zAv =  permute(dat.vecAv ,[5 7 3 2 4 6 1 8]);
                    zEr =  permute(dat.vecErr,[5 7 3 2 4 6 1 8]);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);

                    hHyper     = shplot2(y, zAv(:,b), zEr(:,b), ax{end}, '-k'); delete([hHyper.upper hHyper.lower]);
                    hold on;
                    hPostHyper = shplot2(y, zAv(:,end), zEr(:,end), ax{end}, '--k'); delete([hPostHyper.upper hPostHyper.lower]);
                    
                    title(ax{end},['Center-Surround Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    xlabel('Frequency (Hz)');
                    ylabel('PSD');
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
                    x   =  permute(dat.t,[5 7 3 2 4 6 1 8]);
                    y   =  permute(dat.f,[5 7 3 2 4 6 1 8]);
                    zAv =  permute(dat.vecAv ,[5 7 3 2 4 6 1 8]);
                    zEr =  permute(dat.vecErr,[5 7 3 2 4 6 1 8]);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);

                    hHyper     = shplot2(y, zAv(:,b), zEr(:,b), ax{end}, '-k'); delete([hHyper.upper hHyper.lower]);
                    hold on;
                    hPostHyper = shplot2(y, zAv(:,end), zEr(:,end), ax{end}, '--k'); delete([hPostHyper.upper hPostHyper.lower]);
                    
                    title(ax{end},['Center-Surround Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
                    xlabel('Frequency (Hz)');
                    ylabel('PSD');
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
                    x   =  permute(dat.t,[5 7 3 2 4 6 1 8]);
                    y   =  permute(dat.f,[5 7 3 2 4 6 1 8]);
                    zAv =  permute(dat.vecAv ,[5 7 3 2 4 6 1 8]);
                    zEr =  permute(dat.vecErr,[5 7 3 2 4 6 1 8]);
                    [a,b] = min(abs(x(1,:,1,1,1,1,1)));
                    winSz = mean(diff(x,[],7));
                    x = mean(x,7);

                    hHyper     = shplot2(y, zAv(:,b), zEr(:,b), ax{end}, '-k'); delete([hHyper.upper hHyper.lower]);
                    hold on;
                    hPostHyper = shplot2(y, zAv(:,end), zEr(:,end), ax{end}, '--k'); delete([hPostHyper.upper hPostHyper.lower]);
                    
                    title(ax{end},['All Active Veins (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'vein'))) ')']);
                    xlabel('Frequency (Hz)');
                    ylabel('PSD');
                    % legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
                    grid on;
                    axis tight;
                    hHyper.patch.FaceAlpha = 0.2;
                    hHyper.patch.FaceColor = 'k';
                    hPostHyper.patch.FaceAlpha = 0.2;
                    hPostHyper.patch.FaceColor = 'k';


                    ax = [ax{:}];
                    axis(ax,'tight');
                    yLim = get(ax,'YLim'); if iscell(yLim); yLim = cat(1,yLim{:}); end; yLim = [min(yLim(:,1)) max(yLim(:,2))];
                    set(ax,'YLim',yLim,'YScale','log');

                    legend([hHyper.line hPostHyper.line], {'hyperhemia' 'post-hyperhemia'}, 'Location', 'northeast','AutoUpdate','off');
                    

                    

                    K     = roi{1}.(acq).(task).vessel(1).mt.psdTrialGram.K;
                    param = roi{1}.(acq).(task).vessel(1).mt.psdTrialGram.param;
                    N     = length(param.dsgn.onsetList)*param.dsgn.win(1);
                    Fs    = param.Fs;
                    T     = N/Fs;
                    [TW,W,K] = K2W(T,K);

                    xLim = xlim;
                    yLim = ylim;
                    line(ax(end),mean(xLim) + [-W W],yLim(2).*[1 1],'linestyle','-','color','r','linewidth',2);
                    
                    saveas(hF,'smrVesselPrePostPSD.fig');
                    saveas(hF,'smrVesselPrePostPSD.png');
        

                otherwise
                    error('Invalid plot type');
            end

            
            


        case 'psd_dilate1_actQ'
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
            yEr = permute(dat.vecErr,[5 1 3 2 4 6 7 8]);
            h = shplot2(x, yAv, yEr, ax{end}, '-r'); delete([h.upper h.lower]);
            title(ax{end},['All Active Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
            xlabel('Frequency (Hz)');
            ylabel('PSD');
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
            yEr = permute(dat.vecErr,[5 1 3 2 4 6 7 8]);
            h = shplot2(x, yAv, yEr, ax{end}, '-r'); delete([h.upper h.lower]);
            title(ax{end},['Center-Surround Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
            xlabel('Frequency (Hz)');
            ylabel('PSD');
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
            yEr = permute(dat.vecErr,[5 1 3 2 4 6 7 8]);
            h = shplot2(x, yAv, yEr, ax{end}, '-r'); delete([h.upper h.lower]);
            title(ax{end},['Left-Right Arteries (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'artery'))) ')']);
            xlabel('Frequency (Hz)');
            ylabel('PSD');
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
            yEr = permute(dat.vecErr,[5 1 3 2 4 6 7 8]);
            h = shplot2(x, yAv, yEr, ax{end}, '-b'); delete([h.upper h.lower]);
            title(ax{end},['All Active Veins (n=' num2str(size(dat.vec,3)) '/' num2str(nnz(ismember({smr.class},'vein'))) ')']);
            xlabel('Frequency (Hz)');
            ylabel('PSD');
            % legend([hArtActNeg.line, hArtActPos.line], strcat(artAct.label,'Vox'), 'Location', 'best');
            grid on;
            axis tight;
            h.patch.FaceAlpha = 0.2;
            h.patch.FaceColor = 'b';

            ax = [ax{:}];
            axis(ax,'tight');
            yLim = get(ax,'YLim'); if iscell(yLim); yLim = cat(1,yLim{:}); end; yLim = [min(yLim(:,1)) max(yLim(:,2))];
            set(ax,'YLim',yLim,'YScale','log');
            



            K     = roi{1}.(acq).(task).vessel(1).mt.psd.K;
            param = roi{1}.(acq).(task).vessel(1).mt.psd.param;
            N     = 300;
            Fs    = param.Fs;
            T     = N/Fs;
            [TW,W,K] = K2W(T,K);

            xLim = xlim;
            yLim = ylim;
            line(ax(end),mean(xLim) + [-W W],yLim(2).*[1 1],'linestyle','-','color','r','linewidth',2);
            



            saveas(hF,'smrVesselFullPSD.fig');
            saveas(hF,'smrVesselFullPSD.png');
            

        case 'resp_dilate1_actQ_actSgn'
            %% Time-domain responses
            hF = figure('WindowStyle','docked');
            ht = tiledlayout(2,3);
            ht.TileSpacing = 'tight';
            ht.Padding = 'tight';

            % Active arteries subplot
            axArtAct = nexttile(ht);
            hArtActNeg = shplot2(artAct.t, artAct.vecAv(:,1), artAct.vecErr(:,1), axArtAct, '-.r'); delete([hArtActNeg.upper hArtActNeg.lower]);
            hold on;
            hArtActPos = shplot2(artAct.t, artAct.vecAv(:,2), artAct.vecErr(:,2), axArtAct, '-r'); delete([hArtActPos.upper hArtActPos.lower]);
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
            hArtCSNeg = shplot2(artCS.t, artCS.vecAv(:,1), artCS.vecErr(:,1), axArtCS, '-.r'); delete([hArtCSNeg.upper hArtCSNeg.lower]);
            hold on;
            hArtCSPos = shplot2(artCS.t, artCS.vecAv(:,2), artCS.vecErr(:,2), axArtCS, '-r'); delete([hArtCSPos.upper hArtCSPos.lower]);
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
            hArtLRNeg = shplot2(artLR.t, artLR.vecAv(:,1), artLR.vecErr(:,1), axArtLR, '-.r'); delete([hArtLRNeg.upper hArtLRNeg.lower]);
            hold on;
            hArtLRPos = shplot2(artLR.t, artLR.vecAv(:,2), artLR.vecErr(:,2), axArtLR, '-r'); delete([hArtLRPos.upper hArtLRPos.lower]);
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
            hVeiActPos = shplot2(veiAct.t, veiAct.vecAv(:,2), veiAct.vecErr(:,2), axVeiAct, '-b'); delete([hVeiActPos.upper hVeiActPos.lower]);
            title(axVeiAct,['All Active Veins (n=' num2str(size(veiAct.vec,3)) '/' num2str(nnz(ismember({smr.class},'vein'))) ')']);
            xlabel('time post-stim onset (s)');
            ylabel('MR signal change');
            grid on;
            axis tight;
            hVeiActPos.patch.FaceAlpha = 0.2;
            hVeiActPos.patch.FaceColor = 'b';

            set([axArtAct axArtCS axArtLR axVeiAct],'YLim',[-1 1].*max(abs([axArtAct.YLim axArtCS.YLim axArtLR.YLim axVeiAct.YLim])));

            saveas(hF,'smrVesselResponses.fig');
            saveas(hF,'smrVesselResponses.png');






        otherwise
            error('Metric not found');
    end








    function resp = smrVessel(smr,ind,onsetList)
        resp       = [];
        resp.vec   = cat(3,smr(ind).vec);
        if isfield(smr(ind),'t')

            resp.t     = cat(3,smr(ind).t);
            if contains(smr(1).metric,'TrialGram')
                dt = abs(diff(resp.t,[],3));
                T = max(resp.t(end,end,:,:,:,:,end));
                dt = max(dt(:))./T;
                if dt>1e-5; error('time vector mismatch'); end
                resp.t = mean(mean(resp.t - onsetList',3),2);
            else
                if any(any(diff(resp.t,[],3),3),2); error('time vector mismatch'); end
                resp.t     = resp.t(:,:,1);        
            end
        else
            resp.t     = [];
        end
        if isfield(smr(ind),'f')
            resp.f     = cat(3,smr(ind).f);
            resp.f(:,:,:,:,end)
            xVessel =      diff(resp.f(:,:,:,:,end),[],3)   ; xVessel = max(abs(xVessel(:)));
            xFreq   = mean(diff(resp.f             ,[],5),5); xFreq   = max(abs(xFreq(:)  ));
            if xVessel/xFreq>0.005; error('frequency vector mismatch'); end
            resp.f     = mean(resp.f,3);        
        else
            resp.f     = [];
        end
        resp.label = cat(3,smr(ind).label);
        if any(1~=[length(unique(resp.label(:,1,:))) length(unique(resp.label(:,2,:)))]); error('label length mismatch'); end
        resp.label = resp.label(:,:,1);
        
        resp.vecAv  = mean(resp.vec,3,"omitnan");
        resp.vecN   = sum(~isnan(resp.vec),3);
        resp.vecErr = std(resp.vec,[],3,"omitnan")./sqrt(resp.vecN);

        resp.info = {'time' '?' 'vessel' '?' 'freq' '?'};