//
//  ITransitioner.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-12.
//

import Foundation


public enum PresentationType {
    case appear
    case dismiss
}

public struct AnimationContext {
    let fromVC: UIViewController
    let toVC: UIViewController
    let transitionVC: UIViewController
    let presentation: PresentationType
    init (fromVC: UIViewController,
          toVC: UIViewController,
          transitionVC: UIViewController,
          presentation: PresentationType) {
        self.fromVC = fromVC
        self.toVC = toVC
        self.transitionVC = transitionVC
        self.presentation = presentation
    }
    
    func newContext(with presentation: PresentationType) -> AnimationContext {
                return AnimationContext(fromVC: fromVC, toVC: toVC, transitionVC: transitionVC, presentation: presentation)
    }
}

// Classes that conform the protocol should provide the animation block with changes
// All preparation for animtion is also the responsibility of the classes
public protocol AnimationProvider {
    
    // Classes that conform the protocol should provide the animation block with changes
    // All preparation for animtion is also the responsibility of the classes
    /// - Parameters:
    ///   - vc: UIViewController
    ///   - toVC: UIViewController
    /// - Returns: animation block with changes
    func transitionBlock(for context: AnimationContext) -> () -> Void
}

// Classes that conform the protocol should provide the animation block with changes
// All preparation for animtion is also the responsibility of the classes
protocol IControllerDimmingTransitioner {
    
    // Classes that conform the protocol should provide the animation block with changes
    // All preparation for animtion is also the responsibility of the classes
    /// - Parameters:
    ///   - vc: UIViewController
    ///   - toVC: UIViewController
    /// - Returns: animation block with changes
    func transitionBlock(for view: UIView) -> () -> Void
}

