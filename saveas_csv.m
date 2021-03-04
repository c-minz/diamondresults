function saveas_csv( filename, Y, X, yaxisscale )
%SAVEAS_CSV saves the data Y as a column vector in text form to
% FILENAME.csv
% 
% Arguments:
% FILENAME            filename without extension. The extension is added.
% Y                   y data vector to be saved in the second column of the
%                     text output file. The data is stored as floating
%                     point with a precision of 5 decimals.
% 
% Optional arguments:
% X                   x data vector, must have the same length as Y.
%                     (Default: index of Y)
%                     Integer values are saved without decimals, floating
%                     point numbers with a precision of 5 decimals.
% YAXISSCALE          type of scaling for the Y axis. Use 'linear'
%                     (Default) to leave Y data unchanged and the file is 
%                     written with the extension '.csv'. With 'log' the
%                     logarithm of the Y data is stored and the file
%                     extension is '.log.csv'.
    
    if nargin < 4
        yaxisscale = 'linear';
    end
    if strcmp( yaxisscale, 'linear' )
        % save to data file, y-axis in linear scale:
        fileID = fopen( sprintf( '%s.%s', filename, 'csv' ), 'w' );
        for i = 1 : length( Y )
            if nargin < 3
                fprintf( fileID, '%d, %0.5f\n', i, Y( i ) );
            elseif isinteger( X( i ) )
                fprintf( fileID, '%d, %0.5f\n', X( i ), Y( i ) );
            else
                fprintf( fileID, '%0.5f, %0.5f\n', X( i ), Y( i ) );
            end
        end
        fclose( fileID );
    elseif strcmp( yaxisscale, 'log' )
        % save to data file, y-axis in linear scale:
        Y = log( Y );
        if nargin < 3
            saveas_csv( sprintf( '%s.%s', filename, 'log' ), Y );
        else
            saveas_csv( sprintf( '%s.%s', filename, 'log' ), Y, X );
        end
    end
end

