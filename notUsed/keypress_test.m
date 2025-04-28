function keypress_test()
    % KEYPRESS_TEST - Create a GUI for testing and displaying keypresses
    %
    % This function creates a figure with a KeyPressFcn callback to display
    % keypress events. Useful for testing keyboard input, especially in
    % environments where command window updates may be unreliable (e.g., SSH
    % with X11 forwarding).
    %
    % Press 'q' to quit the test and save key history to 'key_history.txt'.
    
    % Create figure with specific properties for key testing
    fig = figure('Name', 'Keypress Test', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Position', [100, 100, 500, 400]);
    
    % Initialize user data structure to store key history
    fig.UserData = struct('keyHistory', {{}}, 'done', false);
    
    % Create axes for instructions
    instructAxes = axes('Parent', fig, ...
                       'Position', [0.1, 0.1, 0.8, 0.3], ...
                       'XColor', 'none', ...
                       'YColor', 'none');
    
    % Add instructions text
    text(0.5, 0.5, {'KEYPRESS TEST', '', ...
                   'Press any key to see its code', ...
                   'Press ''q'' to quit'}, ...
         'Parent', instructAxes, ...
         'HorizontalAlignment', 'center', ...
         'FontSize', 14);
    
    % Create axes for key history display
    historyAxes = axes('Parent', fig, ...
                      'Position', [0.1, 0.4, 0.8, 0.3], ...
                      'XColor', 'none', ...
                      'YColor', 'none');
    
    % Create text object for history display
    fig.UserData.historyHandle = text(0.1, 0.9, 'Key History:', ...
                                     'Parent', historyAxes, ...
                                     'HorizontalAlignment', 'left', ...
                                     'VerticalAlignment', 'top', ...
                                     'FontSize', 14);
    
    % Set the KeyPressFcn callback
    set(fig, 'KeyPressFcn', @keypress_gui_callback);
    
    % Keep figure open until user quits
    fprintf('Keypress test active. Press keys to test, ''q'' to quit.\n');
    
    % Main loop to keep the figure active until user quits
    while ~fig.UserData.done && ishandle(fig)
        pause(0.1);  % Small pause to prevent CPU hogging
    end
    
    % Clean up
    if ishandle(fig)
        close(fig);
    end
    
    fprintf('Keypress test completed.\n');
end 