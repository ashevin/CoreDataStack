//
//  CoreDataManager.swift
//  CoreDataManager
//
//  Created by Avi Shevin on 23/10/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import Foundation
import CoreData

public enum CoreDataStackError: Error {
    case missingModelName
}

public typealias CoreDataManagerUpdateBlock = (NSManagedObjectContext, inout Bool) -> ()
public typealias CoreDataManagerQueryBlock = (NSManagedObjectContext) -> ()

public final class CoreDataStack {
    public let viewContext: ReadOnlyMOC

    private let coordinator: NSPersistentStoreCoordinator

    private let queue = OperationQueue()
    private let queryQueue = OperationQueue()
    private var token: AnyObject? = nil
    private var isShuttingDown = false

    convenience public init(modelName: String) throws {
        try self.init(modelName: modelName, storeType: NSSQLiteStoreType)
    }

    public init(modelName: String, storeType: String) throws {
        guard let model = CoreDataStack.model(for: modelName) else {
           throw CoreDataStackError.missingModelName
        }

        queue.maxConcurrentOperationCount = 1
        queue.name = "cdm.queue"

        queryQueue.maxConcurrentOperationCount = 1
        queryQueue.name = "cdm.queue.query"

        let options: [String: Any] = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
            NSSQLitePragmasOption: ["journal_mode": "WAL"]
        ]

        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(ofType: storeType,
                                           configurationName: nil,
                                           at: CoreDataStack.storageURL(for: modelName),
                                           options: storeType == NSSQLiteStoreType
                                            ? options
                                            : nil)

        viewContext = ReadOnlyMOC(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = coordinator
        viewContext.mergePolicy = NSMergePolicy.rollback

        token = NotificationCenter
            .default
            .addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave,
                         object: nil,
                         queue: nil) { (notification) in
                            guard let context = notification.object as? NSManagedObjectContext else {
                                return
                            }

                            guard context != self.viewContext &&
                                context.persistentStoreCoordinator == self.viewContext.persistentStoreCoordinator else {
                                    return
                            }

                            self.viewContext.performAndWait {
                                if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
                                    updatedObjects.forEach {
                                        self.viewContext
                                            .object(with: $0.objectID)
                                            .willAccessValue(forKey: nil)
                                    }
                                }

                                self.viewContext.mergeChanges(fromContextDidSave: notification)
                            }
        }
    }

    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }

    private static func storageURL(for name: String) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0]
            .appendingPathComponent(name)
            .appendingPathExtension("sqlite")
    }

    private static func model(for name: String) -> NSManagedObjectModel? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "momd") else {
            return nil
        }

        return NSManagedObjectModel(contentsOf: url)
    }
}

extension CoreDataStack {
    public func shutdown() {
        guard Thread.current == Thread.main else {
            fatalError("Must call from main thread.")
        }

        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }

        token = nil

        isShuttingDown = true

        queue.waitUntilAllOperationsAreFinished()
    }

    public func save(_ context: NSManagedObjectContext) throws {
        guard context != viewContext else {
            fatalError("Saving the viewContext is illegal.")
        }

        if context.hasChanges {
            try context.save()
        }
    }

    public func perform(_ block: @escaping CoreDataManagerUpdateBlock, completion: (() -> ())? = nil) {
        guard isShuttingDown == false else {
            return
        }

        let context = viewContext.backgroundCloneRW
        var shouldSave = true

        queue.addOperation {
            context.performAndWait {
                block(context, &shouldSave)
            }

            if shouldSave {
                try? context.save()
            }

            context.killed = true

            completion?()
        }
    }

    public func query(_ block: @escaping CoreDataManagerQueryBlock) {
        guard isShuttingDown == false else {
            return
        }

        let context = viewContext.backgroundCloneRO

        queryQueue.addOperation {
            context.performAndWait {
                block(context)

                context.killed = true
            }
        }
    }

    public func viewQuery(_ block: CoreDataManagerQueryBlock) {
        guard isShuttingDown == false else {
            return
        }

        viewContext.performAndWait {
            block(viewContext)
        }

        if viewContext.hasChanges {
            fatalError("viewContext should not be modified.")
        }
    }
}

//MARK: - Public - NSManagedObject -

public extension NSManagedObject {
    public static var entityName: String {
        return self.entity().name ?? String(describing: type(of: self))
    }
}

//MARK: - Public - NSManagedObjectContext -

public extension NSManagedObjectContext {
    public func itemsMatching<T : NSManagedObject>(conditions: [String: Any],
                                                   for entity: T.Type) throws -> [T] {
        let request = NSFetchRequest<NSManagedObject>(entityName: T.entityName)
        request.predicate = NSPredicate.predicate(for: conditions)

        return try self.fetch(request) as! [T]
    }

    public func load<T : NSManagedObject>(items: [T]) throws -> [T] {
        let request = NSFetchRequest<NSManagedObject>(entityName: T.entityName)
        request.predicate = NSPredicate(format: "SELF IN %@", argumentArray: [items])

        return try self.fetch(request) as! [T]
    }

    public func load<T : NSManagedObject>(item: T) throws -> T {
        return try existingObject(with: item.objectID) as! T
    }

    public func load<T : NSManagedObject>(objectID: NSManagedObjectID) throws -> T {
        return try existingObject(with: objectID) as! T
    }
}

//MARK: - Private

private extension NSManagedObjectContext {
    var backgroundCloneRW: KillableMOC {
        let context = KillableMOC(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy.overwrite

        return context
    }

    var backgroundCloneRO: ReadOnlyMOC {
        let context = ReadOnlyMOC(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy.rollback

        return context
    }
}

//MARK: - Semi-private classes

public class KillableMOC: NSManagedObjectContext {
    fileprivate var killed = false

    override public func performAndWait(_ block: () -> Void) {
        guard killed == false else {
            fatalError("Dead context reused.")
        }

        super.performAndWait(block)
    }

    override public func perform(_ block: @escaping () -> Void) {
        guard killed == false else {
            fatalError("Dead context reused.")
        }

        super.perform(block)
    }

    override public func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
        guard killed == false else {
            fatalError("Dead context reused.")
        }

        return try super.fetch(request)
    }
}

public class ReadOnlyMOC: KillableMOC {
    override public func save() throws {
        fatalError("Can't save a read-only context")
    }
}

