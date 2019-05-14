//
//  SideMenuTableViewCell.swift
//  iAlert
//
//  Created by Assaf Tayouri on 02/05/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit

class SideMenuOptionTableViewCell: UITableViewCell {
    
    lazy var iconImageView:UIImageView = {
        return createIconImageView()
    }()
    
    lazy var optionLabelView:UILabel = {
        return createOptionImageView()
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.SECONDARY_COLOR
        
        selectionStyle = .none
        
        setSubviews()
        
        if Settings.shared.direction == Direction.LTR
        {
            setLTRDirection()
        }
        else if Settings.shared.direction == Direction.RTL
        {
            setRTLDirection()
        }
        /*iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.leftAnchor.constraint(equalTo: leftAnchor,constant: 12).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true*/
    
        
        
        /*optionLabelView.translatesAutoresizingMaskIntoConstraints = false
        optionLabelView.leftAnchor.constraint(equalTo: iconImageView.rightAnchor,constant: 12).isActive = true
        optionLabelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setSubviews()
    {
        addSubview(iconImageView)
        addSubview(optionLabelView)
    }
    
    private func createIconImageView()->UIImageView
    {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        
        return iconView
    }
    
    private func createOptionImageView() -> UILabel
    {
        let optionLabel = UILabel()
        optionLabel.textColor = .white
        optionLabel.font = UIFont.DEFAULT_FONT.withSize(18)
        return optionLabel
    }
    
    
     func setRTLDirection()
    {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.rightAnchor.constraint(equalTo: rightAnchor,constant: -12).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        optionLabelView.translatesAutoresizingMaskIntoConstraints = false
        optionLabelView.rightAnchor.constraint(equalTo: iconImageView.leftAnchor,constant: -12).isActive = true
        optionLabelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
     func setLTRDirection()
    {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.leftAnchor.constraint(equalTo: leftAnchor,constant: 12).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        optionLabelView.translatesAutoresizingMaskIntoConstraints = false
        optionLabelView.leftAnchor.constraint(equalTo: iconImageView.rightAnchor,constant: 12).isActive = true
        optionLabelView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
