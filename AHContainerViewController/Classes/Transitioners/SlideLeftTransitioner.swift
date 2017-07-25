//
//  SlideLeftTransitioner.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-25.
//

import Foundation


final class SlideLeftTransitioner: AnimationProvider {
    
    private let wMultiplier: CGFloat
    private let hMultiplier: CGFloat
    init(size: SizeProportion) {
        wMultiplier = CGFloat(size.width)
        hMultiplier = CGFloat(size.height)
    }
    
    func transitionBlock(for context: AnimationContext) -> () -> Void {
        
        let vcSize = context.transitionVC.view.frame.size
        let width = vcSize.width * wMultiplier
        let height = vcSize.height * hMultiplier
        let center = context.transitionVC.view.center
        let appearFrame = CGRect(x: 0, y: 0, width: width,height: height)
        
        switch context.presentation {
        case .appear:
            context.toVC.view.frame = appearFrame
            context.toVC.view.center = CGPoint(x: center.x + vcSize.width, y: center.y)
        case .dismiss: break
        }
        
        
        let animation = {
            switch context.presentation {
            case .appear:
                context.toVC.view.frame.origin = CGPoint(x: vcSize.width - width, y: 0)
            case .dismiss:
                context.fromVC.view.center = CGPoint(x: center.x - vcSize.width, y: center.y)
            }
        }
        
        return animation
    }
}

