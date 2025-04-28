function add_keypress_launcher(figHandle)
    % ADD_KEYPRESS_LAUNCHER - Adds keyboard test launcher to any figure
    %
    % This function adds a keyboard event handler to an existing figure that
    % will launch a keyboard testing GUI when 'm' is pressed.
    %
    % Usage:
    %   add_keypress_launcher(figHandle);
    %
    % INPUTS:
    %   figHandle - Handle to the figure where the keyboard launcher should be added
    %
    % Example:
    %   fig = figure;
    %   plot(1:10);
    %   add_keypress_launcher(fig);
    %   % Now pressing 'm' on the figure will launch the keyboard test
    
    % Check if a valid figure handle was provided
    if ~ishandle(figHandle) || ~strcmp(get(figHandle, 'Type'), 'figure')
        error('Input must be a valid figure handle');
    end
    
    % Get the current KeyPressFcn callback (if any)
    currentCallback = get(figHandle, 'KeyPressFcn');
    
    % Store the original callback in the figure's UserData
    if ~isfield(figHandle.UserData, 'originalKeyPressFcn')
        figHandle.UserData.originalKeyPressFcn = currentCallback;
    end
    
    % Set the new callback
    set(figHandle, 'KeyPressFcn', @launch_keypress_test_callback);
    
    % Add a message to the figure to inform the user
    try
        % Create an axes for the message
        msgAxes = axes('Parent', figHandle, ...
                       'Position', [0.01, 0.01, 0.25, 0.05], ...
                       'Visible', 'off', ...
                       'Tag', 'KeypressLauncherInfo');
        
        % Add text with the instruction
        text(0.1, 0.5, 'Press ''m'' to launch keyboard test', ...
             'Parent', msgAxes, ...
             'HorizontalAlignment', 'left', ...
             'FontSize', 8, ...
             'Color', [0.4 0.4 1]);
    catch
        % Do nothing if we can't add the message
    end
    
    % Print a confirmation message
    fprintf('Keyboard test launcher added to figure %d\n', figHandle.Number);
    fprintf('Press ''m'' while the figure has focus to launch the keyboard test\n');
end 