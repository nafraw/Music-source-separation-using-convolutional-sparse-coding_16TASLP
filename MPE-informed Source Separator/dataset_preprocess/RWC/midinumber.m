function midi = midinumber(chr)
    oct = str2num(chr(end));
    switch lower(chr(1:end-1))
        case 'c'
            offset = 0;
        case 'c#'
            offset = 1;
        case 'db'
            offset = 1;
        case 'd'
            offset = 2;
        case 'd#'
            offset = 3;
        case 'eb'
            offset = 3;
        case 'e'
            offset = 4;
        case 'f'
            offset = 5;
        case 'f#'
            offset = 6;
        case 'gb'
            offset = 6;
        case 'g'
            offset = 7;
        case 'g#'
            offset = 8;
        case 'ab'
            offset = 8;
        case 'a'
            offset = 9;
        case 'a#'
            offset = 10;
        case 'bb'
            offset = 10;
        case 'b'
            offset = 11;
        otherwise
            error('unknown note name');
    end
    midi = 12 * (oct + 1) + offset;
end