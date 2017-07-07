//
//  PHTransitionManager.swift
//
//  Created by Rajinder Paul on 12/7/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHTransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    fileprivate var transitionFromView = true

    // MARK: UIViewControllerAnimatedTransitioning protocol methods

    // animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        // set up from 2D transforms that we'll use in the animation
        let offScreenRight = CGAffineTransform(translationX: -container.frame.width, y: 0)
        let offScreenLeft = CGAffineTransform(translationX: container.frame.width, y: 0)
        
        // prepare the toView for the animation
        toView.transform = self.transitionFromView ? offScreenRight : offScreenLeft
        
        // add the both views to our view controller
        container.addSubview(toView)
        container.addSubview(fromView)
        
        // get the duration of the animation
        let duration = self.transitionDuration(using: transitionContext)
        
        // perform the animation!
        UIView.animate(withDuration: duration, animations: {
            
            fromView.transform = self.transitionFromView ? offScreenLeft : offScreenRight
            toView.transform = CGAffineTransform.identity
            
            }, completion: { finished in
                // tell our transitionContext object that we've finished animating
                transitionContext.completeTransition(true)
        })
    }
    
    // return how many seconds the transiton animation will take
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // remmeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.transitionFromView = true
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionFromView = false
        return self
    }
}
