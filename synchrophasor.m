% C37_118 Synchrophasor reference signal processing models ----------------
% According to C37.118.1-2011 p. 29f (41) / 61

%% CONSTS -----------------------------------------------------------------
f   = 51;                           % signal frequency
f0  = 50;                           % nominal frequency
w0  = 2 * pi * f0;                  % angular frequency
Fs  = 4000;                         % sampling frequency
L   = 4000;                         % sampling length
dt  = 1 / Fs;                       % time diff
Spc = Fs / f0;                      % samples per cycle (has to be INT)
A   = 9;                            % amplitude
C   = 1.625;                        % correction factor, see p. 33 (45)
N   = ( Fs / f0 - 1 ) * 2;          % FIR filter order
rng = -N/2 : N/2;                   % sum range
%Gd = (N / 2) * dt;                 % filter group delay
%% ANONYMOUS FUNCTIONS ----------------------------------------------------
filter = @( x ) ( 1 - ( 2 * abs( x ) / ( N+2 )));  % filter coefficients ..
                                    % .. for P class (C.5)
gain = sum( filter( rng ));         % gain
r2d = @( r ) ( r * 180 / pi );      % radians to degrees conversion
%% SAMPLES ----------------------------------------------------------------

% calculate samples
samples = simulate( f, Fs, L, A );

s1 = @( x ) samples( 1, x );
s2 = @( x ) samples( 2, x );
s3 = @( x ) samples( 3, x );

%% synchrophasor estimation formula ---------------------------------------

%% single phase phasor calculation
Xx = @( s, i ) ( sqrt( 2 ) / gain * sum( s( i + rng ) .* filter( rng) .* ...
	exp( -1j * ( i + rng ) * dt * w0 )));
X1 = @( i ) Xx( s1, i );
X2 = @( i ) Xx( s2, i );
X3 = @( i ) Xx( s3, i );
%X1 = @( i ) ( sqrt(2) / gain * sum( s1( i + rng ) .* filter( rng ) .* ...
%    exp( -1j * (i + rng ) * dt * w0 )));
%X2 = @( i ) ( sqrt(2) / gain * sum( s2( i + rng ) .* filter( rng ) .* ...
%    exp( -1j * (i + rng ) * dt * w0 )));
%X3 = @( i ) ( sqrt(2) / gain * sum( s3( i + rng ) .* filter( rng ) .* ...
%    exp( -1j * (i + rng ) * dt * w0 )));

Xabc = @( i ) ( [ X1( i ); X2( i ); X3( i ) ]);

%% positive sequence calculation
% using symmetrical component transformation
alpha = exp( 1j * 2/3 * pi );
%M = 1/3 * [1 1 1; 1 alpha alpha^2; 1 alpha^2 alpha];
Mp = 1/3 * [ 1 alpha alpha^2 ]; % we only need the positive sequence

% zero, positive and negative sequence phasors
%Xzpn = M * Xabc;
Xp = @( i ) ( Mp * Xabc( i )); % only positive sequence

%% frequency estimation ---------------------------------------------------
a = @( x, i ) angle( x ( i ));

% Offset from nominal! Frequency = f0 + FREQ( x )
%   C37.118.1a-2014, Amendment 1 changes the following formula
% FREQ = @( i ) (f0 - (( 6 * ( a( Xp, i   ) - a( Xp, i-1 )) + ...
%                        3 * ( a( Xp, i-1 ) - a( Xp, i-2 )) + ...
%                        1 * ( a( Xp, i-2 ) - a( Xp, i-3 )) ) ...
%                       / ( 20 * pi * dt )));
FREQ = @( i ) (( a( Xp, i+1 ) - a( Xp, i-1 )) / ( 4 * pi * dt ));

%% ROCOF estimation -------------------------------------------------------
%   C37.118.1a-2014, Amendment 1 changes the following formula
%ROCOF = @( i ) (( FREQ( i ) - FREQ( i-1 )) / dt);
ROCOF = @( i ) (( a( Xp, i+1 ) + a( Xp, i-1 ) - 2 * a( Xp, i )) / ...
                ( 2 * pi * dt^2 ));

%% synchrophasor estimation w/ correction ---------------------------------
X1corr = @( i ) ( X1(i) / sin( pi * ( f0 + C * FREQ( i ) / ( 2 * f0 ))));
X2corr = @( i ) ( X2(i) / sin( pi * ( f0 + C * FREQ( i ) / ( 2 * f0 ))));
X3corr = @( i ) ( X3(i) / sin( pi * ( f0 + C * FREQ( i ) / ( 2 * f0 ))));
