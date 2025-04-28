function test_number_input()
    % Test the number input dialog
    
    disp('--------------------------------');
    disp('Opening number input dialog');
    disp('Enter a number and click Submit');
    disp('--------------------------------');
    
    % Call the number input dialog
    result = number_input_dialog();
    
    % Display the result
    if isempty(result)
        disp('No number was entered (dialog was closed)');
    else
        disp(['Final number entered: ' num2str(result)]);
    end
    
    disp('Test completed.');
end 