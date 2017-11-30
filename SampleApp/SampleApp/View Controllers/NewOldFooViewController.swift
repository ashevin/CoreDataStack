//
//  NewOldFooViewController.swift
//  CoreDataManager
//
//  Created by Avi Shevin on 26/11/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import UIKit
import CoreData
import CoreDataStack
import AviControls

class NewOldFooViewController: UIViewController {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var barName: UIButton!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var navItem: UINavigationItem!

    var oldFoo: Foo?

    private var selectedBar: NSManagedObjectID?

    override func viewDidLoad() {
        super.viewDidLoad()

        ratingView.image = #imageLiteral(resourceName: "star_template")

        if let foo = oldFoo {
            nameField.text = foo.name
            ratingView.rating = UInt(foo.stars)

            if let bar = foo.bar {
                barName.setTitle(bar.name, for: .normal)
            }

            navItem.title = "Old Foo"
        } else {
            ratingView.rating = 3

            saveButton.isEnabled = false
        }
    }

    @IBAction func saveTapped(_ sender: Any) {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let cds = appDelegate.coreDataStack else {
                return
        }

        let fooName = nameField.text
        let stars = Int16(ratingView.rating)

        cds.perform({ context, shouldSave in
            let foo: Foo
            if let oldFoo = self.oldFoo, let loadedFoo = try? context.load(item: oldFoo) {
                foo = loadedFoo
            }
            else {
                foo = Foo(context: context)
            }

            foo.name = fooName
            foo.stars = stars

            if let bar = self.selectedBar {
                foo.bar = try? context.load(objectID: bar)
            }
        }) {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func barTapped(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "barselector") as? BarSelectorViewController {
            vc.delegate = self

            present(vc, animated: true, completion: nil)
        }
    }
}

extension NewOldFooViewController: UITextFieldDelegate {
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

extension NewOldFooViewController: BarSelectorDelegate {
    func selectedBar(_ bar: Bar) {
        self.selectedBar = bar.objectID

        barName.setTitle(bar.name, for: .normal)
    }
}
