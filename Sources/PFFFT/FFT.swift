internal import PFFFTLib
import ComplexModule
import RealModule

@frozen
public enum FFTType {
    case real
    case complex
}

@frozen
public enum FFTSign {
    case forward
    case backward
}

public enum FFTError: Error {
    case invalidSize
}

public protocol FFTElement {
    associatedtype FFTScalarType: FFTScalar
    associatedtype FFTComplexType = Complex<FFTScalarType>

    static func pffftSetup(_ n: Int, _ type: FFTType) throws -> OpaquePointer
    static func pffftMinFftSize(_ type: FFTType) -> Int
    static func pffftIsValidSize(_ n: Int, _ type: FFTType) -> Bool
    static func pffftNearestValidSize(_ n: Int, _ type: FFTType, _ higher: Bool) -> Int
}

public protocol FFTScalar: Real {
    static func pffftTransformOrdered(_ ptr: OpaquePointer, _ input: UnsafeMutablePointer<Self>, _ output: UnsafeMutablePointer<Self>, _ work: UnsafeMutablePointer<Self>?, _ dir: FFTSign)
    static func pffftTransform(_ ptr: OpaquePointer, _ input: UnsafeMutablePointer<Self>, _ output: UnsafeMutablePointer<Self>, _ work: UnsafeMutablePointer<Self>?, _ dir: FFTSign)
    static func pffftZreorder(_ ptr: OpaquePointer, _ input: UnsafeMutablePointer<Self>, _ output: UnsafeMutablePointer<Self>, _ dir: FFTSign)
    static func pffftZconvolveAccumulate(_ ptr: OpaquePointer, _ dftA: UnsafeMutablePointer<Self>, _ dftB: UnsafeMutablePointer<Self>, _ dftAB: UnsafeMutablePointer<Self>, _ scaling: Self)
    static func pffftZconvolveNoAccu(_ ptr: OpaquePointer, _ dftA: UnsafeMutablePointer<Self>, _ dftB: UnsafeMutablePointer<Self>, _ dftAB: UnsafeMutablePointer<Self>, _ scaling: Self)
    static func pffftSimdArch() -> String
}

extension Float: FFTScalar {
    public static func pffftTransformOrdered(_ ptr: OpaquePointer, _ input: UnsafeMutablePointer<Self>, _ output: UnsafeMutablePointer<Self>, _ work: UnsafeMutablePointer<Self>?, _ dir: FFTSign) {
        pffft_transform_ordered(ptr, input, output, work, pffft_direction_t(dir))
    }

    public static func pffftTransform(_ ptr: OpaquePointer, _ input: UnsafeMutablePointer<Self>, _ output: UnsafeMutablePointer<Self>, _ work: UnsafeMutablePointer<Self>?, _ dir: FFTSign) {
        pffft_transform(ptr, input, output, work, pffft_direction_t(dir))
    }

    public static func pffftZreorder(_ ptr: OpaquePointer, _ input: UnsafeMutablePointer<Self>, _ output: UnsafeMutablePointer<Self>, _ dir: FFTSign) {
        pffft_zreorder(ptr, input, output, pffft_direction_t(dir))
    }

    public static func pffftZconvolveAccumulate(_ ptr: OpaquePointer, _ dftA: UnsafeMutablePointer<Self>, _ dftB: UnsafeMutablePointer<Self>, _ dftAB: UnsafeMutablePointer<Self>, _ scaling: Self) {
        pffft_zconvolve_accumulate(ptr, dftA, dftB, dftAB, scaling)
    }

    public static func pffftZconvolveNoAccu(_ ptr: OpaquePointer, _ dftA: UnsafeMutablePointer<Self>, _ dftB: UnsafeMutablePointer<Self>, _ dftAB: UnsafeMutablePointer<Self>, _ scaling: Self) {
        pffft_zconvolve_no_accu(ptr, dftA, dftB, dftAB, scaling)
    }

    public static func pffftSimdArch() -> String {
        String(cString: pffft_simd_arch())
    }
}

extension Double: FFTScalar {
    public static func pffftTransformOrdered(_ ptr: OpaquePointer, _ input: UnsafeMutablePointer<Double>, _ output: UnsafeMutablePointer<Double>, _ work: UnsafeMutablePointer<Double>?, _ dir: FFTSign) {
        pffftd_transform_ordered(ptr, input, output, work, pffft_direction_t(dir))
    }

    public static func pffftTransform(_ ptr: OpaquePointer, _ input: UnsafeMutablePointer<Double>, _ output: UnsafeMutablePointer<Double>, _ work: UnsafeMutablePointer<Double>?, _ dir: FFTSign) {
        pffftd_transform(ptr, input, output, work, pffft_direction_t(dir))
    }

    public static func pffftZreorder(_ ptr: OpaquePointer, _ input: UnsafeMutablePointer<Double>, _ output: UnsafeMutablePointer<Double>, _ dir: FFTSign) {
        pffftd_zreorder(ptr, input, output, pffft_direction_t(dir))
    }

    public static func pffftZconvolveAccumulate(_ ptr: OpaquePointer, _ dftA: UnsafeMutablePointer<Double>, _ dftB: UnsafeMutablePointer<Double>, _ dftAB: UnsafeMutablePointer<Double>, _ scaling: Double) {
        pffftd_zconvolve_accumulate(ptr, dftA, dftB, dftAB, scaling)
    }

    public static func pffftZconvolveNoAccu(_ ptr: OpaquePointer, _ dftA: UnsafeMutablePointer<Double>, _ dftB: UnsafeMutablePointer<Double>, _ dftAB: UnsafeMutablePointer<Double>, _ scaling: Double) {
        pffftd_zconvolve_no_accu(ptr, dftA, dftB, dftAB, scaling)
    }

    public static func pffftSimdArch() -> String {
        String(cString: pffftd_simd_arch())
    }
}

extension Complex: FFTElement where RealType: FFTElement & FFTScalar {
    public typealias FFTScalarType = RealType
    public typealias FFTComplexType = Self

    public static func pffftSetup(_ n: Int, _: FFTType) throws -> OpaquePointer {
        return try FFTScalarType.pffftSetup(n, .complex)
    }

    public static func pffftMinFftSize(_: FFTType) -> Int {
        return FFTScalarType.pffftMinFftSize(.complex)
    }

    public static func pffftIsValidSize(_ n: Int, _: FFTType) -> Bool {
        return FFTScalarType.pffftIsValidSize(n, .complex)
    }

    public static func pffftNearestValidSize(_ n: Int, _: FFTType, _ higher: Bool) -> Int {
        return FFTScalarType.pffftNearestValidSize(n, .complex, higher)
    }
}

extension Double: FFTElement {
    public typealias FFTScalarType = Double

    public static func pffftSetup(_ n: Int, _ type: FFTType) throws -> OpaquePointer {
        guard let ptr = pffftd_new_setup(Int32(n), pffft_transform_t(type)) else { throw FFTError.invalidSize }
        return ptr
    }

    public static func pffftMinFftSize(_ type: FFTType) -> Int {
        Int(pffftd_min_fft_size(pffft_transform_t(type)))
    }

    public static func pffftIsValidSize(_ n: Int, _ type: FFTType) -> Bool {
        pffftd_is_valid_size(Int32(n), pffft_transform_t(type)) != 0
    }

    public static func pffftNearestValidSize(_ n: Int, _ type: FFTType, _ higher: Bool) -> Int {
        Int(pffftd_nearest_transform_size(Int32(n), pffft_transform_t(type), higher ? 1 : 0))
    }
}

extension Float: FFTElement {
    public typealias FFTScalarType = Float

    public static func pffftSetup(_ n: Int, _ type: FFTType) throws -> OpaquePointer {
        guard let ptr = pffft_new_setup(Int32(n), pffft_transform_t(type)) else { throw FFTError.invalidSize }
        return ptr
    }

    public static func pffftMinFftSize(_ type: FFTType) -> Int {
        Int(pffft_min_fft_size(pffft_transform_t(type)))
    }

    public static func pffftIsValidSize(_ n: Int, _ type: FFTType) -> Bool {
        pffft_is_valid_size(Int32(n), pffft_transform_t(type)) != 0
    }

    public static func pffftNearestValidSize(_ n: Int, _ type: FFTType, _ higher: Bool) -> Int {
        Int(pffft_nearest_transform_size(Int32(n), pffft_transform_t(type), higher ? 1 : 0))
    }
}

@frozen
public struct FFT<T: FFTElement>: ~Copyable {
    public typealias ComplexType = T.FFTComplexType
    public typealias ScalarType = T.FFTScalarType

    let ptr: OpaquePointer
    let n: Int
    let work: Buffer<ScalarType>
    let setup: Setup

    public init(setup: Setup) {
        self.setup = setup
        ptr = setup.ptr
        n = setup.n

        let workCapacity = if n > 4096 {
            T.self == ComplexType.self ? 2 * n : n
        } else {
            0
        }
        work = Buffer(capacity: workCapacity)
    }

    /// Initialize the FFT implementation with the given size and type.
    /// Since an FFT setup for a given size and element type is expensive to create but consists
    /// of read only data, a global cache is used to reuse setups.
    /// - Parameters:
    /// - n: The size of the FFT.
    /// - Throws: `FFTError.invalidSize` if the size is invalid.
    public init(n: Int) throws {
        try self.init(setup: SetupCache.shared.get(n: n, type: T.self))
    }

    /// Make a buffer for the FFT (time-domain) signal.
    /// - Parameters:
    /// - extra: An extra number of elements to allocate.
    public func makeSignalBuffer(extra: Int = 0) -> Buffer<T> {
        Buffer(capacity: n + extra)
    }

    /// Make a buffer for the FFT (frequency-domain) spectrum.
    /// - Parameters:
    /// - extra: An extra number of elements to allocate.
    public func makeSpectrumBuffer(extra: Int = 0) -> Buffer<ComplexType> {
        Buffer(capacity: T.self == ComplexType.self ? (n + extra) : n / 2 + extra)
    }

    /// Make a buffer for the internal layout of the FFT (frequency-domain) spectrum.
    /// - Parameters:
    /// - extra: An extra number of points to allocate. For complex FFTs, 2 * extra
    /// additional elements will be allocated.
    public func makeInternalLayoutBuffer(extra: Int = 0) -> Buffer<ScalarType> {
        Buffer(capacity: (T.self == ComplexType.self ? 2 : 1) * (n + extra))
    }

    @inline(__always)
    var workPtr: UnsafeMutablePointer<ScalarType>? {
        if work.count > 0 {
            return work.baseAddress
        } else {
            return nil
        }
    }

    @inline(__always)
    func rebind<I>(_ buffer: borrowing Buffer<I>) -> UnsafeMutablePointer<ScalarType>! {
        UnsafeMutableRawBufferPointer(buffer.buffer).bindMemory(to: ScalarType.self).baseAddress
    }

    @inline(__always)
    func checkFftBufferCounts(signal: borrowing Buffer<T>, spectrum: borrowing Buffer<ComplexType>) {
        guard signal.count >= n else {
            fatalError("signal buffer too small")
        }
        guard spectrum.count >= (T.self == ComplexType.self ? n : n / 2) else {
            fatalError("spectrum buffer too small")
        }
    }

    @inline(__always)
    func checkFftInternalLayoutBufferCounts(signal: borrowing Buffer<T>, spectrum: borrowing Buffer<ScalarType>) {
        guard signal.count >= n else {
            fatalError("signal buffer too small")
        }
        guard spectrum.count >= (T.self == ComplexType.self ? 2 * n : n) else {
            fatalError("spectrum buffer too small")
        }
    }

    @inline(__always)
    func checkConvolveBufferCounts(a: borrowing Buffer<ScalarType>, b: borrowing Buffer<ScalarType>, ab: borrowing Buffer<ScalarType>) {
        let minCount = T.self == ComplexType.self ? 2 * n : n

        guard a.count >= minCount else {
            fatalError("a buffer too small")
        }
        guard b.count >= minCount else {
            fatalError("b buffer too small")
        }
        guard ab.count >= minCount else {
            fatalError("ab buffer too small")
        }
    }

    /// Perform a forward FFT on the input buffer.
    ///
    /// The input and output buffers may be the same.
    /// The data is stores in order as expected (interleaved complex components ordered by frequency).
    /// The input and output buffer must have a capacity of at least `n` for real FFTs and `2 * n` for complex FFTs.
    /// A fatal error will occur if any buffer is too small.
    ///
    /// For a real forward transform with real input, the output array is organized as follows:
    /// index k > 2 where k is even is the real part of the k/2-th complex coefficient.
    /// index k > 2 where k is odd is the imaginary part of the k/2-th complex coefficient.
    /// index k = 0 is the real part of the 0 frequency (DC) coefficient.
    /// index k = 1 is the real part of the Nyquist coefficient.
    ///
    /// Transforms are not scaled. fft_backward(fft_forward(x)) == n * x.
    ///
    /// - Parameters:
    ///  - input: The input buffer.
    ///  - output: The output buffer.
    ///  - work: An optional work buffer. Must have capacity of at least `n` for real FFTs and `2 * n` for complex FFTs.
    ///  - sign: The direction of the FFT.
    public func forward(signal: borrowing Buffer<T>, spectrum: borrowing Buffer<ComplexType>) {
        checkFftBufferCounts(signal: signal, spectrum: spectrum)
        ScalarType.pffftTransformOrdered(ptr, rebind(signal), rebind(spectrum), workPtr, .forward)
    }

    public func inverse(spectrum: borrowing Buffer<ComplexType>, signal: borrowing Buffer<T>) {
        checkFftBufferCounts(signal: signal, spectrum: spectrum)
        ScalarType.pffftTransformOrdered(ptr, rebind(spectrum), rebind(signal), workPtr, .backward)
    }

    /// Perform a forward FFT on the input buffer, with implementation defined order.
    ///
    /// This function behaves similarly to `fft` however the z-domain data is stored in most efficient ordering,
    /// which is suitable for transforming back with this function, or for convolution.
    /// - Parameters:
    ///  - input: The input buffer.
    ///  - output: The output buffer.
    ///  - work: An optional work buffer. Must have capacity of at least `n` for real FFTs and `2 * n` for complex FFTs.
    ///  - sign: The direction of the FFT.
    public func forwardToInternalLayout(signal: borrowing Buffer<T>, spectrum: borrowing Buffer<ScalarType>) {
        checkFftInternalLayoutBufferCounts(signal: signal, spectrum: spectrum)
        ScalarType.pffftTransform(ptr, rebind(signal), spectrum.baseAddress, workPtr, .forward)
    }

    public func inverseFromInternalLayout(spectrum: borrowing Buffer<ScalarType>, signal: borrowing Buffer<T>) {
        checkFftInternalLayoutBufferCounts(signal: signal, spectrum: spectrum)
        ScalarType.pffftTransform(ptr, spectrum.baseAddress, rebind(signal), workPtr, .backward)
    }

    public func reorder(spectrum: borrowing Buffer<ScalarType>, output: borrowing Buffer<ComplexType>) {
        guard spectrum.count >= (T.self == ComplexType.self ? 2 * n : n) else {
            fatalError("signal buffer too small")
        }
        guard output.count >= n else {
            fatalError("output buffer too small")
        }
        ScalarType.pffftZreorder(ptr, spectrum.baseAddress, rebind(output), .forward)
    }

    /// Perform a convolution of two complex signals in the frequency domain.
    ///
    /// Multiplies frequency domain components of `dftA` and `dftB` and stores the result in `dftAB`.
    /// The operation performed is `dftAB = (dftA * dftB) * scaling`.
    /// - Parameters:
    /// - dftA: The first input buffer of frequency domain data.
    /// - dftB: The second input buffer of frequency domain data.
    /// - dftAB: The output buffer of frequency domain data.
    /// - scaling: The scaling factor to apply to the result.
    public func convolve(dftA: borrowing Buffer<ScalarType>, dftB: borrowing Buffer<ScalarType>, dftAB: borrowing Buffer<ScalarType>, scaling: ScalarType) {
        checkConvolveBufferCounts(a: dftA, b: dftB, ab: dftAB)
        ScalarType.pffftZconvolveNoAccu(ptr, dftA.baseAddress, dftB.baseAddress, dftAB.baseAddress, scaling)
    }

    /// Perform a convolution of two complex signals in the frequency domain.
    ///
    /// Multiplies frequency domain components of `dftA` and `dftB` and accumulates the result in `dftAB`.
    /// The operation performed is `dftAB += (dftA * dftB) * scaling`.
    /// - Parameters:
    /// - dftA: The first input buffer of frequency domain data.
    /// - dftB: The second input buffer of frequency domain data.
    /// - dftAB: The output buffer of frequency domain data.
    /// - scaling: The scaling factor to apply to the result.
    public func convolveAccumulate(dftA: borrowing Buffer<ScalarType>, dftB: borrowing Buffer<ScalarType>, dftAB: borrowing Buffer<ScalarType>, scaling: ScalarType) {
        checkConvolveBufferCounts(a: dftA, b: dftB, ab: dftAB)
        ScalarType.pffftZconvolveAccumulate(ptr, dftA.baseAddress, dftB.baseAddress, dftAB.baseAddress, scaling)
    }

    /// Returns whether the given size is valid for the given type.
    ///
    /// The PFFFT library requires `n` to be factorizable to `minFftSize` with factors of 2, 3, 5.
    /// - Parameters:
    /// - n: The size to check.
    /// - Returns: Whether the size is valid.
    public static func isValidSize(_ n: Int) -> Bool {
        T.pffftIsValidSize(n, .real)
    }

    /// Returns the nearest valid size for the given type.
    /// - Parameters:
    /// - n: The size to check.
    /// - higher: Whether to return the next higher size if `n` is invalid.
    /// - Returns: The nearest valid size.
    public static func nearestValidSize(_ n: Int, higher: Bool) -> Int {
        T.pffftNearestValidSize(n, .real, higher)
    }

    /// The minimum FFT size for this type of setup.
    public static var minFftSize: Int {
        T.pffftMinFftSize(.real)
    }

    public static var simdArch: String {
        ScalarType.pffftSimdArch()
    }
}
