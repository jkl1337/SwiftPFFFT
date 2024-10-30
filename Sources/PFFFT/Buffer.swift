import ComplexModule
import RealModule

let bufferAlignment = 32

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

    @inlinable public func map<U>(_ transform: (T) throws -> U) rethrows -> [U] {
        try buffer.map(transform)
    }

    @inlinable public func mapInPlace(_ body: (Int, inout T) throws -> Void) rethrows {
        for i in 0 ..< buffer.count {
            try body(i, &buffer[i])
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
    @inlinable func mapInPlaceSwapLast(_ body: (Int, inout T) throws -> Void) rethrows {
        for i in 0 ..< buffer.count {
            try body(i, &buffer[i])
        }
        buffer[0].imaginary = buffer[buffer.count - 1].real
    }
}
