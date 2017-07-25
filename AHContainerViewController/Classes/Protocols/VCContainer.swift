//
//  VCContainer.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-12.
//

import Foundation

public protocol VCContainer: class {
    
    func show(_ vc: UIViewController,
              using provider: TransitionProvider,
              completion: ((Bool) -> Void)?)
    
    func push(controller vc: UIViewController,
              with provider: TransitionProvider,
              completion: ((Bool) -> Void)?) 
    
    
    
    func pop(using provider: AnimationTransitionProvider,
             completion: ((Bool) -> Void)?) -> UIViewController?
    
    func pop(to vc: UIViewController,using provider: AnimationTransitionProvider,
             completion: ((Bool) -> Void)?) -> [UIViewController]
}
