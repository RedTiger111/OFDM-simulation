# Sobel Filter Implementation in Verilog

This project is OFDM simulation in matlab.
using 16-QAM modulation and demodulation.
in channel, i use AWGN noise channel and layleigh fading.

## Simmulation Operation

-Tx 
1. png to binary.
2. Modulation.
3. serial to parallel.
4. CP & AWGN & Rayleigh fading.

-Rx 
1. Eliminate CP
2. Channel Reconstruction
3. Remove Reference Signal
4. Demodulation
5. Reconstruction image

## Image and Operation Details

The project uses a 170x173 "bapoon" image as the input. The OFDM operation is applied to this image, generating an output image that include rayleigh & awgn channel.
