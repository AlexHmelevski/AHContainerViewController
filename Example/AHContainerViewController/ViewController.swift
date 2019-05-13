//
//  ViewController.swift
//  AHContainerViewController
//
//  Created by AlexHmelevskiAG on 07/12/2017.
//  Copyright (c) 2017 AlexHmelevskiAG. All rights reserved.
//

import UIKit
import AHContainer

class ViewController: UIViewController {
    let container = ALViewControllerContainer(initialVC: UIViewController())
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(container.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

