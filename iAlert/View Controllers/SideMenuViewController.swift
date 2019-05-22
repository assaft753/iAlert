//
//  SideMenuTableViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 28/04/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    var sideMenuTableView:UITableView!
    var logoImageView:UIImageView!
    weak var delegate:SideMenuViewControllerDelegate?
    
    let optionReuseIdentifier = "sideMenuOptionCell"
    let soundOptionReuseIdentifier = "sideMenuSoundOptionCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.SECONDARY_COLOR
    }
    
    override func loadView() {
        super.loadView()
        initBottomLogoImage()
        initSideMenuTableView()
    }
    
    func initBottomLogoImage()
    {
        logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        logoImageView.image = #imageLiteral(resourceName: "pikud_logo")
        view.addSubview(logoImageView)
        setBottomLogoImageConstrains()
    }
    
    
    func setBottomLogoImageConstrains()
    {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        logoImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -24).isActive = true
        
        if Settings.shared.direction == .RTL
        {
            let centerXImageView = ((view.center.x+40)/2)
            logoImageView.centerXAnchor.constraint(equalTo: view.rightAnchor,constant: -centerXImageView).isActive = true
        }
        
        if Settings.shared.direction == .LTR
        {
            let centerXImageView = ((view.center.x+40)/2)-16
            logoImageView.centerXAnchor.constraint(equalTo: view.leftAnchor,constant: centerXImageView).isActive = true
            
        }
    }
    
    func initSideMenuTableView()
    {
        sideMenuTableView = UITableView()
        sideMenuTableView.delegate = self
        sideMenuTableView.dataSource = self
        
        sideMenuTableView.backgroundColor = UIColor.SECONDARY_COLOR
        sideMenuTableView.separatorStyle = .none
        sideMenuTableView.rowHeight = 80
        sideMenuTableView.isScrollEnabled = false
        
        sideMenuTableView.register(SideMenuOptionTableViewCell.self, forCellReuseIdentifier: optionReuseIdentifier)
        sideMenuTableView.register(SideMenuSoundOptionTableViewCell.self, forCellReuseIdentifier: soundOptionReuseIdentifier)
        view.addSubview(sideMenuTableView)
        
        sideMenuTableView.translatesAutoresizingMaskIntoConstraints = false
        sideMenuTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        sideMenuTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        sideMenuTableView.topAnchor.constraint(equalTo: view.topAnchor,constant: 80).isActive = true
        sideMenuTableView.bottomAnchor.constraint(equalTo: logoImageView.topAnchor,constant: -16).isActive = true
    }
    
    func pickLanguage()
    {
        delegate?.pickLanguage()
    }
    
    func chooseAreas()
    {
        delegate?.chooseAreas()
    }
    
    @objc func toggledSound(_ sender:UISwitch)
    {
        Settings.shared.sound = sender.isOn
    }
    
    
}

extension SideMenuViewController:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SideMenuOption.numberOfOptions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let sideMenuOption = SideMenuOption(rawValue: indexPath.row)
        {
            switch sideMenuOption
            {
            case .Sound:
                let soundOptionCell = tableView.dequeueReusableCell(withIdentifier: soundOptionReuseIdentifier, for: indexPath) as! SideMenuSoundOptionTableViewCell
                soundOptionCell.iconImageView.image = sideMenuOption.optionImage
                soundOptionCell.optionLabelView.text = "\(sideMenuOption)"
                soundOptionCell.soundToggleView.setOn(Settings.shared.sound, animated: false)
                soundOptionCell.soundToggleView.addTarget(self, action: #selector(toggledSound(_:)), for: .valueChanged)
                return soundOptionCell
            default:
                let optionCell = tableView.dequeueReusableCell(withIdentifier: optionReuseIdentifier, for: indexPath) as! SideMenuOptionTableViewCell
                optionCell.iconImageView.image = sideMenuOption.optionImage
                optionCell.optionLabelView.text = "\(sideMenuOption)"
                return optionCell
            }
            
        }
        else
        {
            let optionCell = tableView.dequeueReusableCell(withIdentifier: optionReuseIdentifier, for: indexPath) as! SideMenuOptionTableViewCell
            optionCell.iconImageView.image = nil
            optionCell.optionLabelView.text = "sideMenuOption"
            return optionCell
        }
    }
    
    
}

extension SideMenuViewController:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sideMenuOption = SideMenuOption(rawValue: indexPath.row)
        {
            switch sideMenuOption
            {
                
            case .Language:
                pickLanguage()
            case .Areas:
                chooseAreas()
            default:
                break
            }
        }
    }
}
