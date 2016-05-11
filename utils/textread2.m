function varargout = textread2(filename, parseString, varargin)

try
    fid         = fopen(filename);
    varargout   = textscan(fid, parseString, varargin{:});
    fclose(fid);
catch
    dispf('textread2 file: %s, error: %s', filename, lasterr);
end
