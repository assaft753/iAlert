//
//  SideMenuSoundOptionTableViewCell.swift
//  iAlert
//
//  Created by Assaf Tayouri on 02/05/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit

class SideMenuSoundOptionTableViewCell: SideMenuOptionTableViewCell {
    
    var soundToggleView:UISwitch = {
        let soundToggle:UISwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 200, height: 32))
        soundToggle.onTintColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        soundToggle.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        soundToggle.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        soundToggle.thumbTintColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
        soundToggle.layer.cornerRadius = 20
        return soundToggle
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setRTLDirection()
     {
        super.setRTLDirection()
        soundToggleView.translatesAutoresizingMaskIntoConstraints = false
        soundToggleView.rightAnchor.constraint(equalTo: optionLabelView.leftAnchor,constant: -30).isActive = true
        soundToggleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        soundToggleView.transform = CGAffineTransform(scaleX: -transform.a, y: transform.d)
        iconImageView.transform = CGAffineTransform(scaleX: -transform.a, y: transform.d)
    }
    
    override func setLTRDirection()
    {
        super.setLTRDirection()
        soundToggleView.translatesAutoresizingMaskIntoConstraints = false
        soundToggleView.leftAnchor.constraint(equalTo: optionLabelView.rightAnchor,constant: 30).isActive = true
        soundToggleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func setSubviews() {
        super.setSubviews()
        addSubview(soundToggleView)
    }
    
    
    
}
