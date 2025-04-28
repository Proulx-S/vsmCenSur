function keypress_gui_callback(src, event)
    % KEYPRESS_GUI_CALLBACK - Handles key press events in a figure and displays them
    %
    % This callback function captures keypress events, displays the pressed key
    % in the GUI, and maintains a history of the last 5 keys pressed.
    % Optimized for SSH+X11 forwarding where command window updates may be unreliable.
    %
    % INPUTS:
    %   src   - Source of the callback (figure handle)
    %   event - Event data containing information about the key press
    %
    % Key 'q' will quit the application and save the key history to 'key_history.txt'
    
    % Get the pressed key and any modifiers
    key = event.Key;
    modifier = '';
    
    if ~isempty(event.Modifier)
        modifier = strjoin(event.Modifier, '+');
        modifier = [modifier '+'];
    end
    
    % Display the key press information in the figure
    fig = src;
    
    % Check if key display axes already exists, otherwise create it
    if ~isfield(fig.UserData, 'keypressAxes') || ~ishandle(fig.UserData.keypressAxes)
        fig.UserData.keypressAxes = axes('Parent', fig, ...
                                       'Position', [0.1, 0.7, 0.8, 0.2], ...
                                       'XColor', 'none', ...
                                       'YColor', 'none');
        fig.UserData.keypressHandle = text(0.5, 0.5, '', ...
                                         'Parent', fig.UserData.keypressAxes, ...
                                         'HorizontalAlignment', 'center', ...
                                         'FontSize', 18, ...
                                         'FontWeight', 'bold');
    end
    
    % Update the key display
    keyDisplay = [modifier key];
    set(fig.UserData.keypressHandle, 'String', ['Pressed: ' keyDisplay]);
    
    % Update key history (keep last 5 keys)
    if ~isfield(fig.UserData, 'keyHistory')
        fig.UserData.keyHistory = {};
    end
    
    % Add new key to history
    fig.UserData.keyHistory{end+1} = keyDisplay;
    
    % Keep only the last 5 entries
    if length(fig.UserData.keyHistory) > 5
        fig.UserData.keyHistory = fig.UserData.keyHistory(end-4:end);
    end
    
    % Format and display the key history
    historyStr = 'Key History:';
    for i = 1:length(fig.UserData.keyHistory)
        historyStr = [historyStr newline num2str(i) ': ' fig.UserData.keyHistory{i}];
    end
    
    % Update the history display
    if isfield(fig.UserData, 'historyHandle') && ishandle(fig.UserData.historyHandle)
        set(fig.UserData.historyHandle, 'String', historyStr);
    end
    
    % Check for quit command ('q' key)
    if strcmpi(key, 'q')
        % Save key history to file
        try
            fid = fopen('key_history.txt', 'w');
            if fid ~= -1
                fprintf(fid, 'Key History:\n');
                for i = 1:length(fig.UserData.keyHistory)
                    fprintf(fid, '%d: %s\n', i, fig.UserData.keyHistory{i});
                end
                fclose(fid);
                
                % Display quitting message in GUI
                quitAxes = axes('Parent', fig, ...
                               'Position', [0.2, 0.7, 0.6, 0.2], ...
                               'XColor', 'none', ...
                               'YColor', 'none');
                text(0.5, 0.5, 'Quitting... Key history saved to key_history.txt', ...
                     'Parent', quitAxes, ...
                     'HorizontalAlignment', 'center', ...
                     'FontSize', 14, ...
                     'Color', 'r');
                drawnow;
            end
        catch
            warning('Failed to save key history to file.');
        end
        
        % Signal that we're done
        fig.UserData.done = true;
    end
    
    % Force graphics update
    drawnow;
end 