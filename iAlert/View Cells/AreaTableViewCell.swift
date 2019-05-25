//
//  AreaTableViewCell.swift
//  iAlert
//
//  Created by Assaf Tayouri on 10/05/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit

class AreaTableViewCell: UITableViewCell {

    var area:Area!
    
    lazy var cityNameLabel:UILabel = {
        let cityNameLabel = UILabel(frame: CGRect.zero)
        cityNameLabel.font = UIFont.DEFAULT_FONT.withSize(17)
        cityNameLabel.textColor = .black
        cityNameLabel.numberOfLines = 1
        cityNameLabel.adjustsFontSizeToFitWidth = true;
        
        return cityNameLabel
    }()
    
    lazy var areaCodeLabel:UILabel = {
       let areaCodeLabel = UILabel(frame: CGRect.zero)
        areaCodeLabel.font = UIFont.DEFAULT_FONT.withSize(12)
        areaCodeLabel.textColor = .darkGray
        areaCodeLabel.numberOfLines = 1
        return areaCodeLabel
    }()
    
    lazy var checkbox:VKCheckbox = {
        let checkbox = VKCheckbox(frame: CGRect.zero)
        checkbox.line = .thin
        checkbox.bgColorSelected = UIColor.SECONDARY_COLOR
        //checkbox.bgColor = UIColor.white
        checkbox.color = UIColor.white
        checkbox.borderColor = UIColor.SECONDARY_COLOR
        checkbox.borderWidth = 1.3
        return checkbox
    }()
    
    weak var delegate:AreasDelegate?
    
    func valueChanged(isOn:Bool)
    {
        if isOn,let delegate = delegate,!delegate.checkMaximumCurrentSafePlaces()
        {
            
        area.isPreffered = isOn
           iAlertService.shared.setPrefferedArea(areaCode: area.areaCode)
        }
        else if !isOn
        {
            area.isPreffered = isOn
            iAlertService.shared.deletePrefferedArea(areaCode: area.areaCode)
        }
        else
        {
            checkbox.reset();
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(checkbox)
        addSubview(areaCodeLabel)
        addSubview(cityNameLabel)
        
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        checkbox.widthAnchor.constraint(equalToConstant: 32).isActive = true
        checkbox.heightAnchor.constraint(equalToConstant: 32).isActive = true
        layoutSubviews()
        checkbox.cornerRadius = checkbox.frame.height / 2
        
        cityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cityNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor,constant: -8).isActive = true
        
        areaCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        areaCodeLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor,constant: 0).isActive = true
        
        layoutSubviews()
        
        
        if Settings.shared.direction == .RTL
        {
            initRTLViews()
        }
        
        else if Settings.shared.direction == .LTR
        {
           initLTRViews()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initRTLViews()
    {
        checkbox.rightAnchor.constraint(equalTo: rightAnchor,constant: -8).isActive = true
        
        areaCodeLabel.rightAnchor.constraint(equalTo: checkbox.leftAnchor,constant: -8).isActive = true
        
        cityNameLabel.rightAnchor.constraint(equalTo: checkbox.leftAnchor,constant: -8).isActive = true
        
        cityNameLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        cityNameLabel.textAlignment = .right
        
    }
    
    private func initLTRViews()
    {
        checkbox.leftAnchor.constraint(equalTo: leftAnchor,constant: 8).isActive = true
        
        areaCodeLabel.leftAnchor.constraint(equalTo: checkbox.rightAnchor,constant: 8).isActive = true
        
        cityNameLabel.leftAnchor.constraint(equalTo: checkbox.rightAnchor,constant: 8).isActive = true
        
        cityNameLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        cityNameLabel.textAlignment = .left
    }

}
