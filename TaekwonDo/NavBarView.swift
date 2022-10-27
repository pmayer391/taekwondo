//
//  TaekwonDoVC.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/26/22.
//

import Foundation
import UIKit

@IBDesignable
class NavBarView : UIView{
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAddItem: UIButton!
    @IBOutlet weak var lblAddItem: UILabel!
    @IBOutlet weak var imgAddItem: TDImageView!
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet weak var lblSort: UILabel!
    @IBOutlet weak var imgSort: TDImageView!
    
    var navController: NavController!
    var title: String = ""{
        didSet{
            lblTitle.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let bundle = Bundle(for: NavBarView.self)
        let nib = UINib(nibName: "NavBarView", bundle: bundle)
        contentView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imgSort.image = imgSort.image?.withRenderingMode(.alwaysTemplate)
        imgAddItem.tintColor = .white
        imgSort.image = imgSort.image?.withRenderingMode(.alwaysTemplate)
        imgSort.tintColor = .white
    }
    
}
