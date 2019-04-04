//
//  SlideUpTransitioner.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-12.
//

import Foundation


// Creates a slide from bottom to up transition

final class SlideUpTransitioner: AnimationProvider {
    
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
        let appearFrame = CGRect(x: 0,
                                 y: vcSize.height,
                                 width: width,
                                 height: height)
        
        switch context.presentation {
        case .appear:
            context.toVC.view.frame = appearFrame
        case .dismiss: break
        }
        
        let animation = {
            switch context.presentation {
            case .appear:
                context.toVC.view.frame.origin = CGPoint(x: context.transitionVC.view.frame.origin.x,
                                                         y: vcSize.height - height)
            case .dismiss:
                context.fromVC.view.center = CGPoint(x: center.x, y: center.y - height)
            }
        }
        
        return animation
    }
}
