internal import PFFFTLib

extension pffft_transform_t {
    @inline(__always)
    init(_ type: FFTType) {
        switch type {
        case .real: self = PFFFT_REAL
        case .complex: self = PFFFT_COMPLEX
        }
    }
}

extension pffft_direction_t {
    @inline(__always)
    init(_ sign: FFTSign) {
        switch sign {
        case .forward: self = PFFFT_FORWARD
        case .backward: self = PFFFT_BACKWARD
        }
    }
}

