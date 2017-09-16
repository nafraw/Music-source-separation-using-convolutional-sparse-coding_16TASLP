function [useful, fold, flag_trimmed] = find_validation_set(n_fold)
fold = [];
n_random = 100; % maximum number for random trial
% n_fold = 5;
for trial = 1:n_random
    v = randperm(10);
    % easy search (not exhaustive)
    for f = 1:n_fold
        fold{f} = v(f:n_fold:10);
    end
    if n_fold == 1 % no test data, so training data is also test data, no need to verify
        useful = 1;
        flag_trimmed = 0;
        return;
    end
    
    a=load('./pitch_presence_source');
    pic_occ = [a.pitch_occurrence{1}; a.pitch_occurrence{2}; a.pitch_occurrence{3}; a.pitch_occurrence{4}];
    for f = 1:n_fold
        % test_set
        tes = fold{f};
        % train set
        trs = 1:10;
        trs(fold{f}) = [];
        % search
        set_te = (sum(pic_occ(:, tes), 2)) > 0;
        set_tr = (sum(pic_occ(:, trs), 2)) > 0;
        
        validate1 = (set_tr - set_te) >= 0; % set_tr can cover set_te
        
        pass(f) = (length(find(validate1 == 0)) == 0);
    end
    if sum(pass) == n_fold
        display('The follwoing fold is good to use:');
        fold
        flag_trimmed = 0
        useful = 1;
        return
    end
end


for trial = 1:n_random
    %% not passed, test is 5 second only
    a = load('./pitch_presence_mixed');
    test_pic_occ = [a.pitch_occurrence{1}; a.pitch_occurrence{2}; a.pitch_occurrence{3}; a.pitch_occurrence{4}];
    % exhastive search
    for f = 1:n_fold
        % test_set
        tes = fold{f};
        % train set
        trs = 1:10;
        trs(fold{f}) = [];
        % search
        set1  = (sum(pic_occ(:, trs) , 2)) > 0;
        set2  = (sum(test_pic_occ(:, tes), 2)) > 0;
        validate1 = (set1 - set2) >= 0; % set1 can cover set2
        pass(f) = (length(find(validate1 == 0)) == 0);
    end
    if sum(pass) == n_fold
        display('The follwoing fold (full vs 5-sec) is good to use:');
        fold
        flag_trimmed = 1
        useful = 1;
        return;
    end
end
display('Unfortunately, no good validation set is found');
useful = 0;