//
//  Foo+CoreDataProperties.swift
//  CoreDataManager
//
//  Created by Avi Shevin on 23/10/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//
//

import Foundation
import CoreData


extension Foo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Foo> {
        return NSFetchRequest<Foo>(entityName: "Foo")
    }

    @NSManaged public var name: String?
    @NSManaged public var count: Int16
    @NSManaged public var barred: Bool

}
