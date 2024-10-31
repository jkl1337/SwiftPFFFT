import ComplexModule
@testable import PFFFT
import XCTest

final class FFTTests: XCTestCase {
    func testFftComplexFloat() throws {
        let fft = try FFT<Complex<Float>>(n: 16)
        let signal = fft.makeSignalBuffer()
        let spectrum = fft.makeSpectrumBuffer()

        signal.enumerateInPlace { i, v in
            v = Complex(Float(i) + 1.0, Float(i) - 2.0)
        }

        fft.forward(signal: signal, spectrum: spectrum)

        let result = spectrum.map { $0 }
        let expected: [Complex<Float>] = [
            .init(136.0, 88.0),
            .init(-48.218716, 32.218716),
            .init(-27.31371, 11.313708),
            .init(-19.972847, 3.972846),
            .init(-16.0, 0.0),
            .init(-13.345428, -2.6545706),
            .init(-11.313709, -4.6862917),
            .init(-9.591298, -6.408703),
            .init(-8.0, -8.0),
            .init(-6.408703, -9.591298),
            .init(-4.6862917, -11.313708),
            .init(-2.6545706, -13.345429),
            .init(0.0, -16.0),
            .init(3.972845, -19.972847),
            .init(11.313707, -27.31371),
            .init(32.218716, -48.218716),
        ]
        for (r, e) in zip(result, expected) {
            XCTAssert(r.isApproximatelyEqual(to: e))
        }

        fft.inverse(spectrum: spectrum, signal: signal)

        let signalResult = signal.map { $0 }
        let signalExpected = (0 ..< 16).map { i in
            Complex(Float(i) + 1.0, Float(i) - 2.0) * 16
        }

        for (r, e) in zip(signalResult, signalExpected) {
            XCTAssert(r.isApproximatelyEqual(to: e))
        }
    }
}
