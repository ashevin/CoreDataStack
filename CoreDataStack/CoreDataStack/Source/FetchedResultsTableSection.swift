//
//  FetchedResultsTableSection.swift
//  CoreDataManager
//
//  Created by Avi Shevin on 24/10/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import UIKit
import CoreData

public typealias CellConfigurationBlock = (UITableViewCell?, IndexPath) -> ()

public class FetchedResultsTableSection: NSObject, NSFetchedResultsControllerDelegate {
    weak var table: UITableView?
    let section: Int
    public let configureBlock: CellConfigurationBlock
    var frc: NSFetchedResultsController<NSManagedObject>? {
        didSet {
            frc?.delegate = self

            try? frc?.performFetch()
        }
    }

    public var objectCount: Int {
        return frc?.fetchedObjects?.count ?? 0
    }

    public init(table: UITableView,
                frc: NSFetchedResultsController<NSManagedObject>?,
                configureBlock: @escaping CellConfigurationBlock) {
        self.table = table
        self.section = table.fetchedResultsSectionCount
        self.frc = frc
        self.configureBlock = configureBlock

        super.init()
        
        frc?.delegate = self
        try? frc?.performFetch()
    }

    public func objectForTable(at indexPath: IndexPath) -> NSManagedObject? {
        guard let section = frc?.sections?[0],
            let objects = section.objects,
            indexPath.row < objects.count else {
                return nil
        }

        return objects[indexPath.row] as? NSManagedObject
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table?.beginUpdates()
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table?.endUpdates()
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        let ip = IndexPath(row: indexPath?.row ?? 0, section: section)
        let nip = IndexPath(row: newIndexPath?.row ?? 0, section: section)

        switch type {
        case .insert: table?.insertRows(at: [nip], with: .automatic)
        case .delete: table?.deleteRows(at: [ip], with: .automatic)
        case .update: configureBlock(table?.cellForRow(at: ip), ip)
        case .move:
            table?.moveRow(at: ip, to: nip)
        }
    }
}

private var sectionsKey = 0

public extension UITableView {
    public func add(fetchedResultsSection: FetchedResultsTableSection) {
        var sections: NSMutableDictionary? = associatedSections()

        if sections == nil {
            sections = NSMutableDictionary()
            objc_setAssociatedObject(self, &sectionsKey, sections, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        sections?[fetchedResultsSection.section] = fetchedResultsSection
    }

    public func removeFetchedResultsSection(for section: Int) {
        guard let sections = associatedSections() else {
            return
        }

        sections[section] = nil

        if sections.count == 0 {
            objc_setAssociatedObject(self, &sectionsKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func fetchedResultsSection(for section: Int) -> FetchedResultsTableSection? {
        guard let sections = associatedSections() else {
            return nil
        }

        guard let frSection = sections[section] as? FetchedResultsTableSection else {
            return nil
        }

        return frSection
    }

    public var fetchedResultsSectionCount: Int {
        guard let sections = associatedSections() else {
            return 0
        }

        return sections.count
    }

    public func objectForTable(at indexPath: IndexPath) -> NSManagedObject? {
        guard let object = fetchedResultsSection(for: indexPath.section)?
            .objectForTable(at: indexPath) else {
            return nil
        }

        return object
    }

    private func associatedSections() -> NSMutableDictionary? {
        return objc_getAssociatedObject(self, &sectionsKey) as? NSMutableDictionary
    }
}
