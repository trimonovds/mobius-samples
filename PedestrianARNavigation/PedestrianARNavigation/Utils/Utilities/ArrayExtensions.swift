//
//  ArrayExtensions.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 22/03/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation

extension Array {

    public func skip(_ n: Int) -> Array {
        let result: [Element] = []
        return n > count ? result : Array(self[Int(n)..<count])
    }

    public func all(condition: (Element) -> Bool) -> Bool {
        return self.filter(condition).count == self.count
    }

    public func any(condition: (Element) -> Bool) -> Bool {
        return self.filter(condition).count > 0
    }
}

public extension Swift.Collection {

    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Sequence {

    /// Returns single element that sutisfies predicate
    /// or nil if no elements found or more than one element found
    /// - Parameter condition: predicate
    /// - Returns: the only element that sutisfies predicate or nil otherwise
    public func single(condition: (Element) -> Bool) -> Element? {
        let sutisfiableElements = self.filter(condition)
        if sutisfiableElements.count > 1 {
            return nil
        } else {
            return sutisfiableElements.first
        }
    }
}
