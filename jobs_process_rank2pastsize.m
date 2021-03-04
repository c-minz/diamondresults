function jobs_process_rank2pastsize( Ns, dims, ...
    shapes, targetdir )
%JOBS_PROCESS_RANK2PASTSIZE processes combined job files for causet
% size N and dimensions DIMS to extract diamond link counts. It creates CSV
% files for legend labels.
% 
% Arguments:
% NS                  vector of numbers of elements in the causets.
% DIMS                array of spacetime dimensions.
% 
% Optional arguments:
% SHAPES              string array of shape names. 
%                     Default: { 'Bicone' }
% TARGETDIR           directory for processed file output. 
%                     Default: 
%                     data/Diamonds

    %% set default values:
    if nargin < 3 || isempty( shapes )
        shapes = { 'Bicone' };
    end
    if nargin < 4 || isempty( targetdir )
        targetdir = 'data/Diamonds';
    end
    %% create LaTeX file for each dimension:
    for d = dims
        for shapecell = shapes
            shape = char( shapecell );
            for N = Ns
                paramstr = jobs_getparamstr( N, d, shape );
                results = load( jobs_getfilename( paramstr, 'mat' ), ...
                    'eventcounts', 'futureinfinities', 'diamonds' );
                Y = double( sum( results.diamonds( :, :, :, 1 ), [ 1, 2 ] ) );
                Y = reshape( Y, [ 1, size( Y, 3 ) ] );
                weight = double( results.eventcounts - ...
                    results.futureinfinities( 2, : ) );
                X = ( 1:length( Y ) ) - 0.5;
                saveas_csv( sprintf( '%s/%s', ...
                    targetdir, paramstr ), Y ./ weight, X );
            end
        end
    end
end

