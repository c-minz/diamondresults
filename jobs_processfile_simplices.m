function jobs_processfile_simplices( paramstr, ...
    attributions, targetdir )
%JOBS_PROCESSFILE_SIMPLICES loads a combined job file and stores data
% tables for the simplices in csv files (to be plotted with LaTeX-TikZ). 
% Columns in the output files are ( probability, probability ).
% 
% Arguments:
% PARAMSTR            name of the file (without extension) to be processed.
% 
% Optional arguments:
% ATTRIBUTIONS        Nx1 cell array where each element is either a single 
%                     index or a vector of indexes, which give the
%                     combination of location attributes. 
%                     First cell array column: subvolumes
%                       1 entire causet (default)
%                       2 one top volume layer removed
%                       3 two top volume layers removed
%                       ...
% TARGETDIR           directory for processed csv file output. 
%                     Default: data/Dimensions
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    %% set default values:
    if nargin < 2 || isempty( attributions )
        attributions = { 1 };
    end
    if nargin < 3 || isempty( targetdir )
        targetdir = 'data/Dimensions';
    end
    %% prepare results structure:
    results = load( jobs_getfilename( paramstr, 'mat' ), ...
        'simplices', 'runs' );
    %% process all selected indexes:
    for i = 1 : size( attributions, 1 )
        for vol = attributions{ i, 1 }
            %% select data:
            Y = results.simplices( :, :, vol );
            binsize = 100 / ( length( Y ) - 2 );
            X = linspace( -binsize, 100, length( Y ) ) + binsize / 2;
            Y = 100 * double( Y ) / results.runs;
            for spd = 1 : size( Y, 1 )
                %% save dimension estimators to csv files:
                saveas_csv( sprintf( '%s/%sVol%dSpd%d', ...
                    targetdir, paramstr, vol, spd ), ...
                    Y( spd, : ), X );
            end
        end
    end
end

