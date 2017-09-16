function setting = specify_setting(setting, field, value, type)
if nargin < 3 || nargin > 4
    error('Incorrect number of input argument');
else
    idx = length(setting)+1;
    setting(idx).parname = field; % parameter name
    setting(idx).value = value;
    if nargin == 4
        setting(idx).type = type;
    else
        if iscell(value)
            tmp = value{1};
        else
            tmp = value;
        end
        if ischar(tmp)
            setting(idx).type = 'char';
        elseif isnumeric(tmp)
            setting(idx).type = 'numeric';
        else
            error('unsupported auto-identification of type');
        end
    end
end
end