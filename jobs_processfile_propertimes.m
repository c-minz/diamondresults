function jobs_processfile_propertimes( paramstr, ...
    attributions, targetdir )
%JOBS_PROCESSFILE_PROPERTIMES loads a combined job file and stores data
% tables for proper time separation distribution in csv files (to be 
% plotted with LaTeX-TikZ). 
% Columns in the output files are ( proper time, probability ).
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
%                       2: geodesic from event 1 to N by longest link chain
%                       3: geodesic from event 1 to N by maximal volume
% TARGETDIR           directory for processed csv file output. 
%                     Default: data/ProperTimes

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
        targetdir = 'data/ProperTimes';
    end
    %% load data:
    results = load( jobs_getfilename( paramstr, 'mat' ), 'maxpropertime' );
    %% process all selected indexes:
    for i = 1 : size( attributions, 1 )
        for cri = attributions{ i, 1 }
        for cmi = attributions{ i, 2 }
        for vol = attributions{ i, 3 }
        for arr = attributions{ i, 4 }
            %% select data:
            if cri == 0
                if ~isfield( results, 'propertimes' )
                    temp = load( jobs_getfilename( paramstr, 'mat' ), ...
                        'propertimes' );
                    results.propertimes = temp.propertimes;
                    clear temp;
                end
                Y = results.propertimes( :, vol, arr );
                thisparamstr = sprintf( '%sArr%dVol%d', ...
                    paramstr, arr, vol );
            else
                if ~isfield( results, 'preffutures' )
                    temp = load( jobs_getfilename( paramstr, 'mat' ), ...
                        'preffutures' );
                    results.preffutures.propertimes = ...
                        temp.preffutures.propertimes;
                    clear temp;
                end
                Y = results.preffutures.propertimes( :, cri, cmi, vol );
                thisparamstr = sprintf( '%sCri%dMin%dVol%d', ...
                    paramstr, cri, cmi, vol );
            end
            Xbinsize = results.maxpropertime / ( length( Y ) - 1 );
            X = ( 1 : length( Y ) ) - 1.5;
            Y = transpose( double( Y ) );
            Ysum = sum( Y );
            %% save proper time seperations to csv files:
            saveas_csv( sprintf( '%s/%s', targetdir, thisparamstr ), ...
                100 * Y / Ysum, Xbinsize * X );
            % ... change this to - 1.5 for negative underflow bin
            fileID = fopen( sprintf( '%s/%sev.tex', ...
                targetdir, thisparamstr ), 'w' );
            fprintf( fileID, '\\def\\expectationvalue{%0.6f}\n', ...
                Xbinsize * sum( Y .* X ) / Ysum );
            fprintf( fileID, '\\def\\xbinwidth{%0.6f}\n', Xbinsize );
            fclose( fileID );
        end
        end
        end
        end
    end
end

