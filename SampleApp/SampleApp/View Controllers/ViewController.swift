//
//  ViewController.swift
//  CoreDataManager
//
//  Created by Avi Shevin on 23/10/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import UIKit
import CoreData
import CoreDataStack

class ViewController: UIViewController {
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

                                                        fooCell.fooName?.text = foo?.name
                                                        fooCell.stars.text = String(describing: foo?.stars ?? 0)
            })

            return frSection
        }())

        self.tableView.add(fetchedResultsSection: {
            let frSection = FetchedResultsTableSection(table: self.tableView,
                                                       frc: createBestestFoosFrc(),
                                                       configureBlock: { [weak self] (cell, indexPath) in
                                                        guard let fooCell = cell as? FooCell else {
                                                            return
                                                        }

                                                        let foo = self?.tableView.objectForTable(at: indexPath) as? Foo

                                                        fooCell.fooName?.text = foo?.name
                                                        fooCell.stars.text = String(describing: foo?.stars ?? 0)
            })

            return frSection
        }())

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

    func createFoosFrc() -> NSFetchedResultsController<NSManagedObject>? {
        guard let cds = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack else {
            return nil
        }

        let request: NSFetchRequest<Foo> = Foo.fetchRequest()
        request.predicate = NSPredicate(format: "%K <= %d", "stars", 4)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: cds.viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)

        return frc as? NSFetchedResultsController<NSManagedObject>
    }

    func createBestestFoosFrc() -> NSFetchedResultsController<NSManagedObject>? {
        guard let cds = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack else {
            return nil
        }

        let request: NSFetchRequest<Foo> = Foo.fetchRequest()
        request.predicate = NSPredicate(format: "%K > %d", "stars", 4)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: cds.viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)

        return frc as? NSFetchedResultsController<NSManagedObject>
    }

    func createBarsFrc() -> NSFetchedResultsController<NSManagedObject>? {
        guard let cdm = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack else {
            return nil
        }

        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: cdm.viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)

        try? frc.performFetch()

        return frc as? NSFetchedResultsController<NSManagedObject>
    }

    @objc public func addItem(_ button: UIButton) {
        if button.tag == 0 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "newfoo") {
                present(vc, animated: true, completion: nil)
            }
        }
        else if button.tag == 2 {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "newbar") {
                present(vc, animated: true, completion: nil)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.fetchedResultsSection(for: section)?.objectCount ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.fetchedResultsSectionCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "fooCell", for: indexPath)
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "fooCell", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "barCell", for: indexPath)
        }

        let frSection = tableView.fetchedResultsSection(for: indexPath.section)

        frSection?.configureBlock?(cell, indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .lightGray

        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = section == 0
            ? "Foos"
            : section == 1 ? "Bestest Foos" : "Bars"
        l.sizeToFit()

        v.addSubview(l)

        if section == 0 || section == 2 {
            let b = UIButton(type: UIButtonType.contactAdd)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.tag = section

            b.addTarget(self, action: #selector(addItem(_:)), for: .touchUpInside)

            v.addSubview(b)

            v.addConstraints([
                NSLayoutConstraint(item: b, attribute: .right, relatedBy: .equal, toItem: v, attribute: .rightMargin, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: l, attribute: .centerY, relatedBy: .equal, toItem: b, attribute: .centerY, multiplier: 1, constant: 0),
                ])
        }

        v.addConstraints([
            NSLayoutConstraint(item: l, attribute: .left, relatedBy: .equal, toItem: v, attribute: .leftMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: l, attribute: .centerY, relatedBy: .equal, toItem: v, attribute: .centerY, multiplier: 1, constant: 0),
            ])

        return v
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let foo = tableView.objectForTable(at: indexPath) as? Foo {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "newfoo") as? NewOldFooViewController {
                vc.oldFoo = foo

                present(vc, animated: true, completion: nil)
            }
        }
        else if let bar = tableView.objectForTable(at: indexPath) as? Bar {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "newbar") as? NewOldBarViewController {
                vc.oldBar = bar

                present(vc, animated: true, completion: nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "Delete", handler: { _, indexPath in
                guard
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                    let cds = appDelegate.coreDataStack else {
                        return
                }

                guard let foo = tableView.objectForTable(at: indexPath) else {
                    return
                }

                cds.perform({ context, shouldSave in
                    try? context.delete(context.load(item: foo))
                })
            })
        ]
    }
}

