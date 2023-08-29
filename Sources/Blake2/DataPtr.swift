//
//  DataPtr.swift
//  
//
//  Created by Yehor Popovych on 29/08/2023.
//

import Foundation

public protocol PtrRepresentable {
    associatedtype Ptr
    func withPtr<R>(cb: (Ptr) throws -> R) rethrows -> R
}

public protocol MutPtrRepresentable: PtrRepresentable {
    associatedtype MutPtr
    mutating func withMutPtr<R>(cb: (MutPtr) throws -> R) rethrows -> R
}

public protocol DataPtrRepresentable: PtrRepresentable where Ptr == UnsafeRawBufferPointer {}

public protocol DataMutPtrRepresentable: MutPtrRepresentable, DataPtrRepresentable
    where MutPtr == UnsafeMutableRawBufferPointer {}

extension Data: DataMutPtrRepresentable {
    public typealias Ptr = UnsafeRawBufferPointer
    public typealias MutPtr = UnsafeMutableRawBufferPointer
    
    @inlinable public func withPtr<R>(
        cb: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R {
        try withUnsafeBytes(cb)
    }
    
    @inlinable public mutating func withMutPtr<R>(
        cb: (UnsafeMutableRawBufferPointer) throws -> R
    ) rethrows -> R {
        try withUnsafeMutableBytes(cb)
    }
}

extension Array: PtrRepresentable, DataPtrRepresentable where Element == UInt8 {
    public typealias Ptr = UnsafeRawBufferPointer
    
    @inlinable public func withPtr<R>(
        cb: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R {
        try withUnsafeBytes(cb)
    }
}

extension Array: MutPtrRepresentable, DataMutPtrRepresentable where Element == UInt8 {
    public typealias MutPtr = UnsafeMutableRawBufferPointer
    
    @inlinable public mutating func withMutPtr<R>(
        cb: (UnsafeMutableRawBufferPointer) throws -> R
    ) rethrows -> R {
        try withUnsafeMutableBytes(cb)
    }
}

extension String: DataPtrRepresentable {
    public typealias Ptr = UnsafeRawBufferPointer
    
    @inlinable public func withPtr<R>(
        cb: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R {
        var str = self
        return try str.withUTF8 { try $0.withUnsafeBytes(cb) }
    }
}

extension Optional: PtrRepresentable where Wrapped: PtrRepresentable {
    public typealias Ptr = Optional<Wrapped.Ptr>
    
    @inlinable public func withPtr<R>(
        cb: (Optional<Wrapped.Ptr>) throws -> R
    ) rethrows -> R {
        switch self {
        case .none: return try cb(nil)
        case .some(let val): return try val.withPtr(cb: cb)
        }
    }
}

public extension PtrRepresentable {
    @inlinable func join<T, R>(
        _ t: T, cb: (Ptr, T.Ptr) throws -> R
    ) rethrows -> R where T: PtrRepresentable {
        try withPtr { p1 in try t.withPtr { try cb(p1, $0) } }
    }
    
    @inlinable func join2<T1, T2, R>(
        _ t1: T1, _ t2: T2, cb: (Ptr, T1.Ptr, T2.Ptr) throws -> R
    ) rethrows -> R where T1: PtrRepresentable, T2: PtrRepresentable {
        try join(t1) { p1, p2 in try t2.withPtr { try cb(p1, p2, $0) } }
    }
    
    @inlinable func join3<T1, T2, T3, R>(
        _ t1: T1, _ t2: T2, _ t3: T3,
        cb: (Ptr, T1.Ptr, T2.Ptr, T3.Ptr) throws -> R
    ) rethrows -> R where
        T1: PtrRepresentable, T2: PtrRepresentable, T3: PtrRepresentable
    {
        try join2(t1, t2) { p1, p2, p3 in try t3.withPtr { try cb(p1, p2, p3, $0) } }
    }
}

public extension MutPtrRepresentable {
    @inlinable mutating func mutJoin<T, R>(
        _ t: T, cb: (MutPtr, T.Ptr) throws -> R
    ) rethrows -> R where T: PtrRepresentable {
        try withMutPtr { p1 in try t.withPtr { try cb(p1, $0) } }
    }
    
    @inlinable mutating func mutJoin2<T1, T2, R>(
        _ t1: T1, _ t2: T2, cb: (MutPtr, T1.Ptr, T2.Ptr) throws -> R
    ) rethrows -> R where T1: PtrRepresentable, T2: PtrRepresentable {
        try mutJoin(t1) { p1, p2 in try t2.withPtr { try cb(p1, p2, $0) } }
    }
    
    @inlinable mutating func mutJoin3<T1, T2, T3, R>(
        _ t1: T1, _ t2: T2, _ t3: T3,
        cb: (MutPtr, T1.Ptr, T2.Ptr, T3.Ptr) throws -> R
    ) rethrows -> R where
        T1: PtrRepresentable, T2: PtrRepresentable, T3: PtrRepresentable
    {
        try mutJoin2(t1, t2) { p1, p2, p3 in try t3.withPtr { try cb(p1, p2, p3, $0) } }
    }
}
