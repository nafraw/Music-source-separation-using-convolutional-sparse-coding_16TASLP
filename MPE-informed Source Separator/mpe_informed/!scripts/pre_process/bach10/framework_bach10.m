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
    title = ['Start: MPE-ISS Pre-Process at ', IPaddress, ' ', script_name ' starts'];
    mail_contents{1}     = ['Your MATLAB script ', script_name, ' starts running now'];
    mail_contents{end+1} = '';
    mail_contents{end+1} =  'The full path is:';
    mail_contents{end+1} = script_fullpath;
    attachment  = [];
%     MailReport_NAS(receiver, title, mail_contents, attachment);
    clear mail_contents
end

%% Call main function
time = clock; % cuurent time
diary_name = ['./diary/command_window_log_', num2str(time(4)),'_', num2str(time(5)), '_', date '.txt'];
% save command window log
if ~exist('./diary', 'dir')
    mkdir('./diary');
end
diary(diary_name);
try
    main_pre_process(param);
catch err
    diary off
    if send_mail_at_error
        title = ['Error: MPE-ISS Pre-Process at ' IPaddress ' ' script_name];
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
%         MailReport_NAS(receiver, title, mail_contents, attachment);
    else
        time = clock; % cuurent time
        diary_name = ['command_window_log_', num2str(time(4)),'_', num2str(time(5)), '_', date '.txt'];
        % save command window log
        diary(diary_name);
    end    
    rethrow(err);
end
diary off
param.dict_train.D0 = 0; % to avoid too large attachment
%% Write a mail for experiment management
if send_mail_at_finish
    % title
    title = ['Finish: MPE-ISS Pre-Process at ' IPaddress ' ' script_name];
    % contents
    mail_contents{1} = ['Your MATLAB script ', script_name, ' is finished!'];
    % attachments
        time = clock; % cuurent time
        % the name of attachment is given by a given name and time and date.
        attachment{1} = ['./param_file/param_', script_name, '_', num2str(time(4)),'_', num2str(time(5)), '_', date '.mat'];        
        if ~exist('./param_file/', 'dir')
            mkdir('./param_file/');
        end
        save(attachment{1}, 'param');        
        attachment{2} = diary_name;
    % send mail
%     MailReport_NAS(receiver, title, mail_contents, attachment);
end

rmpath(genpath('../../../'));
rmpath(genpath('../../../../MATLAB gadget'));

end