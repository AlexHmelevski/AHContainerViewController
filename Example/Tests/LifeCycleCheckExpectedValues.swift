//
//  LifeCycleCheckExpectedValues.swift
//  AHContainerViewController_Example
//
//  Created by Alex Hmelevski on 2017-07-17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

struct LifeCycleCheckExpectedValues {
    let mockVC: MockViewController
    let viewWillApear: Int
    let viewDidAppear: Int
    let viewWillDisappear: Int
    let viewDidDisappear: Int
    
    static func fullCycle(for mock: MockViewController) -> LifeCycleCheckExpectedValues {
        return LifeCycleCheckExpectedValues(mockVC: mock,
                                            viewWillApear: 1,
                                            viewDidAppear: 1,
                                            viewWillDisappear: 1,
                                            viewDidDisappear: 1)
    }
    
    static func emptyCycle(for mock: MockViewController) -> LifeCycleCheckExpectedValues {
        return LifeCycleCheckExpectedValues(mockVC: mock,
                                            viewWillApear: 0,
                                            viewDidAppear: 0,
                                            viewWillDisappear: 0,
                                            viewDidDisappear: 0)
    }
    
    static func appearOnlyCycle(for mock: MockViewController) -> LifeCycleCheckExpectedValues {
        return LifeCycleCheckExpectedValues(mockVC: mock,
                                            viewWillApear: 1,
                                            viewDidAppear: 1,
                                            viewWillDisappear: 0,
                                            viewDidDisappear: 0)
    }
    
    static func disappearOnlyCycle(for mock: MockViewController) -> LifeCycleCheckExpectedValues {
        return LifeCycleCheckExpectedValues(mockVC: mock,
                                            viewWillApear: 0,
                                            viewDidAppear: 0,
                                            viewWillDisappear: 1,
                                            viewDidDisappear: 1)
    }
}
