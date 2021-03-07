function jobs_preprocess( Ns, dims, shapes )
%JOBS_PREPROCESS loads combined job files and computes averages for the 
% statistics. The expectation values per event in a respective causet are 
% stored in new files, which have the fieldname appended to the filename.
% 
% Arguments:
% NS                  array of numbers of elements in the causet.
% DIMS                array of spacetime dimensions.
% 
% Optional arguments:
% SHAPES              string array of shape names. 
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    %% set default values:
    if nargin < 3 || isempty( shapes )
        shapes = { 'Bicone' };
    end
    %% run through Ns, dimensions and shapes:
    for N = Ns
        for d = dims
            for shape = shapes
                filename = jobs_getfilename( ...
                    jobs_getparamstr( N, d, shape ) );
                jobs_preprocessfile( filename );
            end
        end
    end
end

