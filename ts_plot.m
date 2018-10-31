function ts_plot( X, varargin )
% @brief Plots a matrix of time series in 1xN subplots
%
% @details Plots a matrix of time series in 1xN subplots.  This function assumes
% that T>N, where T is the length of each time series and N is the number of
% time series.  If this is not the case, pass in NO_FLIP == 1 as the last
% argument to prevent forcing this assumption.
%
% @param X = array of time series
% @param varargin{1} = NO_FLIP (binary), 1 to override T>N assumption, 0 o.w.
%   
% @Example
% @code
%   X = rand(2,100);
%   ts_plot( X );
% @endcode   

  % check inputs
  opts = cell2struct(varargin(2:2:end),varargin(1:2:end),2);
  NO_FLIP = 0;
  if isfield(opts,'NO_FLIP')
    NO_FLIP = opts.NO_FLIP;
  end   
  
  TITLES = {};
  if isfield(opts,'TITLES')
     TITLES = opts.TITLES;
  end

  % Typically the length of the time series is greater than the number of time
  % series
  if ( size(X,1) > size(X,2) & ~NO_FLIP )
    disp( 'ts_plot: Number of time series greater than number of data points.  Flipping and continuing.' );
    X = X';
  end
  
  for i = 1:size(X,1)
    subplot(size(X,1),1,i);
    plot( X(i,:) );
    if ( ~isempty( TITLES ) )
       title( TITLES{i} );
    end
  end
