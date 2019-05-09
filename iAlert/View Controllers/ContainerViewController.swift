//
//  ContainerViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 28/04/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    var homeViewController:HomeViewController?
    var sideMenuViewController:SideMenuViewController?
    var centerNavigationController:UINavigationController?
    var animateSideMenuDirectionFunc:(()->Void)?
    var pickedLanguageId:String!
    var isMenuVisible:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initHomeViewController()
        initAnimationDirectionFunc()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func initSideMenuViewController()
    {
        if sideMenuViewController == nil
        {
            sideMenuViewController = SideMenuViewController()
            sideMenuViewController!.delegate = self
            
            view.insertSubview(sideMenuViewController!.view, at: 0)
            
            sideMenuViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            sideMenuViewController!.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            sideMenuViewController!.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            sideMenuViewController!.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            sideMenuViewController!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            addChildViewController(sideMenuViewController!)
            sideMenuViewController!.didMove(toParentViewController: self)
        }
    }
    
    func deinitSideMenuViewController()
    {
        self.sideMenuViewController?.view.removeFromSuperview()
        self.sideMenuViewController?.removeFromParentViewController()
        self.sideMenuViewController = nil
    }
    
    
    func initHomeViewController()
    {
        if homeViewController == nil
        {
            homeViewController = HomeViewController()
            homeViewController?.delegate = self
            let navigationViewController = UINavigationController(rootViewController: homeViewController!)
            navigationViewController.view.layer.shadowOpacity = 0.8
            view.addSubview(navigationViewController.view)
            addChildViewController(navigationViewController)
            navigationViewController.didMove(toParentViewController: self)
            centerNavigationController = navigationViewController
        }
    }
    
    
    func toggleSideMenu(shouldExpand:Bool,action onClose:(()->Void)? = nil)
    {
        if shouldExpand == true
        {
            guard centerNavigationController != nil,let sideFunc = animateSideMenuDirectionFunc else{return}
            initSideMenuViewController()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: sideFunc, completion: {
                _ in
                let transparentView = TransparentView(frame: CGRect(x: 0, y: 0, width: self.homeViewController!.view.bounds.width, height: self.homeViewController!.view.bounds.height))
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                transparentView.addGestureRecognizer(tap)
                transparentView.isUserInteractionEnabled = true
                
                self.homeViewController!.view.addSubview(transparentView)
            })
        }
        else
        {
            guard let centerNavigationController = centerNavigationController else{return}
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                centerNavigationController.view.frame.origin.x = 0
            }, completion: {_ in
                if let homeViewController = self.homeViewController,let tranparentView = homeViewController.view?.subviews.last as? TransparentView{
                    tranparentView.removeFromSuperview()
                    self.deinitSideMenuViewController()
                    onClose?()
                }
            })
        }
    }
    
    private func showPickLanguage()
    {
        let alert = UIAlertController(title: "pickLanguage".localized, message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        
        alert.view.addSubview(pickerFrame)
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { [weak self] (UIAlertAction)  in
            self!.updateLanguage(for: self!.pickedLanguageId)
        }))
        self.pickedLanguageId = Language.LANGUAGE_IDS[0]
        self.present(alert,animated: true, completion: nil )
    }
    
    private func showChooseAreas()
    {
        print("show Choose Areas")
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let homeViewController = homeViewController,((homeViewController.view?.subviews.last) as? TransparentView) != nil,isMenuVisible == true
        {
            isMenuVisible = !isMenuVisible
            toggleSideMenu(shouldExpand: isMenuVisible)
        }
    }
    
}

extension ContainerViewController:HomeViewControllerDelegate
{
    func navigateMeButtonPressed() {
        self.present(NavigateViewController(), animated: true)
    }
    
    func toggleMenu() {
        isMenuVisible = !isMenuVisible
        toggleSideMenu(shouldExpand: isMenuVisible)
    }
}

extension ContainerViewController:SideMenuViewControllerDelegate
{
    func pickLanguage() {
        if isMenuVisible == true
        {
            isMenuVisible = !isMenuVisible
            toggleSideMenu(shouldExpand: isMenuVisible,action: self.showPickLanguage)
        }
    }
    
    func chooseAreas() {
        
        if isMenuVisible == true
        {
            isMenuVisible = !isMenuVisible
            toggleSideMenu(shouldExpand: isMenuVisible,action: self.showChooseAreas)
        }

    }
    
    
}

extension ContainerViewController
{
    func animateSideMenuRTLFunc(){
        centerNavigationController!.view.frame.origin.x = -(centerNavigationController!.view.center.x + 40)
    }
    
    func animateSideMenuLTRFunc(){
        centerNavigationController!.view.frame.origin.x = centerNavigationController!.view.center.x + 40
    }
    
    func initAnimationDirectionFunc()
    {
        if Settings.shared.direction == Direction.LTR
        {
            animateSideMenuDirectionFunc = animateSideMenuLTRFunc
        }
        
        if Settings.shared.direction == Direction.RTL
        {
            animateSideMenuDirectionFunc = animateSideMenuRTLFunc
        }
    }
    
    func updateLanguage(for languageId:String)
    {
        if let lanId = Settings.shared.languageId,lanId != languageId {
            Settings.shared.languageId = languageId
            homeViewController?.updateUI()
            initAnimationDirectionFunc()
        }
    }
    
    
}

extension ContainerViewController:UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Language.LANGUAGE_STRS.count
    }
    
    
}

extension ContainerViewController:UIPickerViewDelegate
{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Language.LANGUAGE_STRS[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickedLanguageId = Language.LANGUAGE_IDS[row]
    }
}
