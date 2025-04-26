function test_keyboard_ssh()
    % Test keyboard input in a figure, optimized for SSH+X11 forwarding
    
    % Create a figure with a white background
    fig = figure('Name', 'Keyboard Test (SSH)', 'Color', 'white', ...
                'Position', [100, 100, 500, 300]);
    
    % Create clear instructions in the figure
    uicontrol('Style', 'text', 'Position', [50, 200, 400, 50], ...
        'String', 'Press any key. The response will appear below. Press q to quit.', ...
        'BackgroundColor', 'white', 'FontSize', 12, ...
        'HorizontalAlignment', 'center');
    
    % Create feedback area
    feedback = uicontrol('Style', 'text', 'Position', [50, 100, 400, 50], ...
        'String', 'Waiting for keypress...', ...
        'BackgroundColor', [0.9 0.9 1], 'FontSize', 14, ...
        'HorizontalAlignment', 'center');
    
    % Create history panel
    history_panel = uicontrol('Style', 'listbox', 'Position', [50, 50, 400, 100], ...
        'String', {}, 'BackgroundColor', 'white', ...
        'HorizontalAlignment', 'left');
    
    % Initialize user data
    fig.UserData.keyHistory = {};
    fig.UserData.feedback = feedback;
    fig.UserData.history_panel = history_panel;
    fig.UserData.done = false;
    
    % Set up key press callback
    set(fig, 'KeyPressFcn', @keypress_callback_ssh);
    
    % Wait until done flag is set
    while ~fig.UserData.done && ishandle(fig)
        pause(0.1);  % Smaller pause time for better responsiveness
    end
    
    % Display final results if figure still exists
    if ishandle(fig)
        % Save results to a file
        try
            save('ssh_keyboard_test_results.mat', 'fig');
            disp('Test results saved to ssh_keyboard_test_results.mat');
        catch
            disp('Could not save test results.');
        end
        
        % Close the figure
        close(fig);
    end
end

function keypress_callback_ssh(src, event)
    % Callback for keypresses optimized for SSH use
    keyMsg = ['Key pressed: ' event.Key ' (' event.Character ')'];
    
    % Update the feedback display
    src.UserData.feedback.String = keyMsg;
    src.UserData.feedback.BackgroundColor = [0.8 1 0.8];  % Light green
    
    % Add to history
    src.UserData.keyHistory{end+1} = keyMsg;
    
    % Update the history panel
    src.UserData.history_panel.String = src.UserData.keyHistory;
    src.UserData.history_panel.Value = length(src.UserData.keyHistory);
    
    % Check for quit
    if strcmp(event.Key, 'q')
        src.UserData.feedback.String = 'Test complete. Closing...';
        src.UserData.feedback.BackgroundColor = [1 0.8 0.8];  % Light red
        src.UserData.done = true;
    end
end 