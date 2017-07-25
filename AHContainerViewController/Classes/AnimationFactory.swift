//
//  AnimationFactory.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-12.
//

import Foundation

protocol TransitionProviderFactory {
    func provider(for type: ContainerPresentationType,
                  dimmingViewType dType: DimmingViewType) -> DefaultProvider
}

struct DimmingPresentationInfo {
    let view: UIView
    let animationBlock: () -> Void
}

final class DimmingAppearTransitioner: IControllerDimmingTransitioner {
    func transitionBlock(for view: UIView) -> () -> Void {
        view.alpha = 0.0
        return {
            view.alpha = 1.0
        }
    }
}

public struct DefaultProvider: TransitionProvider {
    public let animationProvider: AnimationProvider
    public let alongsideAnimation: AnimationBlock?
    public var dimmingViewModel: DimmingViewModel?
    public var dimmingTapHandler: (()->())?
}


public final class DefaultAnimationProviderFactory: TransitionProviderFactory {
    
    var dimmingViewModelFactory: DimmingViewFactory = ALModalPresentationControllerDimmingViewFactory()
    
    public init() { }
    public func provider(for type: ContainerPresentationType,
                  dimmingViewType dType: DimmingViewType) -> DefaultProvider {
        return DefaultProvider(animationProvider: transitioner(for: type),
                               alongsideAnimation: nil,
                               dimmingViewModel: dimmingViewModelFactory.view(for: dType),
                               dimmingTapHandler: nil)
    }
    
    func transitioner(for type: ContainerPresentationType) -> AnimationProvider {
        switch type {
            case .crossDissolve: return CrossDissolveTransitioner()
            case let .slideUp(proportion): return SlideUpTransitioner(size: proportion)
            case .noAnimation: return NoAnimationTransitioner()
            case .slideDown: return SlideDownTransitioner()
            case let .slideRight(proportion) : return SlideRightTransitioner(size: proportion)
            case let .slideLeft(proportion) : return SlideLeftTransitioner(size: proportion)
            case let .popoverSlideUp(proportion):  return PopoverSlideUpTransitioner(size: proportion)
        }
    }
    
    func dimmingViewModel(for type: DimmingViewType) -> DimmingViewModel? {
        return dimmingViewModelFactory.view(for:type)
    }
}
