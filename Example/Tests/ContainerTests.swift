//
//  ContainerTests.swift
//  AHContainerViewController_Tests
//
//  Created by Alex Hmelevski on 2017-07-12.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import AHContainerViewController

extension XCTestCase {
    func fulfill(exp: [XCTestExpectation], in interval: DispatchTimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
            exp.forEach({ $0.fulfill() })
        }
    }
}


class ALViewControllerContainerTests: XCTestCase {
    var initial: MockViewController = MockViewController()
    var vc1: MockViewController = MockViewController()
    var vc2: MockViewController = MockViewController()
    var container: ALViewControllerContainer!
    var exp: XCTestExpectation!
    var defaultFactory = DefaultAnimationProviderFactory()
    var proportion: SizeProportion = SizeProportion(width: 1, height: 1)
    override func setUp() {
        super.setUp()
        exp = expectation(description: "UI testing")
        initial = MockViewController()
        initial.id = "initial"
        vc1 = MockViewController()
        vc1.id = "vc1"
        vc2 = MockViewController()
        vc2.id = "vc2"
        container = ALViewControllerContainer(initialVC: initial)
        container.beginAppearanceTransition(true, animated: false)
        container.endAppearanceTransition()
        
    }
    
    func test_intial_has_lifecycle_called() {
        fulfill(exp: [exp], in: .seconds(2))
        waitForExpectations(timeout: 10) { (error) in
           self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.appearOnlyCycle(for: self.initial))
        }
    }
    
    func test_show_change_support_lifecycle_calls() {
        fulfill(exp: [exp], in: .seconds(2))
        container.show(vc1, using: defaultFactory.provider(for: .slideDown, dimmingViewType: .noDimming)) { (done) in
             self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.fullCycle(for: self.initial))
             self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.appearOnlyCycle(for: self.vc1))
        }
       wait(for: [exp], timeout: 10)
        
    }
    
    
    
    func test_show_push_pop_to_change_support_lifecycle_calls() {
        fulfill(exp: [exp], in: .seconds(6))
        let provide = self.defaultFactory.provider(for: .slideUp(size: self.proportion), dimmingViewType: .noDimming)
         container.show(vc1, using: defaultFactory.provider(for: .slideDown, dimmingViewType: .defaultView)) { (done) in
            self.container.push(controller: self.vc2,
                                with: self.defaultFactory.provider(for: .slideDown, dimmingViewType: .noDimming),
                                completion: { (done) in
                                    self.container.pop(using: provide,
                                   completion: nil)
            })
        }
        
        waitForExpectations(timeout: 10) { (error) in
            self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.fullCycle(for: self.initial))
            
            self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues(mockVC: self.vc1,
                                                                         viewWillApear: 2,
                                                                         viewDidAppear: 2,
                                                                         viewWillDisappear: 1,
                                                                         viewDidDisappear: 1))
            
            self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.fullCycle(for: self.vc2))
            
        }
    }
    
    func test_push_change_support_lifecycle_calls() {
        fulfill(exp: [exp], in: .seconds(2))
        
        container.push(controller: vc1, with: defaultFactory.provider(for: .slideUp(size: proportion), dimmingViewType: .noDimming)) { (done) in
            self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.fullCycle(for: self.initial))
            self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.appearOnlyCycle(for: self.vc1))
        }
        
        wait(for: [exp], timeout: 10)
    }
    
    
    func test_pop_change_support_lifecycle_calls() {
        fulfill(exp: [exp], in: .seconds(4))
        
        container.show(vc1, using: defaultFactory.provider(for: .slideDown, dimmingViewType: .noDimming)) { (done) in
            
            self.container.pop(using: self.defaultFactory.provider(for: .slideUp(size: self.proportion), dimmingViewType: .defaultView),
                                                       completion: { (done) in
                                                        
                    self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues(mockVC: self.initial,
                                                                                 viewWillApear: 2,
                                                                                 viewDidAppear: 2,
                                                                                 viewWillDisappear: 1,
                                                                                 viewDidDisappear: 1))
                    self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.fullCycle(for: self.vc1))
                                                        
                }
            )
        }
        
        wait(for: [exp], timeout: 10)
        
    }
    
    
    
    func test_2push_change_support_lifecycle_calls() {
        fulfill(exp: [exp], in: .seconds(6))
        
        let initialExpected = LifeCycleCheckExpectedValues.fullCycle(for: initial)
        let vc1Expected = LifeCycleCheckExpectedValues.fullCycle(for: vc1)
        let vc2Expected = LifeCycleCheckExpectedValues.appearOnlyCycle(for: vc2)
        
        let provider = defaultFactory.provider(for: .slideUp(size: proportion), dimmingViewType: .noDimming)
        
        container.push(controller: vc1, with: provider) { (done) in
            self.container.push(controller: self.vc2,
                                with: provider,
                                completion: { (done) in
                                    
                                    self.checkLifyCycleCounts(with: initialExpected)
                                    self.checkLifyCycleCounts(with: vc1Expected)
                                    self.checkLifyCycleCounts(with: vc2Expected)
                                    
            })
        }
        
        wait(for: [exp], timeout: 10)
        
    }
    
    func test_push_removes_old_from_hierarchy() {
        fulfill(exp: [exp], in: .seconds(6))
        container.push(controller: vc1, with: defaultFactory.provider(for: .slideDown, dimmingViewType: .noDimming)) { (done) in
            XCTAssertEqual(self.container.view.subviews.count, 1)
            XCTAssertEqual(self.container.view.subviews.first, self.vc1.view)
        }
        
        wait(for: [exp], timeout: 10)
        
    }
    
    
    func test_pop_when_there_is_no_vc_in_stack() {
        fulfill(exp: [exp], in: .seconds(3))
        
        self.container.pop(using: defaultFactory.provider(for: .slideDown, dimmingViewType: .noDimming)) { (done) in
            XCTFail("Don't expect to be called when trying to pop from empty stack")
        }
        
        wait(for: [exp], timeout: 10)
        
        XCTAssertEqual(self.initial.willAppearCalledCount, 1) // one -  initial show up, second - pop
        XCTAssertEqual(self.initial.didAppearCalledCount, 1) // one -  initial show up, second - pop
        
        XCTAssertEqual(self.initial.willDisappearCalledCount, 0)
        XCTAssertEqual(self.initial.didDisappearCalledCount, 0)
        
        
        XCTAssertEqual(self.vc1.willAppearCalledCount, 0)
        XCTAssertEqual(self.vc1.didAppearCalledCount, 0)
        XCTAssertEqual(self.vc1.willDisappearCalledCount, 0)
        XCTAssertEqual(self.vc1.didDisappearCalledCount, 0)
        
        XCTAssertEqual(self.vc2.willAppearCalledCount, 0)
        XCTAssertEqual(self.vc2.didAppearCalledCount, 0)
        XCTAssertEqual(self.vc2.willDisappearCalledCount, 0)
        XCTAssertEqual(self.vc2.didDisappearCalledCount, 0)
    }
    
    func test_push_with_VC_smaller_than_presenter_shouldBe_balanced() {
        fulfill(exp: [exp], in: .seconds(2))
        self.container.push(controller: self.vc1,
                            with: self.defaultFactory.provider(for: .slideUp(size: SizeProportion(width: 0.4, height: 0.4)), dimmingViewType: .noDimming),
                            completion: { (done) in
                                self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.fullCycle(for: self.initial))
                                self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.appearOnlyCycle(for: self.vc1))
        })
        wait(for: [exp], timeout: 500)
    }
    
    func test_push_then_pop_with_VC_smaller_than_presenter_shouldBe_balanced() {
        let expextedInitial = LifeCycleCheckExpectedValues(mockVC: self.initial,
                                                           viewWillApear: 2,
                                                           viewDidAppear: 2,
                                                           viewWillDisappear: 1,
                                                           viewDidDisappear: 1)
        let provider = self.defaultFactory.provider(for: .slideUp(size: SizeProportion(width: 0.4, height: 0.4)), dimmingViewType: .noDimming)
        fulfill(exp: [exp], in: .seconds(2))
        self.container.push(controller: self.vc1,
                            with: provider,
                            completion: { (done) in
                                self.container.pop(using: provider, completion: { (done) in
                                    self.checkLifyCycleCounts(with: expextedInitial)
                                    self.checkLifyCycleCounts(with: LifeCycleCheckExpectedValues.fullCycle(for: self.vc1))
                                })
                                
        })
        wait(for: [exp], timeout: 10)
    }
    
    private func checkLifyCycleCounts(with expectedValues: LifeCycleCheckExpectedValues, on line: Int = #line, in function: String = #function) {
        XCTAssertEqual(expectedValues.viewWillApear, expectedValues.mockVC.willAppearCalledCount, "on the line \(line) in function \(function)")
        XCTAssertEqual(expectedValues.viewDidAppear, expectedValues.mockVC.didAppearCalledCount, "on the line \(line) in function \(function)")
        XCTAssertEqual(expectedValues.viewWillDisappear, expectedValues.mockVC.willDisappearCalledCount, "on the line \(line) in function \(function)")
        XCTAssertEqual(expectedValues.viewDidDisappear, expectedValues.mockVC.didDisappearCalledCount, "on the line \(line) in function \(function)")
    }
    
}
