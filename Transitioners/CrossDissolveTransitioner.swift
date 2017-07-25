//
//  CrossDissolveTransitioner.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-12.
//

import Foundation

// Does cross dissolve between controllers
final class CrossDissolveTransitioner: AnimationProvider {
    
    func transitionBlock(for context: AnimationContext) -> () -> Void {
        context.toVC.view.frame = context.transitionVC.view.frame
        context.toVC.view.alpha = 0
        
        let animation = {
            context.toVC.view.alpha = 1.0
            context.fromVC.view.alpha = 0
        }
        
        return animation
    }
}
