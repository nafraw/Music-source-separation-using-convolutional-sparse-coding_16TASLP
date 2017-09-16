a=load('./pitch_presence_full_song');
pic_occ = [a.pitch_occurrence{1}; a.pitch_occurrence{2}; a.pitch_occurrence{3}; a.pitch_occurrence{4}];

% all combinations
v = 1:10;
C = combnk(v,5);

% exhaustive search
for i=1:size(C,1)
    % find complement set
    m = ismember(v, C(i,:));
    Cc(i,:) = v(find(m==0));
    % search
    set1  = (sum(pic_occ(:, C(i,:)) , 2)) > 0;
    set2  = (sum(pic_occ(:, Cc(i,:)), 2)) > 0;
    
    validate1 = (set1 - set2) >= 0; % set1 can cover set2
    validate2 = (set2 - set1) >= 0; % set2 can cover set1
    
    pass1 = (length(find(validate1 == 0)) == 0);
    pass2 = (length(find(validate2 == 0)) == 0);
    
    if pass1 && pass2
        C(i,:)
        Cc(i,:)
        break;
    end
end
%% not passed, test is 5 second only
if ~(pass1 && pass2)
    a = load('./pitch_presence_5_sec');
    test_pic_occ = [a.pitch_occurrence{1}; a.pitch_occurrence{2}; a.pitch_occurrence{3}; a.pitch_occurrence{4}];
    % exhastive search
    for i=1:size(C,1)
        % find complement set
        m = ismember(v, C(i,:));
        Cc(i,:) = v(find(m==0));
        % search
        set1  = (sum(pic_occ(:, C(i,:)) , 2)) > 0;
        set2  = (sum(test_pic_occ(:, Cc(i,:)), 2)) > 0;        
        validate1 = (set1 - set2) >= 0; % set1 can cover set2
        
        set1  = (sum(test_pic_occ(:, C(i,:)) , 2)) > 0;
        set2  = (sum(pic_occ(:, Cc(i,:)), 2)) > 0;
        validate2 = (set2 - set1) >= 0; % set2 can cover set1
        
        pass1 = (length(find(validate1 == 0)) == 0);
        pass2 = (length(find(validate2 == 0)) == 0);
        
        if pass1 && pass2
            C(i,:)
            Cc(i,:)
            break;
        end
    end
end
