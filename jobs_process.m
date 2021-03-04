function jobs_process( Ns, dims, ...
    shapes )
%JOBS_PROCESS processes combined job files for causet sizes NS and 
% dimensions DIMS.
% 
% Arguments:
% NS                  vector of causet cardinalities.
% DIMS                vector of spacetime dimensions.
% 
% Optional arguments:
% SHAPES              cell array of shape names. 
%                     Default: { 'Bicone' }

    %% set default values:
    if nargin < 3 || isempty( shapes )
        shapes = { 'Bicone' };
    end
    %% process all N-causets from d-dimensional shapes:
    for N = Ns
        for d = dims
            for shape = shapes
                paramstr = jobs_getparamstr( N, d, shape );
                %% counts of preferred futures
                % criteria 1 to 6, including 1 subrelation, at subvolume 3
                jobs_processfile_preffutures( paramstr, ...
                    { 1:6, 1, 3 } );
                %% proper time separation distributions
                % criteria 1 to 6, including 1 subrelation, at subvolume 3;
                % at subvolume 1, arrangements 2 and 3 (geodesic chains)
                jobs_processfile_propertimes( paramstr, ...
                    { 1:6, 1, 3, 1; ...
                      0, 0, 1, [2, 3] } );
                %% diamond link distributions
                % criterium 5, including 1 subrelation, at subvolumes 1 to 6;
                % at subvolume 1, arrangements 2 and 3 (geodesic chains)
                jobs_processfile_diamonds( paramstr, -1, ...
                    { 5, 1, 1:6, 0; ...
                      0, 0, 1, [2, 3] } );
                %% dimension distributions
                % at subvolume 1, arrangements 2 and 3 (geodesic chains);
                % at subvolume 3, arrangements 1 (entire causet);
                % criteria 1 to 6, including 1 subrelation, at subvolume 3
                jobs_processfile_dimensions( paramstr, ...
                    { 0, 0, 1, [ 2, 3 ]; ...
                      0, 0, 3, 1; ...
                      1:6, 1, 3, 1 } );
                %% proper time separation by link size
                % at subvolume 3, with 0 (pure), 2 to 9 subrelated events
                jobs_processfile_diamondtimes( paramstr, ...
                    [ 0, 2 : 1 : 9 ], { 3 } );
                %% matrix of global spacetime dimension estimates
                jobs_processfile_chains( parmastr );
            end
        end
    end
    %% event count table for the legend in diamond link distributions
    jobs_process_eventcounts( Ns, dims, 1:6, shapes );
end

