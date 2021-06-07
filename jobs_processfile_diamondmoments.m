function jobs_processfile_diamondmoments( paramstrs, ...
    attributions, internalevents, targetdir )
%JOBS_PROCESSFILE_DIAMONDMOMENTS loads a combined job file and stores data
% tables for the distribution moments for diamond sizes (number of central 
% events) in csv files (to be plotted with LaTeX-TikZ). 
% Columns in the output file: dimension, mean, square root of variance, 
%  cube root of skewness
% 
% Arguments:
% PARAMSTRS           cell vector of names of the files (without extension) 
%                     to be processed.
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
% INTERNALEVENTS      number of internal events. 
%                     Default: -1 (any number of internal events)
% TARGETDIR           directory for processed file output. 
%                     Default: data/Diamonds
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    %% set default values:
    if nargin < 2 || isempty( attributions )
        attributions = { 0, 0, 3, 1 };
    end
    if nargin < 3 || isempty( internalevents )
        internalevents = -1;
    end
    if nargin < 4 || isempty( targetdir )
        targetdir = 'data/Diamonds';
    end
    %% process all selected indexes:
    for i = 1 : size( attributions, 1 )
        for cri = attributions{ i, 1 }
        for cmi = attributions{ i, 2 }
        for vol = attributions{ i, 3 }
        for arr = attributions{ i, 4 }
            pmax = length( paramstrs );
            moments = zeros( pmax, 4 );
            for p = 1 : pmax
                %% select data:
                paramstr = paramstrs{ p };
                if cri == 0
                    temp = load( jobs_getfilename( paramstr, 'mat' ), ...
                        'diamonds', 'd' );
                    Y = temp.diamonds( :, :, vol, arr );
                else
                    temp = load( jobs_getfilename( paramstr, 'mat' ), ...
                        'preffutures', 'd' );
                    Y = temp.preffutures.diamonds( :, :, cri, cmi, vol );
                end
                %% get data row:
                Y = skewshift( Y ); % col index: diamond size
                if internalevents < 0
                    Y = sum( Y, 1 ); % any internal events
                else
                    Y = Y( internalevents + 1, : );
                end
                n = max( sum( Y ), 1 );
                DS = 1 : length( Y ); % weighted diamond size
                %% calculate moments:
                moments( p, 1 ) = temp.d;
                moments( p, 2 ) = sum( Y .* DS ) / n; % mean
                moments( p, 3 ) = sqrt( ...
                    sum( Y .* ( DS - moments( p, 2 ) ).^2 ) / n ); % variance
                moments( p, 4 ) = nthroot( ...
                    sum( Y .* ( DS - moments( p, 2 ) ).^3 ) / n, 3 ) ...
                  / moments( p, 3 ); % skewness
                clear temp;
            end
            %% save csv table:
            if cri == 0
                filename = sprintf( '%s/DiamondMomentsArr%dVol%d', ...
                    targetdir, arr, vol );
            else
                filename = sprintf( '%s/DiamondMomentsCri%dMin%dVol%d', ...
                    targetdir, cri, cmi, vol );
            end
            saveas_csvtable( filename, moments );
        end
        end
        end
        end
    end
end

