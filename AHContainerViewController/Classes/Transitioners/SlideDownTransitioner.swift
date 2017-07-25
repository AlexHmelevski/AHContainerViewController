//
//  SlideDownTransitioner.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-12.
//

import Foundation

final class SlideDownTransitioner: AnimationProvider {
    /// - Parameters:
    ///   - vc: UIViewController
    ///   - toVC: UIViewController
    /// - Returns: animation block with changes
        
    func transitionBlock(for context: AnimationContext) -> () -> Void {
        let vcSize = context.transitionVC.view.frame.size
        
            
        switch context.presentation {
        case .appear:
            context.toVC.view.frame = CGRect(x: context.toVC.view.frame.origin.x,
                                             y: -vcSize.height,
                                             width: vcSize.width,
                                             height: vcSize.height)
        case .dismiss: break
        }
        
        
        let animation = {
            switch context.presentation {
            case .appear:
                context.toVC.view.frame = context.transitionVC.view.bounds
            case .dismiss:
                context.fromVC.view.frame = CGRect(x: context.fromVC.view.frame.origin.x,
                                                   y: context.transitionVC.view.frame.height,
                                                   width: context.fromVC.view.frame.width,
                                                   height: context.fromVC.view.frame.height)
            }
        }
        
        return animation
    }
    
}
