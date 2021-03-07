function filename = jobs_getfilename( paramstr, extension, directory )
%JOBS_GETFILENAME returns the filename with directory and extension.
% 
% Arguments:
% PARAMSTR            filename parameter string.
% 
% Optional arguments:
% EXTENSION           filename extension or '' to add no extension 
%                     (default). 
%                     Use e.g. 'diamonds.mat' for pre-processed file.
% DIRECTORY           path to the file directory. The default directory is
%                     'data'.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    if nargin < 2
        extension = '';
    end
    if nargin < 3 || isempty( directory )
        directory = 'data';
    end
    if isempty( extension )
        filename = sprintf( '%s/%s', directory, paramstr );
    else
        filename = sprintf( '%s/%s.%s', directory, paramstr, extension );
    end
end

