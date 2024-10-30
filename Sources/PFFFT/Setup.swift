internal import PFFFTLib

public class Setup {
    let ptr: OpaquePointer
    let n: Int

    init<T: FFTElement>(n: Int, type: T.Type) throws {
        ptr = try type.pffftSetup(n, .real)
        self.n = n
    }

    deinit {
        pffft_destroy_setup(ptr)
    }
}
