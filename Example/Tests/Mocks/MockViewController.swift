//
//  MockViewController.swift
//  AHContainerViewController_Example
//
//  Created by Alex Hmelevski on 2017-07-12.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class MockViewController: UIViewController {
    var willAppearCalledCount = 0
    var didAppearCalledCount = 0
    var willDisappearCalledCount = 0
    var didDisappearCalledCount = 0
    var id: String = "MOCK"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppearCalledCount += 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didAppearCalledCount += 1
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDisappearCalledCount += 1
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didDisappearCalledCount += 1
    }
}
