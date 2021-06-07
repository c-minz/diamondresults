function jobs_processfile_diamonds( paramstr, ...
    subrelations, attributions, targetdir )
%JOBS_PROCESSFILE_DIAMONDS loads a combined job file and stores data
% tables for the diamond link size (number of central events) in csv files 
% (to be plotted with LaTeX-TikZ). 
% Columns in the output files are ( central event count, probability ).
% Columns in the (*Srlev) files are ( subrel. or -1, expect. value ).
% 
% Arguments:
% PARAMSTR            name of the file (without extension) to be processed.
% 
% Optional arguments:
% SUBRELATIONS        vector of subrelated event numbers. Pure diamond
%                     links are addressed with a 0 and any subrelation is
%                     adressed by -1. Default: [ -1, 0, 2, 3 ].
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
% TARGETDIR           directory for processed file output. 
%                     Default: data/Diamonds
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    %% set default values:
    if nargin < 2 || isempty( subrelations )
        subrelations = [ -1, 0, 2, 3 ];
    end
    if nargin < 3 || isempty( attributions )
        attributions = { 0, 0, 3, 1 };
    end
    if nargin < 4 || isempty( targetdir )
        targetdir = 'data/Diamonds';
    end
    %% prepare results structure:
    results = struct();
    %% process all selected indexes:
%     saveEvalues = false;
    for i = 1 : size( attributions, 1 )
        for cri = attributions{ i, 1 }
        for cmi = attributions{ i, 2 }
        for vol = attributions{ i, 3 }
        for arr = attributions{ i, 4 }
            %% select data:
            if cri == 0
                if ~isfield( results, 'diamonds' )
                    temp = load( jobs_getfilename( paramstr, 'mat' ), ...
                        'diamonds', 'runs', 'N', 'eventcounts', ...
                        'futureinfinities' );
                    results.diamonds = double( temp.diamonds );
                    results.runs = temp.runs;
                    results.N = temp.N;
                    results.eventcounts = double( temp.eventcounts );
                    results.futureinfinities = double( temp.futureinfinities );
                    clear temp;
                end
                Y = results.diamonds( :, :, vol, arr );
                fprintf( 'Total number of diamonds: %d\n', sum( sum( Y ) ) );
                thisparamstr = sprintf( '%sArr%dVol%d', ...
                    paramstr, arr, vol );
            else
                if ~isfield( results, 'preffutures' )
                    temp = load( jobs_getfilename( paramstr, 'mat' ), ...
                        'preffutures', 'runs' );
                    results.preffutures.diamonds = ...
                        double( temp.preffutures.diamonds );
                    results.runs = temp.runs;
                    clear temp;
                end
                Y = results.preffutures.diamonds( :, :, cri, cmi, vol );
                thisparamstr = sprintf( '%sCri%dMin%dVol%d', ...
                    paramstr, cri, cmi, vol );
            end
            %% skew shift and combine statistics:
            Y = skewshift( Y );
            maxdmd = size( Y, 2 );
            Srlsum = sum( Y, 1 );
            Srlsumsum = sum( Srlsum );
            if Srlsumsum == 0
                Srlsumsum = 1;
            end
            %% save csv for each selected sub-relations:
            Evalues = zeros( size( subrelations ) );
            Eidx = 0;
            if cri == 0 && arr == 1
                weightsfactor = 1 / ( results.eventcounts( vol ) - ...
                    results.futureinfinities( 2, vol ) ); % show expected numbers
            else
                weightsfactor = 100 / Srlsumsum; % convert to percent
            end
            for j = ( subrelations + 1 )
                range = ( max( j, 1 ):maxdmd ) + 0.5;
                if j == 0
                    weights = weightsfactor * Srlsum;
                    saveas_csv( sprintf( '%s/%sSrlsum', ...
                        targetdir, thisparamstr ), ...
                        weights, range );
                    %saveEvalues = true;
                else
                    weights = weightsfactor * Y( j, range );
                    saveas_csv( sprintf( '%s/%sSrl%d', ...
                        targetdir, thisparamstr, j - 1 ), ...
                        weights, range );
                end
                Eidx = Eidx + 1;
                Evalues( Eidx ) = sum( weights .* range ) / sum( weights );
            end
%             %% save csv for expectation values:
%             if saveEvalues
%                 saveas_csv( sprintf( '%s/%sSrlev', ...
%                     targetdir, thisparamstr ), Evalues, subrelations );
%             end
        end
        end
        end
        end
    end
end

