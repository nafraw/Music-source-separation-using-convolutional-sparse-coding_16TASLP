instrument{1} = 'Violin';
instrument{2} = 'Clarinet';
instrument{3} = 'Saxophone';
instrument{4} = 'Bassoon';

target_path = 'Z:/Bach10/dictionary/';
save_path   = 'Z:/Bach10/dictionary/';
target_prefix{1} = 'supervised_4AW_005sec_Bach10_';
target_prefix{2} = 'supervised_4AW_02988sec_Bach10_';
target_prefix{3} = 'supervised_4AW_05663sec_Bach10_';
target_postfix = '_lambda_0.05_first5';
save_prefix = 'vary_length_4AW_';
%% first task
for i = 1:length(instrument)
    for j = 1:length(target_prefix)
        paths{j} = [target_path, target_prefix{j}, instrument{i}, target_postfix, '.mat'];        
    end
    save_file = [save_path, save_prefix, instrument{i}, target_postfix, '.mat'];
    collect_dicts_as_one(paths, save_file);
end
%% second task
target_postfix = '_lambda_0.05_last5';
for i = 1:length(instrument)
    for j = 1:length(target_prefix)
        paths{j} = [target_path, target_prefix{j}, instrument{i}, target_postfix, '.mat'];
    end
    save_file = [save_path, save_prefix, instrument{i}, target_postfix, '.mat'];
    collect_dicts_as_one(paths, save_file);
end