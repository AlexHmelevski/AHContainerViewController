//
//  NoAnimationTransitioner.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-12.
//

import Foundation
final class NoAnimationTransitioner: AnimationProvider {
    /// - Parameters:
    ///   - vc: UIViewController
    ///   - toVC: UIViewController
    /// - Returns: animation block with changes
        
    func transitionBlock(for context: AnimationContext) -> () -> Void {
        context.toVC.view.frame = context.transitionVC.view.bounds
        
        let animation = {
        }
        
        return animation
    }
    
}
