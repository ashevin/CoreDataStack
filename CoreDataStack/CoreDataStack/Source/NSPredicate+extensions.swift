//
//  NSPredicate+extensions.swift
//  CoreDataManager
//
//  Created by Avi Shevin on 23/10/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import Foundation

public extension NSPredicate {
    public func or(_ conditions: [String: Any]) -> NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: [self, NSPredicate(with: conditions)])
    }

    public func and(_ conditions: [String: Any]) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [self, NSPredicate(with: conditions)])
    }

    public func or(_ predicate: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: [self, predicate])
    }

    public func and(_ predicate: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [self, predicate])
    }

    public static func && (left: NSPredicate, right: NSPredicate) -> NSPredicate {
        return left.and(right)
    }

    public static func || (left: NSPredicate, right: NSPredicate) -> NSPredicate {
        return left.or(right)
    }

    public static func && (left: NSPredicate, right: [String: Any]) -> NSPredicate {
        return left.and(right)
    }

    public static func || (left: NSPredicate, right: [String: Any]) -> NSPredicate {
        return left.or(right)
    }
}

public extension NSPredicate {
    public convenience init(with conditions: [String: Any]) {
        var predicates = [NSPredicate]()

        for (key, value) in conditions {
            predicates.append(NSPredicate.predicate(for: key, value: value))
        }

        var predicateString = predicates[0].predicateFormat
        for i in 1..<predicates.count {
            predicateString += " AND " + predicates[i].predicateFormat
        }

        self.init(format: predicateString)
    }

    static func predicate(for key: String, value: Any) -> NSPredicate {
        let predicate: NSPredicate
        if value is CountableClosedRange<Int> {
            let range = value as! CountableClosedRange<Int>

            predicate = closedRangePredicate(key: key, value: range)
        }
        else if value is CountableRange<Int> {
            let range = value as! CountableRange<Int>

            predicate = openRangePredicate(key: key, value: range)
        }
        else if value is Set<AnyHashable> || value is Array<AnyHashable> {
            predicate = inPredicate(key: key, value: value)
        }
        else {
            predicate = equalPredicate(key: key, value: value)
        }

        return predicate
    }

    static func equalPredicate(key: String, value: Any) -> NSPredicate {
        if key.lowercased() == "self" {
            return NSPredicate(format: "SELF == %@", argumentArray: [value])
        }

        return NSPredicate(format: "%K == %@", argumentArray: [key, value])
    }

    static func inPredicate(key: String, value: Any) -> NSPredicate {
        if key.lowercased() == "self" {
            return NSPredicate(format: "SELF IN %@", argumentArray: [value])
        }

        return NSPredicate(format: "%K IN %@", argumentArray: [key, value])
    }

    static func closedRangePredicate(key: String, value: CountableClosedRange<Int>) -> NSPredicate {
        let lower = value.lowerBound
        let upper = value.upperBound

        if key.lowercased() == "self" {
            return NSPredicate(format: "SELF >= %@ && SELF <= %@",
                               argumentArray: [lower, upper])
        }

        return NSPredicate(format: "%K >= %@ && %K <= %@",
                           argumentArray: [key, lower, key, upper])
    }

    static func openRangePredicate(key: String, value: CountableRange<Int>) -> NSPredicate {
        let lower = value.lowerBound
        let upper = value.upperBound

        if key.lowercased() == "self" {
            return NSPredicate(format: "SELF >= %@ && SELF < %@",
                               argumentArray: [lower, upper])
        }

        return NSPredicate(format: "%K >= %@ && %K < %@",
                           argumentArray: [key, lower, key, upper])
    }
}
