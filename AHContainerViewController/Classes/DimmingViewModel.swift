//
//  DimmingViewModel.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-12.
//

import Foundation

public enum DimmingViewType {
    case defaultView
    case defaultBlur(UIBlurEffect.Style)
    case noDimming
    
}

public struct DimmingViewModel {
    let view: UIView
    let animation: (CGFloat) -> (() -> Void)
}

protocol DimmingViewFactory {
    func view(for type: DimmingViewType) -> DimmingViewModel?
}
public class ALModalPresentationControllerDimmingViewFactory: DimmingViewFactory {
    func view(for type: DimmingViewType) -> DimmingViewModel? {
        switch type {
            case let .defaultBlur(style): return defaultBlur(with: style)
            case .defaultView: return defaultDimming
        default: return nil
        }
    }
    
    private var defaultDimming: DimmingViewModel {
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        dimmingView.alpha = 0
        
        let animationBlock: (CGFloat) -> ( () -> Void ) = { (alpha) in
            return { dimmingView.alpha = alpha }
        }
        
        return DimmingViewModel(view: dimmingView, animation: animationBlock)
    }
    
    private func defaultBlur(with style: UIBlurEffect.Style) -> DimmingViewModel {
        let view = UIVisualEffectView()
        view.effect = nil
        
        let animationBlock: (CGFloat) -> (() -> Void) = { (alpha) in
            return { view.effect = alpha <= 0 ? nil : UIBlurEffect(style: style) }
        }
        
        return  DimmingViewModel(view: view, animation: animationBlock)
    }
    
    private var defaultPropertyAnimator: UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator()
        
        return animator
    }
    
}
