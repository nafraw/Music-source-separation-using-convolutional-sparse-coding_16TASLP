function framework_bach10(param, script_name, script_fullpath)
diary off;
clc;
%% Environmental setting
addpath(genpath('../../../'));
addpath(genpath('../../../../MATLAB gadget'));     %JPK's bitbucket project.

send_mail_at_start = 0;
send_mail_at_error = 1;
send_mail_at_finish= 1;
receiver = ''; % mail receiver


%% Write a mail for experiment management
[~, IPaddress] = IP_local;
if send_mail_at_start
    title = ['Start: MPE-ISS score-informed NMF at ', IPaddress, ' ', script_name ' starts'];
    mail_contents{1}     = ['Your MATLAB script ', script_name, ' starts running now'];
    mail_contents{end+1} = '';
    mail_contents{end+1} =  'The full path is:';
    mail_contents{end+1} = script_fullpath;
    attachment  = [];
%     send_mail_and_check_size(receiver, title, mail_contents, attachment);
    clear mail_contents
end

%% Call main function
time = clock; % cuurent time
diary_name = [param.path_sendData, 'diary/command_window_log_', num2str(time(4)),'_', num2str(time(5)), '_', date '.txt'];
% save command window log
check_path(diary_name);
diary(diary_name);
try
    param
    param.exp_name
    SSperf = main_bach10_separation_dict_spectrogram_no_inst_v2(param);
    [mSDR, mSIR, mSAR, SDR, SIR, SAR] = perfStatistic_SS(SSperf);
    draw_good();
catch err
    diary off
    if send_mail_at_error
        title = ['Error: MPE-ISS score-informed NMF at ' IPaddress ' ' script_name];
        mail_contents{1}     = ['Your MATLAB script ', script_name, ' failed due to an error!'];
        mail_contents{end+1} = '';
        mail_contents{end+1} =  'The full path is:';
        mail_contents{end+1} = script_fullpath;
        mail_contents{end+1} = '';
        mail_contents{end+1} =  'The error message is:';
        mail_contents{end+1} = [err.message];
        mail_contents{end+1} = '';
        mail_contents{end+1} =  'The stack is:';
        for sid = 1:size(err.stack, 1)
            mail_contents{end+1} = [err.stack(sid).file, ' line: ', ...
                                    num2str(err.stack(sid).line)];
        end
        time = clock; % cuurent time
        % the name of attachment is given by a given name and time and date.
        attachment{1} = ['./error_file/err_', script_name, '_', num2str(time(4)),'_', num2str(time(5)), '_', date '.mat'];
        if ~exist('./error_file', 'dir')
            mkdir('./error_file');
        end
        save(attachment{1}, 'err', 'param');
        % the name for command window_log
        attachment{2} = diary_name;
%         send_mail_and_check_size(receiver, title, mail_contents, attachment);
    else
%         time = clock; % cuurent time
%         diary_name = ['command_window_log_', num2str(time(4)),'_', num2str(time(5)), '_', date '.txt'];
%         % save command window log
%         diary(diary_name);
    end
    draw_bad();
    rethrow(err);
end
diary off
param.dict_train.D0 = 0; % to avoid too large attachment
%% Write a mail for experiment management
if send_mail_at_finish
    % title
    title = ['Finish: MPE-ISS score-informed NMF at ' IPaddress ' ' script_name];
    % contents
    mail_contents{1} = ['Your MATLAB script ', script_name, ' is finished!'];
    mail_contents{end+1} = sprintf('Average SDR: %2.3f', mSDR);
    mail_contents{end+1} = sprintf('Average SIR: %2.3f', mSIR);
    mail_contents{end+1} = sprintf('Average SAR: %2.3f', mSAR);
    % attachments
        time = clock; % cuurent time
        % the name of attachment is given by a given name and time and date.
        attachment{1} = [param.path_sendData, 'param/', script_name, '_', ...
            num2str(time(4)),'_', num2str(time(5)), '_', date '.mat'];
        attachment{2} = [param.path_sendData, 'result/', script_name, '_',...
            num2str(time(4)),'_', num2str(time(5)), '_', date '.mat'];
        check_path(attachment{1});
        check_path(attachment{2});        
        save(attachment{1}, 'param');
        save(attachment{2}, 'SSperf', 'SDR', 'SIR', 'SAR');
%         attachment{3} = diary_name;
    mail_contents{end+1} = ['Result is saved at: ', attachment{2}];
    mail_contents{end+1} = ['Parameter is saved at: ', attachment{1}];
    mail_contents{end+1} = ['Diary (log) is saved at: ', diary_name];
    % send mail
%     send_mail_and_check_size(receiver, title, mail_contents, attachment);    
end

rmpath(genpath('../../../'));
rmpath(genpath('../../../../MATLAB gadget'));

end