function keypress_test_callback(src, event)
    % Callback function for key press events
    keyMsg = ['Key pressed: ' event.Key];
    
    % Get the figure handle
    fig = gcbf;
    
    % Create or update feedback text in the figure itself
    if ~isfield(fig.UserData, 'textHandle')
        % Create text object for feedback
        fig.UserData.textHandle = uicontrol('Style', 'text', ...
            'Position', [10, 10, 300, 30], ...
            'String', keyMsg, ...
            'BackgroundColor', fig.Color, ...
            'HorizontalAlignment', 'left');
    else
        % Update existing text
        fig.UserData.textHandle.String = keyMsg;
    end
    
    % Store history of keypresses in figure UserData
    if ~isfield(fig.UserData, 'keyHistory')
        fig.UserData.keyHistory = {};
    end
    fig.UserData.keyHistory{end+1} = keyMsg;
    
    % Check for quit command
    if strcmp(event.Key, 'q')
        % Display final message in the figure
        if isfield(fig.UserData, 'textHandle')
            fig.UserData.textHandle.String = 'Exiting test figure...';
            fig.UserData.textHandle.ForegroundColor = [1 0 0]; % Red
        end
        
        % Write history to file instead of console
        fid = fopen('key_history.txt', 'w');
        if fid > 0
            fprintf(fid, 'Key press history:\n');
            for i = 1:length(fig.UserData.keyHistory)
                fprintf(fid, '%s\n', fig.UserData.keyHistory{i});
            end
            fclose(fid);
        end
        
        fig.UserData.done = true;
    end
end