function integrate_keypress_test()
    % INTEGRATE_KEYPRESS_TEST - Instructions for integrating keyboard test with QAdendrogram
    %
    % This function provides instructions for integrating the keyboard test
    % with your QAdendrogram function. It does not execute any code, it just
    % displays the integration steps.
    
    fprintf('\n=========================================\n');
    fprintf('How to integrate keyboard test with QAdendrogram\n');
    fprintf('=========================================\n\n');
    
    fprintf('METHOD 1: Apply to an existing figure handle\n');
    fprintf('-----------------------------------------\n');
    fprintf('If you have a figure handle from QAdendrogram:\n\n');
    fprintf('    [kI, k, hFig, fClust, mainClust] = QAdendrogram(...);\n');
    fprintf('    add_keypress_launcher(hFig); % Add keyboard test launcher\n\n');
    
    fprintf('METHOD 2: Modify QAdendrogram.m\n');
    fprintf('-----------------------------------------\n');
    fprintf('Add this code after creating the figure in QAdendrogram.m:\n\n');
    fprintf('    %% Add keyboard test launcher\n');
    fprintf('    try\n');
    fprintf('        add_keypress_launcher(hFig);\n');
    fprintf('    catch\n');
    fprintf('        warning(''Could not add keyboard test launcher to figure'');\n');
    fprintf('    end\n\n');
    
    fprintf('METHOD 3: Add an extra option to QAdendrogram\n');
    fprintf('-----------------------------------------\n');
    fprintf('Modify the QAdendrogram function to accept an optional parameter:\n\n');
    fprintf('    function [kI,k,hFig,fClust,mainClust] = QAdendrogram(fig,force,verbose,addKeyboardTest)\n');
    fprintf('        if ~exist(''addKeyboardTest'',''var''); addKeyboardTest = false; end\n');
    fprintf('        ...\n');
    fprintf('        %% After figure creation\n');
    fprintf('        if addKeyboardTest\n');
    fprintf('            try\n');
    fprintf('                add_keypress_launcher(hFig);\n');
    fprintf('            catch\n');
    fprintf('                warning(''Could not add keyboard test launcher to figure'');\n');
    fprintf('            end\n');
    fprintf('        end\n');
    
    fprintf('\n=========================================\n');
    fprintf('USAGE EXAMPLE:\n');
    fprintf('=========================================\n\n');
    fprintf('Example 1: Add to existing figure\n');
    fprintf('    [kI, k, hFig] = QAdendrogram(rCond{S}.(acq).QA.fXCorr,1,verboseThis);\n');
    fprintf('    add_keypress_launcher(hFig);\n\n');
    
    fprintf('Example 2: With modified QAdendrogram\n');
    fprintf('    [kI, k, hFig] = QAdendrogram(rCond{S}.(acq).QA.fXCorr,1,verboseThis,true);\n\n');
    
    fprintf('=========================================\n');
end 