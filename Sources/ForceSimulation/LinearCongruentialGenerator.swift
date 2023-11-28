// TODO: https://forums.swift.org/t/deterministic-randomness-in-swift/20835/5

/// A random number generator that generates deterministic random numbers.
public protocol DeterministicRandomGenerator<Scalar> {
    associatedtype Scalar where Scalar: FloatingPoint & ExpressibleByFloatLiteral
    @inlinable static func next() -> Scalar
    @inlinable mutating func next() -> Scalar
    @inlinable init()
}

/// A random number generator that generates deterministic random numbers for `Double`.
public struct DoubleLinearCongruentialGenerator: DeterministicRandomGenerator {
    @usableFromInline internal static let a: Double = 1_664_525
    @usableFromInline internal static let c: Double = 1_013_904_223
    @usableFromInline internal static let m: Double = 4_294_967_296
    @usableFromInline internal static var _s: Double = 1
    @usableFromInline internal var s: Double = 1

    @inlinable public mutating func next() -> Double {
        s = (Self.a * s + Self.c).truncatingRemainder(dividingBy: Self.m)
        return s / Self.m
    }

    @inlinable public static func next() -> Double {
        Self._s = (Self.a * Self._s + Self.c).truncatingRemainder(dividingBy: Self.m)
        return Self._s / Self.m
    }

    @inlinable public init() {}
}

/// A random number generator that generates deterministic random numbers for `Float`.
public struct FloatLinearCongruentialGenerator: DeterministicRandomGenerator {
    @usableFromInline internal static let a: Float = 75
    @usableFromInline internal static let c: Float = 74
    @usableFromInline internal static let m: Float = 65537
    @usableFromInline internal static var _s: Float = 1
    @usableFromInline internal var s: Float = 1

    @inlinable public mutating func next() -> Float {
        s = (Self.a * s + Self.c).truncatingRemainder(dividingBy: Self.m)
        return s / Self.m
    }

    @inlinable public static func next() -> Float {
        Self._s = (Self.a * Self._s + Self.c).truncatingRemainder(dividingBy: Self.m)
        return Self._s / Self.m
    }

    @inlinable public init() {}
}


/// A floating point type that can be generated with a deterministic random number generator ``DeterministicRandomGenerator``.
public protocol HasDeterministicRandomGenerator: FloatingPoint & ExpressibleByFloatLiteral {
    associatedtype Generator: DeterministicRandomGenerator where Generator.Scalar == Self
}

extension Double: HasDeterministicRandomGenerator {
    public typealias Generator = DoubleLinearCongruentialGenerator
}

extension Float: HasDeterministicRandomGenerator {
    public typealias Generator = FloatLinearCongruentialGenerator
}

extension HasDeterministicRandomGenerator {
    @inlinable
    public func jiggled() -> Self {
        if self == .zero || self == .nan {
            return (Generator.next() - 0.5) * 1e-5
        }
        return self
    }

    @inlinable
    public func jiggled(by: UnsafeMutablePointer<Generator>) -> Self {
        if self == .zero || self == .nan {
            return (by.pointee.next() - 0.5) * 1e-5
        }
        return self
    }
}
