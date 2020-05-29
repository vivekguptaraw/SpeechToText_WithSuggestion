//
//  SpeechTextTableViewCell.swift
//  SpeechToText
//
//  Created by Vivek Gupta on 28/05/20.
//  Copyright © 2020 Vivek Gupta. All rights reserved.
//

import UIKit

class SpeechTextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

protocol NibLoadableProtocol {
    static var defaultNibName: String { get }
    static func loadFromNib() -> Self
}

extension NibLoadableProtocol where Self: UIView {
    
    static var defaultNibName: String {
        return String(describing: self)
    }
    
    static var defaultNib: UINib {
        return UINib(nibName: defaultNibName, bundle: nil)
    }
    
    static func loadFromNib() -> Self {
        guard let nib = Bundle.main.loadNibNamed(defaultNibName, owner: nil, options: nil)?.first as? Self else {
            fatalError("[NibLoadableProtocol] Cannot load view from nib.")
        }
        return nib
    }
}

extension UITableViewCell: NibLoadableProtocol {
    
}
