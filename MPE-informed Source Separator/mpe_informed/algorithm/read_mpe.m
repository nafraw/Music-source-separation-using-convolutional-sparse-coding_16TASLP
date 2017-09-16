function meta = read_mpe(txt_path)
    meta = dlmread(txt_path);    
    meta(:, 2:end) = f0toPitch(meta(:, 2:end));
end

function p = f0toPitch(f0)
    p = round(69 + 12 * log2(f0/440));
end