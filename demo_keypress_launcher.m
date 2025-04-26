function demo_keypress_launcher()
    % DEMO_KEYPRESS_LAUNCHER - Demonstrates the keyboard test launcher
    %
    % This function creates a sample figure and adds the keyboard test launcher
    % to it. When the user presses 'm' on the figure, the keyboard test GUI
    % will be launched.
    %
    % Usage:
    %   demo_keypress_launcher();
    
    % Create a sample figure
    fig = figure('Name', 'Demo: Press ''m'' to launch keyboard test', ...
                'NumberTitle', 'off', ...
                'Position', [100, 100, 600, 400]);
    
    % Add some sample content
    ax = axes('Parent', fig);
    x = linspace(0, 2*pi, 100);
    plot(ax, x, sin(x), 'b-', 'LineWidth', 2);
    hold(ax, 'on');
    plot(ax, x, cos(x), 'r-', 'LineWidth', 2);
    hold(ax, 'off');
    
    xlabel(ax, 'x');
    ylabel(ax, 'f(x)');
    title(ax, 'Sample Plot - Press ''m'' to test keyboard input');
    legend(ax, 'sin(x)', 'cos(x)');
    grid(ax, 'on');
    
    % Add instructions text
    textAxes = axes('Parent', fig, ...
                   'Position', [0.25, 0.8, 0.5, 0.1], ...
                   'Visible', 'off');
    
    text(0.5, 0.5, {'Press ''m'' to launch keyboard test GUI', ...
                    'This works with any MATLAB figure'}, ...
         'Parent', textAxes, ...
         'HorizontalAlignment', 'center', ...
         'FontSize', 14, ...
         'FontWeight', 'bold', ...
         'BackgroundColor', [0.95, 0.95, 0.8], ...
         'EdgeColor', 'black', ...
         'Margin', 5);
    
    % Add the keyboard test launcher to the figure
    add_keypress_launcher(fig);
    
    % Bring figure to front and give it focus
    figure(fig);
    
    % Print instructions to command window
    fprintf('\n=========================================\n');
    fprintf('Keyboard test launcher demo\n');
    fprintf('=========================================\n');
    fprintf('1. Click on the figure to give it focus\n');
    fprintf('2. Press ''m'' to launch the keyboard test GUI\n');
    fprintf('3. Test keyboard input in the new GUI\n');
    fprintf('4. Press ''q'' in the test GUI to close it\n');
    fprintf('   and return to the main figure\n');
    fprintf('=========================================\n\n');
end 