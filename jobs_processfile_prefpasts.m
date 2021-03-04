function jobs_processfile_prefpasts( paramstr, maxcount, ...
    attributions, targetdir )
%JOBS_PROCESSFILE_PREFPASTS loads a combined job file and stores data
% tables for preferred future count distribution in csv files (to be 
% plotted with LaTeX-TikZ). 
% Columns in the output files are ( number of pref. futures, probability ).
% 
% Arguments:
% PARAMSTR            name of the file (without extension) to be processed.
% 
% Optional arguments:
% MAXCOUNT            maximal cardinality for the output data. Default: 4
% ATTRIBUTIONS        Nx4 cell array where each element is either a single 
%                     index or a vector of indexes, which give the
%                     combination of location attributes. 
%                     First cell array column: preferred future criteria
%                       (see CAUSET_FIND_PREFTIMES)
%                       1 (default)
%                     Second cell array column: criteria minima
%                       (see CAUSET_FIND_PREFTIMES)
%                       1 (default)
%                     Third cell array column: subvolumes
%                       1 entire causet
%                       2 one top volume layer removed
%                       3 two top volume layers removed (default)
%                       ...
% TARGETDIR           directory for processed csv file output. 
%                     Default: data/PrefPasts

    %% set default values:
    if nargin < 2 || isempty( maxcount )
        maxcount = 4;
    end
    if nargin < 3 || isempty( attributions )
        attributions = { 1, 1, 3 };
    end
    if nargin < 4 || isempty( targetdir )
        targetdir = 'data/PrefPasts';
    end
    %% load data:
    results = load( jobs_getfilename( paramstr, 'mat' ), ...
        'preffutures' );
    %% process all selected indexes:
    for i = 1 : size( attributions, 1 )
        for cri = attributions{ i, 1 }
        for cmi = attributions{ i, 2 }
        for vol = attributions{ i, 3 }
            %% select data:
            Y = transpose( double( ...
                results.preffutures.counts( :, cri, cmi, vol ) ) );
            Y = [ Y( 1 : maxcount ), sum( Y( maxcount : length( Y ) ) ) ];
            thisparamstr = sprintf( '%sCri%dMin%dVol%d', ...
                paramstr, cri, cmi, vol );
            X = ( 0:1:length( Y ) ) + 0.5;
            %% save proper time seperations to csv files:
            saveas_csv( sprintf( '%s/%s', targetdir, thisparamstr ), ...
                100 * Y / sum( Y ), X );
        end
        end
        end
    end
end

