import Foundation

public class SetupCache: @unchecked Sendable {
    struct CacheKey: Hashable {
        let n: Int
        let type: ObjectIdentifier

        init(n: Int, type: any FFTElement.Type) {
            self.n = n
            self.type = ObjectIdentifier(type)
        }
    }

    var cache: [CacheKey: Setup?] = [:]
    let queue = DispatchQueue(label: String(describing: SetupCache.self), attributes: .concurrent)

    public init() {}

    public func get<T: FFTElement>(n: Int, type: T.Type) throws -> Setup {
        var setup: Setup??
        queue.sync {
            setup = cache[CacheKey(n: n, type: type)]
        }
        if setup == nil {
            queue.sync(flags: .barrier) {
                let key = CacheKey(n: n, type: type)
                setup = cache[key]
                if setup == nil {
                    let entry = try? Setup(n: n, type: type)
                    cache[key] = entry
                    setup = entry
                }
            }
        }
        guard let s = setup! else { throw FFTError.invalidSize }
        return s
    }

    public func clear() {
        queue.sync(flags: .barrier) {
            cache.removeAll()
        }
    }

    public static let shared = SetupCache()
}
