//
//  NewOldBarViewController.swift
//  CoreDataManager
//
//  Created by Avi Shevin on 26/11/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import UIKit
import CoreData
import CoreDataStack

class NewOldBarViewController: UIViewController {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var fooName: UIButton!
    @IBOutlet weak var navItem: UINavigationItem!

    var oldBar: Bar?
    
    private var selectedFoo: NSManagedObjectID?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let bar = oldBar {
            nameField.text = bar.name

            if let foo = bar.foo {
                fooName.setTitle(foo.name, for: .normal)
            }

            navItem.title = "Old Bar"
        } else {
            saveButton.isEnabled = false
        }
    }

    @IBAction func saveTapped(_ sender: Any) {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let cds = appDelegate.coreDataStack else {
                return
        }

        let barName = nameField.text

        cds.perform({ context, shouldSave in
            let bar: Bar
            if let oldBar = self.oldBar, let loadedBar = try? context.load(item: oldBar) {
                bar = loadedBar
            }
            else {
                bar = Bar(context: context)
            }

            bar.name = barName

            if let foo = self.selectedFoo {
                bar.foo = try? context.load(objectID: foo)
            }
        }) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fooTapped(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "fooselector") as? FooSelectorViewController {
            vc.delegate = self

            present(vc, animated: true, completion: nil)
        }
    }
}

extension NewOldBarViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.placeholder = textField.text

        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = !(textField.text?.isEmpty ?? true)
    }
}

extension NewOldBarViewController: FooSelectorDelegate {
    func selectedFoo(_ foo: Foo) {
        self.selectedFoo = foo.objectID

        fooName.setTitle(foo.name, for: .normal)
    }
}
