//
//  AnimateViewController.swift
//  animter
//
//  Created by Mac on 2020/6/30.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class AnimateViewController: UIViewController {
    
    var imageView : UIImageView!
    
    var BlurEffect : UIBlurEffect!
    
    var BlurEffectView :  UIVisualEffectView!
    
    var commentView : UIView!
    
    var commentTitleIn : UILabel!
        
    var commentTitleOut : UILabel!
    
    var animator : UIViewPropertyAnimator!
    
    var runningAnimators  = [UIViewPropertyAnimator]()
    
    var panGes : UIPanGestureRecognizer!
    
    var progressWhenInterrupted : CGFloat = 0
    
    var tapGes : UITapGestureRecognizer!
    
    enum animateState {
        case Extpended
        case Collapsed
    }
    
    var aniState : animateState = .Extpended
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView = UIImageView(frame: CGRect(origin: .zero, size: view.frame.size))
        imageView.image = UIImage(named: "2")
        view.addSubview(imageView)
        
        BlurEffect = UIBlurEffect(style: .light)
        BlurEffectView = UIVisualEffectView(effect: BlurEffect)
        BlurEffectView.frame = CGRect(origin: .zero, size: imageView.frame.size)
        BlurEffectView.alpha = 0
        imageView.addSubview(BlurEffectView)
        
        commentView = UIView(frame: CGRect(x: 0, y: view.frame.height - 80, width: view.frame.width, height: view.frame.height - 150))
        commentView.backgroundColor = .white
        view.addSubview(commentView)
        
        commentTitleIn = UILabel(frame: CGRect(x: view.frame.midX - 50, y: 5, width: 100, height: 40))
        commentTitleIn.text = "评论"
        commentTitleIn.textColor = .systemBlue
        commentTitleIn.textAlignment = .center
        commentView.addSubview(commentTitleIn)
        
        commentTitleOut = UILabel(frame: CGRect(x: view.frame.midX - 50, y: 5, width: 100, height: 40))
        commentTitleOut.text = "评论"
        commentTitleOut.textColor = .black
        commentTitleOut.font = .boldSystemFont(ofSize: 25)
        commentTitleOut.textAlignment = .center
        commentTitleOut.alpha = 0
        commentView.addSubview(commentTitleOut)
        
        panGes = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        commentView.addGestureRecognizer(panGes)
        
        tapGes = UITapGestureRecognizer(target: self, action: #selector(handleTap(recogizer:)))
        commentView.addGestureRecognizer(tapGes)
    }

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animateTransitionIfNeed(forState: aniState, duration: 0.5)
            
        case .changed:
            let translation = recognizer.translation(in: self.commentView)
            switch aniState {
            case .Extpended:
                updateInteractiveTransition(fractionComplete: progressWhenInterrupted - (translation.y / (self.commentView.frame.height - 80)))
            case .Collapsed:
                updateInteractiveTransition(fractionComplete: progressWhenInterrupted + (translation.y / (self.commentView.frame.height - 80)))
            }
            
        case .ended:
            let velocity = recognizer.velocity(in: self.commentView)
            if velocity.y > 0 {
                continueInteractiveTransition(extpend: false)
            }else {
                continueInteractiveTransition(extpend: true)
            }
        default:
            return
        }
    }
    
    @objc func handleTap(recogizer: UITapGestureRecognizer) {
        let isExpanded = aniState == animateState.Extpended
        let newState = isExpanded ? animateState.Collapsed : animateState.Extpended
        animateOrReverseRunningTransition(state: newState, duration: 0.5)
    }
        
        
    func animateTransitionIfNeed(forState state:animateState, duration:TimeInterval) {
        
        if runningAnimators.isEmpty {
            
                let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

                switch state {
                case .Extpended:
                    self.commentView.frame = self.commentView.frame.offsetBy(dx: 0, dy:  -self.commentView.frame.height + 80)
                    self.BlurEffectView.alpha = 1
                    self.commentTitleIn.alpha = 0
                    self.commentTitleOut.alpha = 1
                case .Collapsed:
                    self.commentView.frame = self.commentView.frame.offsetBy(dx: 0, dy: self.commentView.frame.height - 80)
                    self.BlurEffectView.alpha = 0
                    self.commentTitleIn.alpha = 1
                    self.commentTitleOut.alpha = 0
                }
            }
            
            frameAnimator.pauseAnimation()
            frameAnimator.addCompletion { (position) in
                debugPrint("动画", position.rawValue)
                if position == UIViewAnimatingPosition.end {
                    if let index = self.runningAnimators.firstIndex(of: frameAnimator) {
                        self.runningAnimators.remove(at: index)
                        let isExpanded = self.aniState == animateState.Extpended
                        let newState = isExpanded ? animateState.Collapsed : animateState.Extpended
                        self.aniState = newState
                    }
                }else {
                    debugPrint("animator completion with state = \(position)")
                   if let index = self.runningAnimators.firstIndex(of: frameAnimator) {
                        self.runningAnimators.remove(at: index)
                    }
                    debugPrint(self.runningAnimators.count)
                }
            }
            
            progressWhenInterrupted = frameAnimator.fractionComplete
            runningAnimators.append(frameAnimator)

        }else {
            
        }
    }
    
    func animateOrReverseRunningTransition(state: animateState, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeed(forState: aniState, duration: duration)
            for animator in runningAnimators {
                animator.startAnimation()
            }
        }else {
            for animator in runningAnimators {
                animator.isReversed = !animator.isReversed
//                animator.startAnimation()
                debugPrint("反转")
            }
        }
    }
    
    func updateInteractiveTransition(fractionComplete: CGFloat) {
        for animator in runningAnimators {
            animator.fractionComplete = fractionComplete
           
        }
        
    }
    
    func continueInteractiveTransition(extpend: Bool) {
        for animator in runningAnimators {
            switch aniState {
            case .Extpended:
                if extpend {
                    let timing = UISpringTimingParameters(dampingRatio: 1)
                    animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
                }else {
                    let timing = UISpringTimingParameters(dampingRatio: 1)
                    animator.isReversed = !animator.isReversed
                    animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
                }
            case .Collapsed:
                if extpend {
                    let timing = UISpringTimingParameters(dampingRatio: 1)
                     animator.isReversed = !animator.isReversed
                    animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
                }else {
                    let timing = UISpringTimingParameters(dampingRatio: 1)
                   
                    animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
                }
            }
            
        }
    }

}
