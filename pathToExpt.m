function exptspath = pathToExpt
if exist('/Users/liusirui/Dropbox','dir')
    DBdir = 'liusirui';
elseif exist('/Users/sirui/Dropbox','dir')
    DBdir = 'sirui';
elseif exist('/Users/Sirui/Dropbox','dir')
    DBdir = 'Sirui';
end

if ~exist('DBdir','var')
    error('cannot find dropbox directory')
end

exptspath = sprintf('/Users/%s/Dropbox/data/',DBdir);

end
