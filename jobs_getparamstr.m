function filename = jobs_getparamstr( N, d, shape )
%JOBS_GETPARAMSTR returns the parameter string part of the filename. 
% 
% Arguments:
% N                   cardinality of the causet.
% D                   sprinkling dimension of the causet.
% 
% Optional arguments:
% SHAPE               name of the shape, default: 'Bicone'.

    if nargin < 3 || isempty( shape )
        shape = 'Bicone';
    end
    filename = sprintf( 'N%dD%d%s', N, d, lower( char( shape ) ) );
end

