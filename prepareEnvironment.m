function prepareEnvironment
        fclose('all');
        format short;
        ClockRandSeed;
        GetSecs;
        commandwindow; % Select the command Window to avoid typing in open scripts
        HideCursor;
        ListenChar(2); % Don't print to MATLAB command Window
return