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
    public typealias EventHandler = (Message?) -> Void

    public enum Event {
        case willChange
        case change
        case didChange
    }

    public struct Message {
        public let entity: Entity
        public let type: NSFetchedResultsChangeType
    }

    private let frc: NSFetchedResultsController<Entity>

    private var willChangeBlock: EventHandler?
    private var changeBlock: EventHandler?
    private var didChangeBlock: EventHandler?

    private var didFetch = false

    public init(predicate: NSPredicate, sortKey: String, context: NSManagedObjectContext) {
        let request = NSFetchRequest<Entity>(entityName: Entity.entityName)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: true)]

        frc = NSFetchedResultsController<Entity>(fetchRequest: request,
                                                 managedObjectContext: context,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)

        super.init()

        frc.delegate = self
    }

    public func on(_ event: Event, handler: @escaping EventHandler) {
        switch event {
        case .willChange: willChangeBlock = handler
        case .change: changeBlock = handler
        case .didChange: didChangeBlock = handler
        }

        if didFetch == false {
            try? frc.performFetch()

            didFetch = true
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
