function grpAvRePlt(hFfull,hFmd)
    
    artFull  = hFfull.Children.Children(4); artFull  = artFull.Children;
    veinFull = hFfull.Children.Children(1); veinFull = veinFull.Children([2 3]);
    artMd    = hFmd.Children.Children(5); artMd    = artMd.Children([1 2]);
    veinMd   = hFmd.Children.Children(2); veinMd   = veinMd.Children([2 3]);

    artCSFull  = hFfull.Children.Children(3); artCSFull  = artCSFull.Children;
    artLRFull  = hFfull.Children.Children(2); artLRFull  = artLRFull.Children;
    artCSMd    = hFmd.Children.Children(4); artCSMd    = artCSMd.Children([1 2]);
    artLRMd    = hFmd.Children.Children(3); artLRMd    = artLRMd.Children([1 2]);


    % axArtMd  = hFmd.Children.Children(5);
    % axVeinMd = hFmd.Children.Children(2);

    figure('WindowStyle','docked');
    ax = axes('Parent',gcf);
    copyobj(artFull,ax);
    copyobj(veinFull,ax);
    yLabel = artFull(1).Parent.YLabel.String;
    if contains(yLabel,'coh','IgnoreCase',true)
        set(ax,'YScale','linear','XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    else
        set(ax,'YScale','log'   ,'XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    end
    ylabel(ax,yLabel);
    title(ax,'All Arteries vs all Veins');
    saveas(gcf,'allArteriesVsAllVeins.fig');
    print(gcf, 'allArteriesVsAllVeins.svg', '-dsvg', '-painters');

    figure('WindowStyle','docked');
    ax = axes('Parent',gcf);
    hArt = copyobj(artMd,ax); hArt(1).Color = 'r';
    hVei = copyobj(veinMd,ax); hVei(1).Color = 'b';
    yLabel = artMd(1).Parent.YLabel.String;
    if contains(yLabel,'coh','IgnoreCase',true)
        set(ax,'YScale','linear','XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    else
        set(ax,'YScale','log'   ,'XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    end
    ylabel(ax,yLabel);
    title(ax,'All Arteries MD vs all Veins MD');
    saveas(gcf,'allArteriesVsAllVeins_PostStimPSD.png');
    print(gcf, 'allArteriesVsAllVeins_PostStimPSD.svg', '-dsvg', '-painters');

    figure('WindowStyle','docked');
    ax = axes('Parent',gcf);
    copyobj(artFull,ax);
    copyobj(artMd,ax);
    yLabel = artFull(1).Parent.YLabel.String;
    if contains(yLabel,'coh','IgnoreCase',true)
        set(ax,'YScale','linear','XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    else
        set(ax,'YScale','log'   ,'XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    end
    ylabel(ax,yLabel);
    title(ax,'All Arteries, Full vs MD');
    saveas(gcf,'allArteries_FullVsMD.png');
    print(gcf, 'allArteries_FullVsMD.svg', '-dsvg', '-painters');

    figure('WindowStyle','docked');
    ax = axes('Parent',gcf);
    copyobj(veinFull,ax);
    copyobj(veinMd,ax);
    yLabel = veinFull(1).Parent.YLabel.String;
    if contains(yLabel,'coh','IgnoreCase',true)
        set(ax,'YScale','linear','XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    else
        set(ax,'YScale','log'   ,'XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    end
    ylabel(ax,yLabel);
    title(ax,'All veins, Full vs MD');
    saveas(gcf,'allVeins_FullVsMD.png');
    print(gcf, 'allVeins_FullVsMD.svg', '-dsvg', '-painters');





    figure('WindowStyle','docked');
    ax = axes('Parent',gcf);
    copyobj(artCSFull,ax);
    copyobj(artCSMd,ax);
    yLabel = artCSFull(1).Parent.YLabel.String;
    if contains(yLabel,'coh','IgnoreCase',true)
        set(ax,'YScale','linear','XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    else
        set(ax,'YScale','log'   ,'XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    end
    ylabel(ax,yLabel);
    title(ax,'Center-Surround Arteries, Full vs MD');
    saveas(gcf,'allArteries_CS_FullVsMD.png');
    print(gcf, 'allArteries_CS_FullVsMD.svg', '-dsvg', '-painters');

    figure('WindowStyle','docked');
    ax = axes('Parent',gcf);
    copyobj(artLRFull,ax);
    copyobj(artLRMd,ax);
    yLabel = artLRFull(1).Parent.YLabel.String;
    if contains(yLabel,'coh','IgnoreCase',true)
        set(ax,'YScale','linear','XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    else
        set(ax,'YScale','log'   ,'XGrid','on','YGrid','on','XMinorGrid','on','YMinorGrid','on');
    end
    ylabel(ax,yLabel);
    title(ax,'Left-Right Arteries, Full vs MD');
    saveas(gcf,'allArteries_LR_FullVsMD.png');
    print(gcf, 'allArteries_LR_FullVsMD.svg', '-dsvg', '-painters');


