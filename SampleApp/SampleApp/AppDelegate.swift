//
//  AppDelegate.swift
//  CoreDataManager
//
//  Created by Avi Shevin on 23/10/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import UIKit
import CoreDataStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let coreDataStack: CoreDataStack?

    override init() {
        coreDataStack = try? CoreDataStack(modelName: "SampleApp", storeType: NSSQLiteStoreType)

        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

