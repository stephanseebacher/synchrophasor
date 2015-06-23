# synchrophasor
A MATLAB implementation of the synchrophasor reference algorithm
in IEEE C37.118.1-2011. 

## Howto?
In MATLAB, run

    >> synchrophasor

To calculate a synchrophasor for one phase, use one of the following

    >> X1( i )
    >> X2( i )
    >> X3( i )
	
for phase 1, 2 or 3 respectively. Be aware that you can't calculate phasors
earlier than `Fs/f` samples (in the current code this value is 80) and later 
than `Fs - (Fs/f)`. The reason for this is that during the calculation, sample
values from one cycle before and one cycle after the current position i are
needed.

Phasors for the positive sequence can be calculated by calling

    >> Xp( i )

Unfortunately, calculating multiple phasors at once also doesn't work 
(e.g. `X1(100:200)`). If you, for example, want to plot them, you have to do
a workaround like this:

    >> for i = start_index : end_index
    >>     foo( i ) = X1( i );
    >> end

Phasor angles are derived like this:

    >> r2d(angle( X1( i )))

`angle()` returns the angle of the complex value that is returned by `X1( i )`,
`r2d()` converts this angle from radians to degrees.