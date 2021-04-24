//
//  HomeNavigationController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/07.
//

import UIKit

final class HomeNavigationController: UINavigationController, BackgroundBlur {
    
    let addButtonView: UIView = {
        let addButtonView = UIView()
        addButtonView.translatesAutoresizingMaskIntoConstraints = false
        addButtonView.backgroundColor = .linkMoaDarkBlueColor
        addButtonView.layer.masksToBounds = true
        addButtonView.layer.cornerRadius = 63 / 2
        return addButtonView
    }()
    
    let plusImageView: UIImageView = {
        let plusImageView = UIImageView(image: UIImage(systemName: "plus"))
        plusImageView.tintColor = .white
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        return plusImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        prepareNavigationBar()
        prepareAddButonView()
    }
    
    private func prepareNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = UIColor.clear
        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "chevron.left")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -10, bottom: -3, right: 0))
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -10, bottom: -3, right: 0))
    }
    
    private func prepareAddButonView() {
        addButtonView.addSubview(plusImageView)
        view.addSubview(addButtonView)
        
        NSLayoutConstraint.activate([
            plusImageView.widthAnchor.constraint(equalToConstant: 28),
            plusImageView.heightAnchor.constraint(equalToConstant: 28),
            plusImageView.centerXAnchor.constraint(equalTo: addButtonView.centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: addButtonView.centerYAnchor),
            addButtonView.widthAnchor.constraint(equalToConstant: 63),
            addButtonView.heightAnchor.constraint(equalToConstant: 63),
            addButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -39),
            addButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -39)
        ])
    }
}

extension HomeNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
