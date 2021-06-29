//
//  BackgroundBlur.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/24.
//

import UIKit

protocol BackgroundBlur: UIViewController {}

extension BackgroundBlur where Self: UIViewController {
    
    private func makeBackgroundView() -> UIView {
        let backgroundView: UIView = UIView()
        backgroundView.tag = 20
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0
        backgroundView.isHidden = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }
    
    func fadeInBackgroundViewAnimation() {
        let backgroundView = makeBackgroundView()
        var view = self.view!
        if let navi = navigationController {
            view = navi.view
        }
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        UIView.animate(withDuration: 0.4, animations: {
            backgroundView.alpha = 0.3
        })
    }
    
    func fadeOutBackgroundViewAnimation() {
        var view = self.view!
        if let navi = navigationController {
            view = navi.view
        }
        
        guard let backgroundView = view.subviews.filter({$0.tag == 20}).first else { return }
        UIView.animate(withDuration: 0.4, animations: {
            backgroundView.alpha = 0
        }, completion: { _ in
            backgroundView.subviews.forEach { $0.layer.removeAllAnimations() }
            backgroundView.layer.removeAllAnimations()
            backgroundView.removeFromSuperview()
        })
    }
}

extension BackgroundBlur where Self: UINavigationController {

    private func makeBackgroundView() -> UIView {
        let backgroundView: UIView = UIView()
        backgroundView.tag = 20
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0
        backgroundView.isHidden = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }

    func animateBackGroundView() {
        let backgroundView = makeBackgroundView()
        view.addSubview(backgroundView)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        UIView.animate(withDuration: 0.4, animations: {
            backgroundView.alpha = 0.3
        })
    }

    func removeBackgroundView() {
        guard let backgroundView = view.subviews.filter({$0.tag == 20}).first else { return }
        UIView.animate(withDuration: 0.4, animations: {
            backgroundView.alpha = 0
        }, completion: { _ in
            backgroundView.subviews.forEach { $0.layer.removeAllAnimations() }
            backgroundView.layer.removeAllAnimations()
            backgroundView.removeFromSuperview()
        })
    }
}
