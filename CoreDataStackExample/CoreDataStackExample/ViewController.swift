//
//  ViewController.swift
//  CoreDataStack
//
//  Created by Mukesh on 13/12/18.
//  Copyright © 2018 BooEat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repository = Repository<Entity>()
        
        repository.create { (user) in
            user.id = Int32.random(in: 0..<100)
            user.name = "Test \(user.id)"
        }
        
        let result = try? repository.fetch()
        print(result?.compactMap{ $0.name } ?? "")
    }
}

