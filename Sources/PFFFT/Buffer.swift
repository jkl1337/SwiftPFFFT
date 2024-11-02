import ComplexModule
import RealModule

let bufferAlignment = 32

/// Thin wrapper around `UnsafeMutableBufferPointer` providing correct alignment.
/// PFFFT internally assumes all buffers passed are aligned to 16 or 32 bytes
/// depending on the platform. Thie type provides correctly aligned buffers
/// and provides some in place mutating methods.
@frozen
public struct Buffer<T>: ~Copyable {
    public let buffer: UnsafeMutableBufferPointer<T>
    var count: Int { buffer.count }
    var baseAddress: UnsafeMutablePointer<T> { buffer.baseAddress! }

    public init(capacity: Int) {
        buffer = UnsafeMutableRawBufferPointer.allocate(
            byteCount: MemoryLayout<T>.stride * capacity,
            alignment: bufferAlignment
        ).bindMemory(to: T.self)
    }

    deinit {
        buffer.deallocate()
    }

    @inlinable public func withUnsafeMutableBufferPointer<R>(_ body: (UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R {
        try body(buffer)
    }

    @inlinable public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R {
        try body(UnsafeBufferPointer(buffer))
    }

    @inlinable public func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        try body(UnsafeMutableRawBufferPointer(buffer))
    }

    /// Return an array with results of mapping given closure over buffer elements.
    /// - Parameter transform: A mapping closure. `transform` accepts an element of the buffer
    ///   as its parameter and returns a transformed value of any type.
    /// - Returns: An array containing the transformed elements of the buffer.
    @inlinable public func map<U>(_ transform: (T) throws -> U) rethrows -> [U] {
        try buffer.map(transform)
    }

    /// Calls the given closure on each element in the buffer for mutation in place.
    /// - Parameter body: A closure that accepts a zero-based enumeration index.
    ///   and must return a new value for the element at that index.
    ///   `body` may throw and the error will be propagated to the caller.
    @inlinable public func mapInPlace(_ body: (Int) throws -> T) rethrows {
        for i in 0 ..< buffer.count {
            try buffer[i] = body(i)
        }
    }
}

public protocol ComplexType {
    associatedtype RealType: Real
    var real: RealType { get set }
    var imaginary: RealType { get set }
}

extension Complex: ComplexType {}

public extension Buffer where T: ComplexType {
    /// Calls the given closure on each space in the buffer for mutation in place with
    /// Nyquist replacement at the end.
    ///
    /// When operating on Complex->Real transforms PFFFT internally uses a slightly more compact
    /// but less common encoding of the DC (0) and Nyquist (n/2) components. Since these two
    /// spectral components are always real, PFFFT places the DC (0) component
    /// in the real part of the 0th element as expected, but places the Nyquist `(n/2)` component
    /// in the imaginary part of the 0th element.
    /// This enumerator works like `mapInPlace` but at the end places the real part of the
    /// n/2 component into the imaginary part of the 0th element. In normal use it is expected
    /// that a spectral buffer of 1 extra element is created such that `count == (n/2 + 1)`.
    /// - Parameter body: A closure that accepts a zero-based enumeration index.
    ///   and must return a new value for the element at that index.
    ///   `body` may throw and the error will be propagated to the caller.
    @inlinable func mapInPlaceSwapLast(_ body: (Int) throws -> T) rethrows {
        for i in 0 ..< buffer.count {
            try buffer[i] = body(i)
        }
        buffer[0].imaginary = buffer[buffer.count - 1].real
    }
}
