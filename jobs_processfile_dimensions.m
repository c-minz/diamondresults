function jobs_processfile_dimensions( paramstr, ...
    attributions, targetdir )
%JOBS_PROCESSFILE_DIMENSIONS loads a combined job file and stores data
% tables for the dimension estimators (flat and curved Myrheim-Meyer) in
% csv files (to be plotted with LaTeX-TikZ). 
% Columns in the output files are ( dimension, probability ).
% 
% Arguments:
% PARAMSTR            name of the file (without extension) to be processed.
% 
% Optional arguments:
% ATTRIBUTIONS        Nx4 cell array where each element is either a single 
%                     index or a vector of indexes, which give the
%                     combination of location attributes. 
%                     First cell array column: preferred future criteria
%                       (see CAUSET_FIND_PREFTIMES to process preferred
%                        future)
%                       0 to process all links, not only preferred future
%                         (default)
%                     Second cell array column: criteria minima
%                       (see CAUSET_FIND_PREFTIMES to process preferred
%                        future)
%                       0 to process all links, not only preferred future
%                         (default)
%                     Third cell array column: subvolumes
%                       1 entire causet
%                       2 one top volume layer removed
%                       3 two top volume layers removed (default)
%                       ...
%                     Forth cell array column: diamond link arrangement
%                     (This column is ignored for preferred future
%                      analysis, and hence could be set to zero.)
%                       1 links anywhere in the causet (default)
%                       2 links along the chain from bottom to top
%                       3 links along further chains to the top
% TARGETDIR           directory for processed csv file output. 
%                     Default: data/Dimensions

    %% set default values:
% RESCALE             positive factor to rescale the interval sizes.
%                     Default: 1 (no rescale).
%     if nargin < 2 || isempty( rescale )
%         rescale = 1;
%     end
    if nargin < 2 || isempty( attributions )
        attributions = { 0, 0, 3, 1 };
    end
    if nargin < 3 || isempty( targetdir )
        targetdir = 'data/Dimensions';
    end
    %% prepare results structure:
    results = load( jobs_getfilename( paramstr, 'mat' ), ...
        'maxdimension' );
    %% process all selected indexes:
    curveset = { 'Dimflat', 'Dimcurved', 'Dimmidpoint' };
    for i = 1 : size( attributions, 1 )
        for cri = attributions{ i, 1 }
        for cmi = attributions{ i, 2 }
        for vol = attributions{ i, 3 }
        for arr = attributions{ i, 4 }
            %% select data:
            if cri == 0
                if ~isfield( results, 'dimestimators' )
                    temp = load( jobs_getfilename( paramstr, 'mat' ), ...
                        'chains', 'dimestimators' );
                    results.dimestimators = temp.dimestimators;
                    clear temp;
                end
                Y = results.dimestimators( :, :, vol, arr );
                thisparamstr = sprintf( '%sArr%dVol%d', ...
                    paramstr, arr, vol );
            else
                if ~isfield( results, 'preffutures' )
                    temp = load( jobs_getfilename( paramstr, 'mat' ), ...
                        'preffutures' );
                    results.preffutures.dimestimators = temp.preffutures.dimestimators;
                    clear temp;
                end
                Y = results.preffutures.dimestimators( :, :, cri, cmi, vol );
                curveset = { 'Dimflat', 'Dimcurved' };
                thisparamstr = sprintf( '%sCri%dMin%dVol%d', ...
                    paramstr, cri, cmi, vol );
            end
            binsize = results.maxdimension / ( length( Y ) - 2 );
            X = linspace( -binsize, results.maxdimension, length( Y ) ) ...
                + binsize / 2;
            Y = double( Y );
            for r = 1 : size( Y, 1 )
                %% save dimension estimators to csv files:
                saveas_csv( sprintf( '%s/%s%s', targetdir, thisparamstr, curveset{ r } ), ...
                    100 * Y( r, : ) / sum( Y( r, : ) ), X );
            end
        end
        end
        end
        end
    end
end

