//
//  NavController.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/26/22.
//

import UIKit

class NavController: UINavigationController {
    
    override func awakeFromNib() {
        configure()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configure(){
        self.setNavigationBarHidden(true, animated: false)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
    
}
