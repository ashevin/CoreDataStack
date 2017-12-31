//
//  FooSelectorViewController.swift
//  CoreDataManager
//
//  Created by Avi Shevin on 26/11/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import UIKit
import CoreData
import CoreDataStack

protocol FooSelectorDelegate: class {
    func selectedFoo(_ foo: Foo)
}

class FooSelectorViewController: UIViewController {
    public weak var delegate: FooSelectorDelegate?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        self.tableView.add(fetchedResultsSection: {
            let frSection = FetchedResultsTableSection(table: self.tableView,
                                                       frc: createFoosFrc(),
                                                       configureBlock: { [weak self] (cell, indexPath) in
                                                        guard let fooCell = cell as? FooCell else {
                                                            return
                                                        }

                                                        let foo = self?.tableView.objectForTable(at: indexPath) as? Foo

                                                        fooCell.fooName.text = foo?.name
                                                        fooCell.stars.text = String(describing: foo?.stars ?? 0)
            })

            return frSection
        }())

        tableView.reloadData()
    }

    func createFoosFrc() -> NSFetchedResultsController<NSManagedObject>? {
        guard let cdm = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack else {
            return nil
        }

        let request: NSFetchRequest<Foo> = Foo.fetchRequest()
        request.predicate = NSPredicate(format: "%K == nil", "bar")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: cdm.viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)

        try? frc.performFetch()

        return frc as? NSFetchedResultsController<NSManagedObject>
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension FooSelectorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.fetchedResultsSection(for: section)?.objectCount ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.fetchedResultsSectionCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        cell = tableView.dequeueReusableCell(withIdentifier: "fooCell", for: indexPath)

        let frSection = tableView.fetchedResultsSection(for: indexPath.section)

        frSection?.configureBlock?(cell, indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedFoo(tableView.objectForTable(at: indexPath) as! Foo)

        dismiss(animated: true, completion: nil)
    }
}

