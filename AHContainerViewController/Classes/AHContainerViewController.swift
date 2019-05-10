//
//  AHContainerViewController.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-12.
//

import Foundation
import ALEither

public struct SizeProportion {
    let width: Double
    let height: Double
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    public static var equal: SizeProportion {
        return SizeProportion(width: 1, height: 1)
    }
}

public enum ContainerPresentationType {
    case crossDissolve(size: SizeProportion)
    case slideUp(size: SizeProportion)
    case slideRight(size: SizeProportion)
    case slideLeft(size: SizeProportion)
    case slideDown
    case popoverSlideUp(size: SizeProportion)
    case noAnimation
}
public typealias AnimationBlock = ()->()

public protocol AnimationTransitionProvider {
    var animationProvider: AnimationProvider { get }
    var alongsideAnimation: AnimationBlock? { get }
}

public protocol DimmingViewProvider {
    var dimmingViewModel: DimmingViewModel? { get }
    var dimmingTapHandler: (()->())? { get }
}

public protocol TransitionProvider: AnimationTransitionProvider,DimmingViewProvider {
    
    
}

open class ALViewControllerContainer: UIViewController,VCContainer {
    private var currentVC: UIViewController
    private var vcStack = [UIViewController]()
    //private var dimmingModel :DimminViewModel?
    private var dimmingModels = [Int: DimmingViewModel]()
    
    public init(initialVC: UIViewController) {
        currentVC = initialVC
        super.init(nibName: nil, bundle: nil)
        addChild(initialVC)
        add(vc: initialVC)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        callFunction(for: currentVC.view, function: { currentVC.beginAppearanceTransition(true, animated: animated) })
        super.viewWillAppear(animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        callFunction(for: currentVC.view, function: { currentVC.endAppearanceTransition() })
        super.viewDidAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        callFunction(for: currentVC.view, function: { currentVC.beginAppearanceTransition(false, animated: animated) })
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        callFunction(for: currentVC.view, function: { currentVC.endAppearanceTransition() })
        super.viewWillDisappear(animated)
        
    }
    
    func callFunction(for view: UIView, function: () -> Void ) {
        if !self.view.subviews.contains(view) {
            function()
        }
    }
    
    open override var childForStatusBarStyle: UIViewController? { return currentVC }
    
    open override var childForStatusBarHidden: UIViewController? { return currentVC }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return currentVC.supportedInterfaceOrientations }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //    MARK: VCContainer - Implementation
    open func show(_ vc: UIViewController,
              using provider: TransitionProvider,
              completion: ((Bool) -> Void)?) {
        change(toVC: vc, with: provider, completion: completion)
    }
    

    open func push(controller vc: UIViewController,
              with provider: TransitionProvider,
              completion: ((Bool) -> Void)?) {
        if !vcStack.contains(currentVC) {
            vcStack.append(currentVC)
        }
        
        let anim = provider.animationProvider.transitionBlock(for: context(currentVC)(vc)(.appear))
        
        addToStack(vc: vc)
        addDimmingView(for: vc, from: provider)
        let oldvc = currentVC
        doAnimation(for: vc, from: currentVC, with: {
            anim()
            provider.alongsideAnimation?()
            provider.dimmingViewModel?.animation(1.0)()
        }, completion: { (done) in
            self.removeOldFromStackIfNeed(oldvc: oldvc, using: vc)
            completion?(done)
        })
        
    }
    
    
    @discardableResult
    open func pop(using provider: AnimationTransitionProvider,
                  completion: ((Bool) -> Void)?) -> UIViewController? {
        // @TODO: Shouldn't we call completion with false in this case?
        guard !vcStack.isEmpty else {
            debugPrint("WARNING \(self): Tryin to pop a controller with empty stack ")
            return nil
        }
        
        guard let toVC = vcStack.enumerated()
                                .first(where: { $0.offset == self.vcStack.count - 2 })
                                .map({ $0.element }) else {
            debugPrint("WARNING \(self): Tryin to pop the last controller")
            return nil
        }
        
        return pop(to: toVC, using: provider, completion: completion).first

    }
    
    open func pop(to vc: UIViewController,
                  using provider: AnimationTransitionProvider,
                  completion: ((Bool) -> Void)?) -> [UIViewController] {
        
        var popedVC = (vc » getIndex).map(sliceVCStack) ?? []
        guard popedVC.count > 1 else { return [] }
        
        let toVC = popedVC.removeFirst()
        
        let anim = popedVC.map({($0,provider)})
                          .map(createAnimationBlock)
        
        
        
        popedVC.last.do { (fromVC) in
            let vcHash = fromVC.hash
            vc.willMove(toParent: nil)
            self.addToVCIntoStackIfNeed(toVC: toVC, using: fromVC)
            self.startStackRoutine(for: toVC, from: fromVC)
            self.doAnimation(for: toVC, from: fromVC, with: {
                self.dimmingModels[vcHash]?.animation(0.0)()
                anim.forEach({ $0() })
                provider.alongsideAnimation?()
            }, completion: { (done) in
                self.remove(vc: fromVC)
                self.endStackRoutine(for: toVC, from: fromVC)
                self.dimmingModels[vcHash]?.view.removeFromSuperview()
                self.dimmingModels.removeValue(forKey: vcHash)
                self.currentVC = toVC
                completion?(done)
            })
        }
        
        return popedVC
    }
    
    //MARK: Private Methods
    
    private func removeOldFromStackIfNeed(oldvc: UIViewController, using newVC: UIViewController) {
        if oldvc.view.frame.size.height <= newVC.view.frame.height && oldvc.view.frame.size.width <= newVC.view.frame.width {
            oldvc.view.removeFromSuperview()
        }
    }
    
    private func addToVCIntoStackIfNeed(toVC: UIViewController, using fromVC: UIViewController) {
        if toVC.view.frame.size.height <= fromVC.view.frame.height && toVC.view.frame.size.width <= fromVC.view.frame.width {
            view.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
    }
    
    
    private func addDimmingView(for vc: UIViewController, from provider: DimmingViewProvider)  {
        provider.dimmingViewModel.do { (dimming) in
            
            let gesture = ALTapGestureRecognizer(action: {
                provider.dimmingTapHandler?()
            })
            dimming.view.addGestureRecognizer(gesture)
            self.dimmingModels[vc.hash] = dimming
            self.view.insertSubview(dimming.view, belowSubview: vc.view)
            dimming.view.frame = self.view.bounds
        }
    }
    
    private var context: (UIViewController) -> (UIViewController) -> (PresentationType)-> AnimationContext {
        return { (fromVC) in
            return { (toVC) in
                return { (pres) in
                    return AnimationContext(fromVC: fromVC, toVC: toVC, transitionVC: self, presentation: pres)
                }
            }
        }
    }
    private func doAnimation(for vc: UIViewController,
                             from fromVC: UIViewController,
                             with animation: @escaping ()->(),
                             completion: ((Bool) -> Void)?) {
        startStackRoutine(for: vc, from: fromVC)
        
        UIView.animate(withDuration: 0.5, animations: animation) { (done) in
            self.endStackRoutine(for: vc, from: fromVC)
            self.currentVC = vc
            completion?(done)
        }
    }
    
    private func startStackRoutine(for toVC: UIViewController, from fromVC: UIViewController) {
        toVC.beginAppearanceTransition(true, animated: true)
        fromVC.beginAppearanceTransition(false, animated: true)
    }
    
    private func endStackRoutine(for toVC: UIViewController, from fromVC: UIViewController) {
        toVC.endAppearanceTransition()
        fromVC.endAppearanceTransition()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    private func createAnimationBlock(for vc: UIViewController, using animationProvider: AnimationTransitionProvider) -> () -> Void {
        let fakeView = UIViewController()
        return animationProvider.animationProvider.transitionBlock(for: context(currentVC)(fakeView)(.dismiss))
    }
    
    private func getIndex(of vc: UIViewController) -> Int? {
        return vcStack.firstIndex(of: vc) ?? -1
    }
    
    private func sliceVCStack(to index: Int?) -> [UIViewController] {
        return index.take(if: {$0 >= 0})
                    .flatMap({ Array(self.vcStack[$0..<vcStack.count]) })
                    ?? []
    }
    
    
    
    private func change(toVC vc: UIViewController,
                        with provider: TransitionProvider,
                        completion: ((Bool) -> Void)?) {
        
        let anim = provider.animationProvider.transitionBlock(for: context(currentVC)(vc)(.appear))
        
        currentVC.willMove(toParent: nil)
        addChild(vc)
        currentVC.dismiss(animated: false, completion: nil)
        
        self.transition(from: self.currentVC, to: vc, duration: 0.5, options: [], animations: {
            anim()
            provider.alongsideAnimation?()
        }) { (done) in
            
            self.add(vc: vc)
            self.remove(vc: self.currentVC)
            
            self.currentVC = vc
            self.setNeedsStatusBarAppearanceUpdate()
            self.purgeStack()
            completion?(done)
        }
    }
    
    private func purgeStack() {
        self.vcStack.forEach({(vc) in
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        })
        self.vcStack.removeAll()
    }
    
    /// Simple routine for adding a child VC
    ///
    /// - Parameter vc: vc
    private func add(vc: UIViewController) {
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
    }
    
    /// Simple routing for removing a child VC
    /// Also removes from the stack if needed
    ///
    /// - Parameter vc: vc
    private func remove(vc: UIViewController) {
        vcStack.firstIndex(of: vc).do { (idx) in
            self.vcStack = self.vcStack.enumerated()
                .filter({ $0.offset != idx })
                .map({$0.element})
        }
        
        vc.removeFromParent()
        vc.view.removeFromSuperview()
    }
    
    /// Adds vc as a child controller and adds it to the stack
    ///
    /// - Parameter vc: vc
    private func addToStack(vc: UIViewController) {
        if !vcStack.contains(vc) {
            addChild(vc)
            vcStack.append(vc)
            add(vc: vc)
        }
    }
    
}
