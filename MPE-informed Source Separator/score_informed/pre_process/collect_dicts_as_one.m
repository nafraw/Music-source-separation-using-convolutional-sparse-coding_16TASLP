function collect_dicts_as_one(paths, save_path)

pitch = [];
fnum = length(paths)
for fid = 1:fnum
    clear tD tpich;
    tD = load(paths{fid}, 'D');         % temporary dictionary
    tpitch = load(paths{fid}, 'pitch'); % temporary pitch
    len(fid,1) = size(tD.D, 1);
    atom_num(fid,1) = size(tD.D, 2);
    Dc{fid} = tD.D;
    pitch = [pitch; tpitch.pitch];
end
D = zeros(max(len), sum(atom_num));
id = 1;
for fid = 1:fnum
    for aid = 1:atom_num(fid)
        D(1:len(fid), id) = Dc{fid}(:, aid);
        id = id + 1;
    end
end

check_path(save_path);
save(save_path, 'D', 'pitch', 'paths');

end