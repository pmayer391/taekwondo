//
//  MainVC.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/26/22.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var titleContainer: UIStackView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var appIcon: UIImageView!
    var topPadding: CGFloat = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleContainer.alpha = 0
        topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0 +
        UIApplication.shared.statusBarFrame.height
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if traitCollection.userInterfaceStyle == .light{
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: { [weak self] in
            self?.titleContainer.alpha = 1
        }, completion: { [weak self] _ in
            
            UIView.animate(withDuration: 2, delay: 1, options: .transitionCurlDown, animations: { [weak self] in
                guard let strong = self else {return}
                strong.appIcon.alpha = 0
                strong.titleContainer.center = CGPoint(x: strong.titleContainer.center.x, y: 80 + strong.topPadding)
                strong.titleLbl.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
            }, completion: { [weak self] _ in
                self?.navigationController?.pushViewController(TaekwonDoVC(), animated: false)
            })
        })
    }

}
