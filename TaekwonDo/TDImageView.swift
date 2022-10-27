//
//  TdImageView.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/26/22.
//

import UIKit

@IBDesignable
class TDImageView: UIImageView {
    
    @IBInspectable var imageColor: UIColor = UIColor.clear {
        didSet{
            self.setImageProperties()
        }
    }

    func setImageProperties(){
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = imageColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setImageProperties()
    }
}
