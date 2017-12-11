//
//  EntityWatcher.swift
//  CoreDataStack
//
//  Created by Avi Shevin on 07/12/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import Foundation
import CoreData

public class EntityWatcher<T : NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    public typealias Entity = T
    public typealias EventHandler = (Change?) -> Void

    public enum Event {
        case willChange
        case change
        case didChange
    }

    public struct Change {
        public let entity: Entity
        public let type: NSFetchedResultsChangeType
    }

    private let frc: NSFetchedResultsController<Entity>

    private var willChangeBlock: EventHandler?
    private var changeBlock: EventHandler?
    private var didChangeBlock: EventHandler?

    convenience public init(predicate: NSPredicate,
                            sortKey: String,
                            ascending: Bool = true,
                            context: NSManagedObjectContext) throws {
        try self.init(predicate: predicate,
                      sortDescriptors: [NSSortDescriptor(key: sortKey, ascending: ascending)],
                      context: context)
    }

    public init(predicate: NSPredicate,
                sortDescriptors: [NSSortDescriptor],
                context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<Entity>(entityName: Entity.entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        frc = NSFetchedResultsController<Entity>(fetchRequest: request,
                                                 managedObjectContext: context,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)

        super.init()

        frc.delegate = self

        try frc.performFetch()
    }

    public func on(_ event: Event, handler: @escaping EventHandler) {
        switch event {
        case .willChange: willChangeBlock = handler
        case .change: changeBlock = handler
        case .didChange: didChangeBlock = handler
        }
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        willChangeBlock?(nil)
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        guard let object = anObject as? Entity else {
            fatalError("How did that happen?!")
        }

        changeBlock?(Message(entity: object, type: type))
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChangeBlock?(nil)
    }
}
