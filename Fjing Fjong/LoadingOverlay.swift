//
//  LoadingOverlay.swift
//  Fjing Fjong
//
//  Created by Fjorge Developers on 4/3/20.
//  Copyright © 2020 Fjorge. All rights reserved.
//

import Foundation
import UIKit
import Lottie

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

public class LoadingOverlay{

    var backgroundView = UIView()
    var overlayView = UIView()
    var LoadingAnimationView = AnimationView(name: "loading")
        
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }

    public func showOverlay(view: UIView) {
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        backgroundView.center = view.center
        backgroundView.backgroundColor = UIColor(rgb: 0x00000).withAlphaComponent(0.2)
        
        overlayView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        overlayView.center = CGPoint(x: backgroundView.bounds.width / 2, y: backgroundView.bounds.height / 2)
        overlayView.backgroundColor = UIColor(rgb: 0xFFFFFF)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        overlayView.dropShadow()
        
        LoadingAnimationView.frame = CGRect(x: 0, y: 0, width: 140, height: 170)
        LoadingAnimationView.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        LoadingAnimationView.contentMode = .scaleAspectFill
        LoadingAnimationView.alpha = 1.0
        LoadingAnimationView.animationSpeed = 0.8
        LoadingAnimationView.loopMode = .loop
        LoadingAnimationView.play()

        overlayView.addSubview(LoadingAnimationView)
        backgroundView.addSubview(overlayView)
        view.addSubview(backgroundView)
    }
    
    public func fadeOverlay() {
        UIView.animate(withDuration: 1.0, animations: {
            self.backgroundView.alpha = 0
        }, completion: { _ in
            self.backgroundView.removeFromSuperview()
        })
    }

    public func hideOverlay() {
        self.backgroundView.removeFromSuperview()
    }
    
    public func redrawOverlay(view: UIView){
        backgroundView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        overlayView.center = CGPoint(x: backgroundView.bounds.width / 2, y: backgroundView.bounds.height / 2)
    }
}
