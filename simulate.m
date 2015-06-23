function [ signal ] = simulate( f, Fs, L, A )
%SIMULATE Simulate a three phase system

%t = 0 : L-1;
t = 1 : L;

phase1 = A * cos( 2 * pi * f / Fs * t );
phase2 = A * cos( 2 * pi * f / Fs * t - 2 * pi / 3 );
phase3 = A * cos( 2 * pi * f / Fs * t - 4 * pi / 3 );

signal = [phase1; phase2; phase3];
end

