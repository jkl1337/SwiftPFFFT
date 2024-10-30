[![CI](https://github.com/jkl1337/SwiftPFFFT/actions/workflows/swift.yml/badge.svg)](https://github.com/jkl1337/SwiftPFFFT/actions/workflows/swift.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjkl1337%2FSwiftPFFFT%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/jkl1337/SwiftPFFFT)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjkl1337%2FSwiftPFFFT%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/jkl1337/SwiftPFFFT)

# SwiftPFFFT

Swift package providing a PFFFT (Pretty Fast, Fast Fourier Transform) library with wrapper.

This code is based on the marton78 fork of PFFFT that was forked from the original PFFFT implementation
by Julien Pommier. This fork provides support for doubles in addition to floats and provides additional SIMD implementations:

The origin for the C implementation in this package is https://github.com/marton78/pffft.

PFFFT provides substantial performance improvement over KissFFT. The advantage over FFTW is reasonable
performance with much simpler usage and a permissive 3 clause BSD license.

## Example

``` swift

// construct an interface for FFT, IFFT and convolutions. The interface is parameterized on the
// type of element in the signal (time) domain. The spectrum (frequency) domain type will always be
// complex. For a real valued signal the spectrum size will be `n / 2`, with the packing convention
// 
let fft = try FFT<Complex<Float>>(n: 16)
let signal = fft.makeSignalBuffer()

signal.mapInPlace { (i, v) in
    v = Complex(Float(i) + 1.0, Float(i) - 2.0)
}

let spectrum = fft.makeSpectrumBuffer()
fft.forward(signal: signal, spectrum: spectrum)

fft.inverse(spectrum: spectrum, signal: signal)

```
