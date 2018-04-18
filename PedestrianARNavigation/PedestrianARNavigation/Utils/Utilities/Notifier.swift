//
//  Notifier.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 03/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation

public class WeakObject: Hashable {

    public weak var obj: AnyObject?

    public var hashValue: Int {
        guard let obj = obj else { return 0 }
        return unsafeBitCast(obj, to: Int.self)
    }

    public init(_ obj: AnyObject) {
        self.obj = obj
    }

    public static func ==(lhs: WeakObject, rhs: WeakObject) -> Bool {
        guard lhs.obj != nil && rhs.obj != nil else { return false }
        return lhs.hashValue == rhs.hashValue
    }

}

public class WeakObjectCollection<T> {

    // MARK: Public methods

    public init(){}

    public func array() -> [T] {
        filter()
        return collection.map { x in x.obj as! T}
    }

    public func insert(_ element: T) {
        filter()
        remove(element)
        collection.append(WeakObject(element as AnyObject))
    }

    public func remove(_ element: T) {
        filter()
        collection = collection.filter { return !(($0.obj! as AnyObject) === (element as AnyObject)) }
    }

    public func count() -> Int {
        filter()
        return collection.count
    }

    public func clear() {
        collection = []
    }

    public func contains(_ member: T) -> Bool {
        for obj in collection {
            if (obj.obj as AnyObject) === (member as AnyObject) {
                return true
            }
        }

        return false
    }

    // MARK: Private properties

    fileprivate var collection = [WeakObject]()
}

fileprivate extension WeakObjectCollection {

    // MARK: Private methods

    func filter() {
        collection = collection.filter { return $0.obj != nil }
    }

}

public class Notifier<T> {

    //MARK: Public

    public typealias Listener = T

    public init() {}

    public func notify(_ call: ((Listener) -> Void)) {
        for l in listeners.array() {
            call(l)
        }
    }

    public func addListener(_ listener: Listener) {
        if !listeners.contains(listener) {
            listeners.insert(listener)
        }
    }

    public func removeListener(_ listener: Listener) {
        listeners.remove(listener)
    }

    public var hasListeners: Bool { return listenersCount != 0 }
    public var listenersCount: Int { return listeners.count() }

    // MARK: Private

    fileprivate var listeners = WeakObjectCollection<Listener>()
}
