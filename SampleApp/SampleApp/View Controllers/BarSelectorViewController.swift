//
//  BarSelectorViewController.swift
//  CoreDataManager
//
//  Created by Avi Shevin on 26/11/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import UIKit
import CoreData
import CoreDataStack

protocol BarSelectorDelegate: class {
    func selectedBar(_ bar: Bar)
}

class BarSelectorViewController: UIViewController {
    public weak var delegate: BarSelectorDelegate?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        self.tableView.add(fetchedResultsSection: {
            let frSection = FetchedResultsTableSection(table: self.tableView,
                                                       frc: createBarsFrc(),
                                                       configureBlock: { [weak self] (cell, indexPath) in
                                                        guard let barCell = cell as? BarCell else {
                                                            return
                                                        }

                                                        let bar = self?.tableView.objectForTable(at: indexPath) as? Bar

                                                        barCell.barName.text = bar?.name
                                                        barCell.fooName.text = bar?.foo?.name
            })

            return frSection
        }())

        tableView.reloadData()
    }

    func createBarsFrc() -> NSFetchedResultsController<NSManagedObject>? {
        guard let cdm = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack else {
            return nil
        }

        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        request.predicate = NSPredicate(format: "%K == nil", "foo")
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

extension BarSelectorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.fetchedResultsSection(for: section)?.objectCount ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.fetchedResultsSectionCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        cell = tableView.dequeueReusableCell(withIdentifier: "barCell", for: indexPath)

        let frSection = tableView.fetchedResultsSection(for: indexPath.section)

        frSection?.configureBlock(cell, indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedBar(tableView.objectForTable(at: indexPath) as! Bar)

        dismiss(animated: true, completion: nil)
    }
}

