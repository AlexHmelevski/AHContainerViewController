//
//  ALTapGestureRecognizer.swift
//  AHContainerViewController
//
//  Created by Alex Hmelevski on 2017-07-12.
//

import Foundation

class ALTapGestureRecognizer: UITapGestureRecognizer {
    private var action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action:nil)
        self.addTarget(self, action: #selector(callAction))
    }
    
    @objc private func callAction() {
        action()
    }
}
