//
//  Array.swift
//  Lime
//
//  Created by Andre Pham on 1/8/2023.
//

import Foundation

extension Array {
    
    @discardableResult
    mutating func removeUntil(capacity: Int, takeFromEnd: Bool = true) -> Int {
        guard self.count > capacity else {
            return 0
        }
        let elementsToRemove = self.count - capacity
        guard elementsToRemove > 0 else {
            return 0
        }
        if takeFromEnd {
            self.removeLast(elementsToRemove)
        } else {
            self.removeFirst(elementsToRemove)
        }
        return elementsToRemove
    }
    
}

extension Array where Element: Hashable {
    
    func filterDuplicates() -> [Element] {
        var uniqueElements = Set<Element>()
        return filter { uniqueElements.insert($0).inserted }
    }
    
    func mostCommonElement() -> Element? {
        let counts = reduce(into: [:]) { counts, element in
            counts[element, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
}

extension Array where Element == Double {
    
    /// Find the closest element in this array **given this array is sorted**.
    /// - Parameters:
    ///   - target: The value to compare to find the closest to it
    /// - Returns: The value in the array closest to `target`
    func closest(to target: Double) -> Double? {
        guard !self.isEmpty else { return nil } // If the array is empty, return nil

        var left = 0
        var right = self.count - 1

        while left < right {
            let mid = left + (right - left) / 2

            if self[mid] == target {
                return self[mid]
            } else if self[mid] < target {
                left = mid + 1
            } else {
                right = mid
            }
        }

        // After the loop, left == right. Compute the closest number between self[left - 1], self[left] and self[left + 1]
        let prev = (left - 1 >= 0) ? self[left - 1] : self[left]
        let next = (left + 1 < self.count) ? self[left + 1] : self[left]

        if abs(prev - target) <= abs(self[left] - target) {
            return prev
        } else if abs(self[left] - target) <= abs(next - target) {
            return self[left]
        } else {
            return next
        }
    }
    
}

