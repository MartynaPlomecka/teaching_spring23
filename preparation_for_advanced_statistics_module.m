course_path =  '*here add your path';
% list files in directory
datapath = fullfile(course_path, 'Henson_data/preprocessed_data');
d = dir(fullfile(datapath, '*sub*')); % equivalent: d = dir([datapath, '/*sub*']);

%% first, we change from .mat ->.set (EEGLAB format) and save the file

for i = 1 : 10
    EEG = pop_loadset(fullfile(d(i).folder, d(i).name));
    EEG = eeg_checkset( EEG );
    saving_path = fullfile(course_path, '\Henson_data\preprocessed_setformat');
    cd(saving_path)
    EEG = pop_saveset(EEG, 'filename', d(i).name);
end

%% now, we change the trigger names and epoch the data:
% list files in directory
datapath = fullfile(course_path, 'Henson_data/preprocessed_setformat'); %load the data from the previously created folder
d = dir(fullfile(datapath, '*sub*')); % equivalent: d = dir([datapath, '/*sub*']);

for i = 1 : 10
    
    % load EEG data
    pop_loadset(fullfile(d(i).folder, d(i).name));
    
    for e = 1:length(EEG.event)
        if EEG.event(e).type == 5 || EEG.event(e).type == 6 || EEG.event(e).type == 7
            EEG.event(e).type = 1; %familiar faces
        elseif EEG.event(e).type == 13 || EEG.event(e).type == 14 || EEG.event(e).type == 15
            EEG.event(e).type = 2; % unfamiliar
        elseif EEG.event(e).type == 17 || EEG.event(e).type == 18 || EEG.event(e).type == 19
            EEG.event(e).type = 3; %scrambled
        end
    end
    
    for e = 1:length(EEG.event)
        if EEG.event(e).type == 1
            EEG.event(e).eventtype = 'familiar';
        elseif EEG.event(e).type == 2
            EEG.event(e).eventtype = 'unfamiliar';
        elseif EEG.event(e).type == 3
            EEG.event(e).eventtype = 'scrambled';
        end
    end
    
    % epoch data
    % OUTEEG = pop_epoch( EEG, events, timelimits);
    EEG = pop_epoch(EEG, {1,2,3}, [-0.2 0.8]); % faces events
    % basline correction
    EEG = pop_rmbase(EEG, [-200 0]);
    
    % save the newly prepared data in this folder
    saving_path = fullfile(course_path, '\Henson_data\setformat_prepforstats');
    cd(saving_path)
    save(d(i).name, 'EEG')
    
end



%% preparation of txt file for the mass univ toolbox "bin" files:

datapath = fullfile(course_path, 'Henson_data/setformat_prepforstats');
d = dir(fullfile(datapath, '*sub*')); % equivalent: d = dir([datapath, '/*sub*']);

col1 = {};
col2  = {};

for i = 1 : 10
    
    % load EEG data
    pop_loadset(fullfile(d(i).folder, d(i).name));
    
    %save the e
    for e = 1:length(EEG.event)
        col1{e} = EEG.event(e).epoch;
        col2{e} = EEG.event(e).eventtype;
        
    end
    
    col = vertcat(col1,col2);
    
    col = col';
    % Create a new cell array with one column and the same number of rows
    output_cell = cell(length(col), 1);
    
    % Loop over the rows of the input cell array and concatenate the values with "="
    for n = 1:length(col)
        output_cell{n} = [num2str(col{n, 1}), '=', num2str(col{n, 2})];
    end
    
    % subject's filename
    filename = d(i).name;
    
    % Extract the file name without the extension
    [~, name, ~] = fileparts(filename);
    
    % Open a new text file for writing with the desired filename
    fid = fopen([name '.txt'], 'w');
    
    % Loop over the rows of the output cell array and write each element to the file
    for m = 1:numel(output_cell)
        fprintf(fid, '%s\n', output_cell{m});
    end
    
    % Close the file
    fclose(fid);
    
end



