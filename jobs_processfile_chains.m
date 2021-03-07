function jobs_processfile_chains( paramstr, ...
    targetdir )
%JOBS_PROCESSFILE_CHAINS loads a combined job file, computes and stores a
% matrix as LaTeX file. The matrix shows the dimension estimates for the 
% causal interval between 1 and N (row 1), the larger (row 2) and smaller
% (row 3) of the two causal intervals between the midpoint and 1 or N.
% 
% Arguments:
% PARAMSTR            name of the file (without extension) to be processed.
% 
% Optional arguments:
% TARGETDIR           directory for processed csv file output. 
%                     Default: data/Dimensions
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    %% set default values:
    if nargin < 2 || isempty( targetdir )
        targetdir = 'data/Dimensions';
    end
    %% load chains from results file:
    results = load( jobs_getfilename( paramstr, 'mat' ), ...
        'chains', 'runs' );
    results.chains = double( results.chains ) / results.runs;
    %% compute dimension estimators:
    Y = zeros( 3, 3 );
    for r = 1 : 3
        Y( r, 1 ) = causet_get_MMdim( results.chains( r, 1:2 ) );
        Y( r, 2 ) = causet_get_MMdim( results.chains( r, 1:4 ) );
    end
    Y( 1, 3 ) = log2( results.chains( 1, 1 ) ) + 1 ...
      - log2( results.chains( 2, 1 ) + results.chains( 3, 1 ) );
    Y( 2, 3 ) = log2( results.chains( 1, 1 ) ) ...
      - log2( results.chains( 2, 1 ) );
    Y( 3, 3 ) = log2( results.chains( 1, 1 ) ) ...
      - log2( results.chains( 3, 1 ) );
    %% store results as LaTeX matrix:
    fileID = fopen( sprintf( '%s/%sDim.tex', targetdir, paramstr ), 'w' );
    fprintf( fileID, matrix2latex( Y ) );
    fclose( fileID );
end

