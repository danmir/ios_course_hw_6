//
//  ColorPickerPresentationManager.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 12.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

class ColorPickerPresentationManager: NSObject {
    var disableCompactHeight = false
}

extension ColorPickerPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = ColorPickerPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.delegate = self
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ColorPickerPresentationAnimator(isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ColorPickerPresentationAnimator(isPresentation: false)
    }
}

extension ColorPickerPresentationManager: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
            return .overFullScreen
        } else {
            return .none
        }
    }
}
