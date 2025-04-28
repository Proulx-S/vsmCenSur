function launch_keypress_test_callback(src, event)
    % LAUNCH_KEYPRESS_TEST_CALLBACK - Launches keyboard test when 'm' is pressed
    %
    % This callback can be attached to any MATLAB figure to launch
    % the interactive keyboard testing GUI when the 'm' key is pressed.
    %
    % Usage:
    %   set(figureHandle, 'KeyPressFcn', @launch_keypress_test_callback);
    %
    % INPUTS:
    %   src   - Source of the callback (figure handle)
    %   event - Event data containing information about the key press
    
    % Check if 'm' was pressed
    if strcmpi(event.Key, 'm')
        % Show feedback in the figure that 'm' was detected
        fprintf('M key detected. Launching keyboard test GUI...\n');
        
        % Try to show feedback in the figure itself
        try
            % Create temporary text overlay in the current figure
            axes('Position', [0.3, 0.7, 0.4, 0.2], ...
                 'Parent', src, ...
                 'Visible', 'off', ...
                 'Tag', 'TempNotification');
            
            text(0.5, 0.5, 'Launching keyboard test GUI...', ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 14, ...
                'FontWeight', 'bold', ...
                'Color', 'blue');
            
            drawnow; % Force display update
            pause(1); % Show message briefly
            
            % Delete the temporary notification
            delete(findobj(src, 'Tag', 'TempNotification'));
        catch
            % Do nothing if we can't add text to the figure
        end
        
        % Launch the keyboard test GUI
        keypress_test();
    end
    
    % Let the original callback (if any) handle the keypress
    if isfield(src.UserData, 'originalKeyPressFcn') && ~isempty(src.UserData.originalKeyPressFcn)
        src.UserData.originalKeyPressFcn(src, event);
    end
end 