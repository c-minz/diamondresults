function jobs_processfile_unithyperboloid( paramstr, ...
    attributions, paramstrext, targetdir )
%JOBS_PROCESSFILE_UNITHYPERBOLOID loads a combined job file and stores 
% data tables for proper time separation distribution in csv files (to be 
% plotted with LaTeX-TikZ). 
% Columns in the output files are ( radial unit hyperboloid coordinate, 
%                                   probability ).
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
% PARAMSTREXT         extra name parameters for the file to be processed.
% TARGETDIR           directory for processed csv file output. 
%                     Default: data/UnitHyperboloid
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    %% set default values:
    if nargin < 2 || isempty( attributions )
        attributions = { 0, 0, 3, 1 };
    end
    paramstr_load = paramstr;
    if nargin >= 3 && ~isempty( paramstrext )
        paramstr_load = [ paramstr_load, paramstrext ];
    end
    if nargin < 4 || isempty( targetdir )
        targetdir = 'data/UnitHyperboloid';
    end
    %% load data:
    results = load( jobs_getfilename( paramstr_load, 'mat' ), ...
        'maxhyperbcoord', 'maxhyperbspeed' );
    %% process all selected indexes:
    for i = 1 : size( attributions, 1 )
        for cri = attributions{ i, 1 }
        for cmi = attributions{ i, 2 }
        for vol = attributions{ i, 3 }
        for arr = attributions{ i, 4 }
            %% select data:
            if cri == 0
                if ~isfield( results, 'unithyperboloid' )
                    temp = load( jobs_getfilename( paramstr_load, 'mat' ), ...
                        'unithyperboloid' );
                    results.unithyperboloid = temp.unithyperboloid;
                    clear temp;
                end
                Y = results.unithyperboloid{ vol, arr };
                thisparamstr = sprintf( '%sArr%dVol%dScatter', ...
                    paramstr, arr, vol );
            else
                if ~isfield( results, 'unithyperboloid' )
                    temp = load( jobs_getfilename( paramstr_load, 'mat' ), ...
                        'preffutures' );
                    results.preffutures.unithyperboloid = ...
                        temp.preffutures.unithyperboloid;
                    clear temp;
                end
                Y = results.preffutures.unithyperboloid{ cri, cmi, vol };
                thisparamstr = sprintf( '%sCri%dMin%dVol%dScatter', ...
                    paramstr, cri, cmi, vol );
            end
            %[ ~, ~, Y ] = hyperb_rescaled( Y );
            %% save unit hyperboloid distributions to csv files:
            writematrix( Y, sprintf( '%s/%s.csv', targetdir, thisparamstr ) );
        end
        end
        end
        end
    end
end

