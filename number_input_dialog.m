function result = number_input_dialog()
    % Create a dialog for inputting a number
    % Returns the input number when the dialog is closed
    
    % Create figure
    fig = figure('Name', 'Number Input', 'Position', [300, 300, 400, 200], ...
        'MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off');
    fig.UserData.result = [];
    
    % Create input field
    uicontrol('Style', 'text', 'Position', [50, 150, 300, 20], ...
        'String', 'Enter a number:', 'HorizontalAlignment', 'left');
    
    edit = uicontrol('Style', 'edit', 'Position', [50, 120, 300, 25], ...
        'String', '', 'HorizontalAlignment', 'left', 'BackgroundColor', 'white');
    
    % Create submit button
    submit_btn = uicontrol('Style', 'pushbutton', 'Position', [50, 80, 100, 25], ...
        'String', 'Submit', 'Callback', @submit_callback);
    
    % Create status text area
    status = uicontrol('Style', 'text', 'Position', [50, 40, 300, 20], ...
        'String', 'Waiting for input...', 'HorizontalAlignment', 'left');
    
    % Create close button
    close_btn = uicontrol('Style', 'pushbutton', 'Position', [250, 80, 100, 25], ...
        'String', 'Close', 'Callback', @close_callback);
    
    % Wait for the figure to close
    uiwait(fig);
    
    % Return the result
    if ishandle(fig)
        result = fig.UserData.result;
        delete(fig);
    else
        result = [];
    end
    
    % Callback functions
    function submit_callback(~, ~)
        try
            num = str2double(edit.String);
            if isnan(num)
                status.String = 'Invalid number! Try again.';
                status.ForegroundColor = [1 0 0]; % Red
            else
                fig.UserData.result = num;
                status.String = ['Number recorded: ' num2str(num)];
                status.ForegroundColor = [0 0.5 0]; % Green
                
                % Print to command window as well
                disp(['Number recorded: ' num2str(num)]);
                commandwindow;
            end
        catch e
            status.String = ['Error: ' e.message];
            status.ForegroundColor = [1 0 0]; % Red
        end
    end
    
    function close_callback(~, ~)
        uiresume(fig);
    end
end 