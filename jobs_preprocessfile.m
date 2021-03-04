function jobs_preprocessfile( filename )
%JOBS_PREPROCESSFILE loads a combined job file and computes averages for 
% the statistics. The expectation values per event in a respective causet 
% are stored in new files, which have the fieldname appended to the 
% filename.
% 
% Arguments:
% FILENAME            name of the file (without extension) to be processed.

    %% load data:
    masterdata = load( sprintf( '%s.mat', filename ) );
    runs = masterdata.runs;
    N = masterdata.N;
    d = masterdata.d;
    %% turn event counts into probabilities:
    if isfield( masterdata, 'eventcounts' )
        masterdata.local.eventcounts = ...
            double( masterdata.eventcounts ) / runs / N;
    end
    if isfield( masterdata, 'futureinfinities' )
        masterdata.local.futureinfinities = ...
            double( masterdata.futureinfinities ) / runs / N;
    end
    %% compute number of elements per subvolume Ncounted:
    if isfield( masterdata, 'eventcounts' ) ...
       && isfield( masterdata, 'futureinfinities' )
        Ncounted = zeros( 1, length( masterdata.eventcounts ) );
        shellcount = length( masterdata.eventcounts );
        for i = 1 : shellcount
            Ncounted( i ) = N * ...
                sum( masterdata.local.eventcounts( 1:i ) ...
                .* ( 1 - sum( masterdata.local.futureinfinities( 2, 1:i ) ) ) );
        end
    elseif isfield( masterdata, 'futureinfinities' )
        % discontinued version:
        shellcount = length( masterdata.futureinfinities );
        Ncounted = N * ( 1 - flip( ...
            masterdata.local.futureinfinities( 2 : shellcount ) ) );
    else
        shellcount = 5;
        Ncounted = N * ones( 1, shellcount );
    end
    %% compute local diamond link numbers:
    %  diamondweight: sums of the diamonds for division
    if isfield( masterdata, 'diamonds' )
        masterdata.local.diamonds = ... % pre-allocate
            zeros( size( masterdata.diamonds ) );
        diamondweight = masterdata.local.diamonds;
        for i = 1 : size( masterdata.local.diamonds, 3 )
            diamondweight( :, :, i, : ) = ...
                double( sum( masterdata. ...
                  diamonds( :, :, 1:i, : ), 3 ) );
            masterdata.local.diamonds( :, :, i, : ) = ...
                diamondweight( :, :, i, : ) ...
              / runs / max( 1, Ncounted( i ) );
        end
        masterdata.local.diamonds = flip( masterdata.local.diamonds, 3 );
        diamondweight = max( 1, diamondweight );
    else
        diamondweight = ones( [ 1, 1, 5, 3 ] );
    end
    %% compute local diamond link proper time separations:
    if isfield( masterdata, 'diamondtimes' )
        masterdata.local.diamondtimes = ... % pre-allocate
            zeros( size( masterdata.diamondtimes ) );
        temp = masterdata.diamondtimes ...
            * ( N / masterdata.volume )^( 1 / d );
        for i = 1 : size( masterdata.local.diamondtimes, 3 )
            masterdata.local.diamondtimes( :, :, i ) = ...
                sum( temp( :, :, 1:i ), 3 ) ./ diamondweight( :, :, i, 1 );
        end
        masterdata.local.diamondtimes = flip( masterdata.local.diamondtimes, 3 );
    end
    %% compute local dimension distributions:
    if isfield( masterdata, 'dimensions' )
        masterdata.local.dimensions = ... % pre-allocate
            zeros( size( masterdata.dimensions ) );
        for type = 1 : size( masterdata.dimensions, 1 )
            for j = 1 : size( masterdata.dimensions, 4 )
                for i = 1 : size( masterdata.dimensions, 3 )
                    temp = double( sum( masterdata.dimensions( type, :, 1:i, j ), 3 ) );
                    masterdata.local.dimensions( type, :, i, j ) = ...
                        temp / sum( temp );
                end
            end
        end
        masterdata.local.dimensions = flip( masterdata.local.dimensions, 3 );
    end
    %% compute local diamond link proper time separation distribution:
    if isfield( masterdata, 'propertimes' )
        masterdata.local.propertimes = ... % pre-allocate
            zeros( size( masterdata.propertimes ) );
        for j = 1 : size( masterdata.propertimes, 3 )
            for i = 1 : size( masterdata.propertimes, 2 )
                temp = double( sum( masterdata.propertimes( :, 1:i, j ), 2 ) );
                masterdata.local.propertimes( :, i, j ) = ...
                    temp / sum( temp );
            end
        end
        masterdata.local.propertimes = flip( masterdata.local.propertimes, 2 );
    end
    %% compute local diamond link numbers and proper
    %  time separations for preferred futures:
    if isfield( masterdata, 'preffutures' )
        haspreffuturecounts = false;
        if isfield( masterdata.preffutures, 'counts' )
            haspreffuturecounts = true;
            masterdata.local.preffutures.counts = ...
                double( masterdata.preffutures.counts ) / runs / N;
            masterdata.local.preffutures.counts = ...
                flip( masterdata.local.preffutures.counts, 4 );
        end
        if isfield( masterdata.preffutures, 'diamonds' )
            masterdata.local.preffutures.diamonds = ... % pre-allocate
                zeros( size( masterdata.preffutures.diamonds ) );
            diamondweight = masterdata.local.preffutures.diamonds;
            NcountedLength = size( masterdata.preffutures.counts, 1 );
            Ncounted = 0;
            for i = 1 : size( masterdata.local.preffutures.diamonds, 5 )
                diamondweight( :, :, :, :, i ) = ...
                    double( sum( masterdata.preffutures. ...
                      diamonds( :, :, :, :, 1:i ), 5 ) );
                for c1 = 1 : size( masterdata.local.preffutures.diamonds, 3 )
                    for c2 = 1 : size( masterdata.local.preffutures.diamonds, 4 )
                        if haspreffuturecounts
                            Ncounted = ( 0:1:( NcountedLength - 1 ) ) ...
                                * double( sum( masterdata.preffutures.counts( ...
                                    1:NcountedLength, c1, c2, 1:i ), 4 ) );
                        end
                        masterdata.local.preffutures.diamonds( :, :, c1, c2, i ) = ...
                            diamondweight( :, :, c1, c2, i ) / runs / max( 1, Ncounted );
                    end
                end
            end
            masterdata.local.preffutures.diamonds = ...
                flip( masterdata.local.preffutures.diamonds, 5 );
        end
        if isfield( masterdata.preffutures, 'dimensions' )
            masterdata.local.preffutures.dimensions = ... % pre-allocate
                zeros( size( masterdata.preffutures.dimensions ) );
            for type = 1 : size( masterdata.preffutures.dimensions, 1 )
                for i = 1 : size( masterdata.preffutures.dimensions, 5 )
                    temp = double( sum( masterdata.preffutures.dimensions( type, :, :, :, 1:i ), 5 ) );
                    for c1 = 1 : size( masterdata.preffutures.dimensions, 3 )
                        for c2 = 1 : size( masterdata.preffutures.dimensions, 4 )
                            masterdata.local.preffutures.dimensions( type, :, c1, c2, i ) = ...
                                temp( 1, :, c1, c2 ) / sum( temp( 1, :, c1, c2 ) );
                        end
                    end
                end
            end
            masterdata.local.preffutures.dimensions = ...
                flip( masterdata.local.preffutures.dimensions, 5 );
        end
        if isfield( masterdata.preffutures, 'propertimes' )
            masterdata.local.preffutures.propertimes = ... % pre-allocate
                zeros( size( masterdata.preffutures.propertimes ) );
            for i = 1 : size( masterdata.preffutures.propertimes, 4 )
                temp = double( sum( masterdata.preffutures.propertimes( :, :, :, 1:i ), 4 ) );
                for c1 = 1 : size( masterdata.preffutures.propertimes, 2 )
                    for c2 = 1 : size( masterdata.preffutures.propertimes, 3 )
                        masterdata.local.preffutures.propertimes( :, c1, c2, i ) = ...
                            temp( :, c1, c2 ) / sum( temp( :, c1, c2 ) );
                    end
                end
            end
            masterdata.local.preffutures.propertimes = ...
                flip( masterdata.local.preffutures.propertimes, 4 );
        end
    end
    %% save pre-processed data:
    for f = { 'eventcounts', 'futureinfinities', 'diamonds', ...
              'diamondtimes', 'dimensions', 'propertimes', ...
              'preffutures' }
        fieldname = char( f );
        data = struct();
        if isfield( masterdata.local, fieldname )
            if isstruct( masterdata.local.(fieldname) )
                data = masterdata.local.(fieldname); %#ok<NASGU>
            else
                data.(fieldname) = masterdata.local.(fieldname); %#ok<STRNU>
            end
            save( sprintf( '%s.%s.mat', filename, fieldname ), ...
                '-struct', 'data' );
        end
    end
end

