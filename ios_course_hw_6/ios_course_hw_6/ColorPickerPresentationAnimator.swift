//
//  ColorPickerAnimator.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 12.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

class ColorPickerPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresentation: Bool
    
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key = isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
        let controller = transitionContext.viewController(forKey: key)!
        
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        
        let finalAlpha = isPresentation ? 1 : 0
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        dismissedFrame.origin.y = presentedFrame.origin.y + 20
        
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        
        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        controller.view.alpha = CGFloat(1 - finalAlpha)
        
        UIView.animate(withDuration: animationDuration, animations: {
            controller.view.frame = finalFrame
            controller.view.alpha = CGFloat(finalAlpha)
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}
