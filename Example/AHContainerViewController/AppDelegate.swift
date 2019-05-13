//
//  AppDelegate.swift
//  AHContainerViewController
//
//  Created by AlexHmelevskiAG on 07/12/2017.
//  Copyright (c) 2017 AlexHmelevskiAG. All rights reserved.
//

import UIKit
import AHContainer
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let container = ALViewControllerContainer(initialVC: UIViewController())
    let defaultProviderFactory = DefaultAnimationProviderFactory()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.rootViewController = container
        window?.makeKeyAndVisible()
        
        let proportion = SizeProportion(width:1, height: 0.8)
        
        var slidUpPopover = defaultProviderFactory.provider(for: .slideRight(size: proportion),
                                                            dimmingViewType: .defaultBlur(.light))
        
        
        slidUpPopover.dimmingTapHandler = {[weak self] in
            guard let `self` = self else {return}
            self.container.pop(using: self.defaultProviderFactory.provider(for: .slideLeft(size: SizeProportion(width: 1, height: 1)),
                                                                           dimmingViewType: .noDimming),
                               completion: nil)
        }
        let newVC = UIViewController()
        newVC.view.backgroundColor = .red
        container.show(newVC, using: defaultProviderFactory.provider(for: .slideUp(size: SizeProportion.equal), dimmingViewType: .noDimming), completion: {(done) in
            let vc2 = UIViewController()
            vc2.view.backgroundColor = .yellow
            self.container.push(controller: vc2,
                                with: slidUpPopover,
                                completion: { (done) in
                                    
            })
            
        })
        return true
    }


}

