//
//  ViewController.swift
//  animter
//
//  Created by Mac on 2020/6/29.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var cycle = UIView()
    
    var animator : UIViewPropertyAnimator!
    
    var animatorx : UIViewPropertyAnimator!
    
    var progressWhenInterrupted : CGFloat = 0
    var progressWhenInterruptedx : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
       
        cycle = UIView(frame: CGRect(origin: CGPoint(x: view.center.x - 25, y: view.center.y - 300), size: CGSize(width: 50, height: 50)))
        cycle.layer.cornerRadius = 25
        cycle.layer.maskedCorners = [.layerMinXMaxYCorner]
        cycle.layer.backgroundColor = UIColor.systemBlue.cgColor
        view.addSubview(cycle)
    
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        cycle.addGestureRecognizer(panGes)
        
        rotation()
        self.title = "动画效果"
        view.backgroundColor = .white
        
        let btn = UIButton(frame: CGRect(origin: view.center, size: CGSize(width: 100, height: 150)))
        btn.setTitle("下一个", for: [])
        btn.setTitleColor(.systemBlue, for: [])
        btn.addTarget(self, action: #selector(self.toNext), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc
    func toNext() {
        let vc = AnimateViewController()
        vc.view.backgroundColor = .white
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animateTransitionIfNeeded(duration: 2)
            animator.pauseAnimation()
            animatorx.pauseAnimation()
            progressWhenInterrupted = animator.fractionComplete
             progressWhenInterruptedx = animatorx.fractionComplete
        case .changed:
            print("滑动")
            let translation = recognizer.translation(in: self.cycle)
            animator.fractionComplete = translation.y / 300 + progressWhenInterrupted
            animatorx.fractionComplete = translation.x / 100 + progressWhenInterruptedx
        case .ended:
            let timing = UICubicTimingParameters(animationCurve: .easeOut)
            animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
            animatorx.continueAnimation(withTimingParameters: timing, durationFactor: 0)
        default:
            return
        }
    }
    
    func animateTransitionIfNeeded(duration: TimeInterval) {
        if animator == nil {
            animator = UIViewPropertyAnimator(duration:duration, curve: .easeOut, animations: {
                self.cycle.frame = self.cycle.frame.offsetBy(dx: 0, dy: 300)
//                self.cycle.layer.opacity = 0
            })
            animator.pausesOnCompletion = true
            animator.addObserver(self, forKeyPath: "running", options: [.new], context: nil)
            animatorx = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
                self.cycle.frame = self.cycle.frame.offsetBy(dx: 100, dy: 0)
            })
            animatorx.pausesOnCompletion = true
        
        }
    }
    

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "running" {
            debugPrint("动画结束")
        }
    }
    
    func rotation() {
        print("旋转动画")
        let animatorRotation = UIViewPropertyAnimator(duration: 5, curve: .easeOut) {
            for _ in 0..<20 {
                let totation = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                self.cycle.transform = self.cycle.transform.concatenating(totation)
            }
        }
        
        animatorRotation.startAnimation()
    }

}





