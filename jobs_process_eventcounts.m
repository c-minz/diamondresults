function jobs_process_eventcounts( Ns, dims, ...
    subvolumes, shapes, targetdir )
%JOBS_PROCESS_EVENTCOUNTS processes combined job files for causet
% size N and dimensions DIMS to extract diamond link counts. It creates TEX
% files for legend labels.
% 
% Arguments:
% NS                  vector of numbers of elements in the causets.
% DIMS                array of spacetime dimensions.
% 
% Optional arguments:
% SUBVOLUMES          either a single index or a vector of indexes.
%                       1 entire causet
%                       2 one top volume layer removed
%                       3 two top volume layers removed
%                       ...
%                     (Default: 1:6)
% SHAPES              string array of shape names. 
%                     Default: { 'Bicone' }
% TARGETDIR           directory for processed file output. 
%                     Default: 
%                     data/Diamonds

    %% set default values:
    if nargin < 3
        subvolumes = 1:6;
    end
    if nargin < 4 || isempty( shapes )
        shapes = { 'Bicone' };
    end
    if nargin < 5 || isempty( targetdir )
        targetdir = 'data/Diamonds';
    end
    %% create LaTeX file for each dimension:
    for d = dims
        for shapecell = shapes
            shape = char( shapecell );
            %% combine event counts to legend label strings:
            legendlabels = cell( 1, length( subvolumes ) );
            i = 0;
            Ncount = length( Ns );
            for N = Ns
                paramstr = jobs_getparamstr( N, d, shape );
                results = load( jobs_getfilename( paramstr, 'mat' ), ...
                    'eventcounts', 'futureinfinities', 'N', 'runs' );
                results.eventcounts = double( results.eventcounts );
                results.futureinfinities = ...
                    double( results.futureinfinities ) / results.eventcounts( 1 );
                results.eventcounts = results.eventcounts / results.eventcounts( 1 );
                shading = sprintf( '\\textcolor{black!%0.1f}{', ...
                    100 * ( 1 - i / Ncount ) );
                i = i + 1;
                j = 0;
                for vol = subvolumes
                    j = j + 1;
                    vpercentage = results.eventcounts( vol ) * 100;
                    cpercentage = vpercentage ...
                        * ( 1 - results.futureinfinities( 2, vol ) );
                    if vpercentage < 9.995
                        vpadding = '\phantom{00}';
                    elseif vpercentage < 99.995
                        vpadding = '\phantom{0}';
                    else
                        vpadding = '';
                    end
                    if cpercentage < 9.995
                        cpadding = '\phantom{0}';
                    else
                        cpadding = '';
                    end
                    legendlabels{ j } = [ legendlabels{ j }, ...
                        shading, sprintf( '%s%0.2f~(%s%0.2f)', ...
                        vpadding, vpercentage, cpadding, cpercentage ), '} ' ];
                end
            end
            %% open new file to save the label strings:
            fileID = fopen( sprintf( '%s/D%d%sLabels.tex', targetdir, d, lower( shape ) ), 'w' );
            for i = 1 : length( legendlabels )
                fprintf( fileID, '\\def\\legendlabel%c{%s}\n', 64 + i, legendlabels{ i } );
            end
            fclose( fileID );
        end
    end
end

