function jobs_processfile_diamondtimes( paramstr, ...
    attributions, targetdir )
%JOBS_PROCESSFILE_DIAMONDTIMES loads a combined job file and stores data
% tables for the diamond link proper time separations in csv files 
% (to be plotted with LaTeX-TikZ). 
% Columns in the output files are ( central event count, proper time ).
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
%                     Default: data/DiamondTimes

    %% set default values:
    if nargin < 2 || isempty( attributions )
        attributions = { 1 };
    end
    if nargin < 3 || isempty( targetdir )
        targetdir = 'data/DiamondTimes';
    end
    %% prepare results structure:
    results = load( jobs_getfilename( paramstr, 'mat' ), ...
        'diamondtimes', 'diamonds' );
    %% process all selected indexes:
    for i = 1 : size( attributions, 1 )
        for vol = attributions{ i, 1 }
            %% select data, compute elementwise average, remove units:
            range_len = size( results.diamondtimes( 1, :, vol ), 2 );
            range = 1 : range_len;
            Y = results.diamondtimes( 1, :, vol );
            Y_norm = results.diamonds( 1, :, vol );
            for j = 2 : size( Y, 1 )
                Y( j : range_len ) = Y( j : range_len ) + ...
                    results.diamondtimes( j, range(1 : range_len - j + 1), vol );
                Y_norm( j : range_len ) = Y_norm( j : range_len ) + ...
                    results.diamonds( j, range(1 : range_len - j + 1), vol );
            end
            Y = Y ./ max( 1, double( Y_norm ) );
            thisparamstr = sprintf( '%sVol%d', paramstr, vol );
            %% save csv for each selected sub-relations:
            saveas_csv( sprintf( '%s/%s', targetdir, thisparamstr ), ...
                Y, range );
        end
    end
end

