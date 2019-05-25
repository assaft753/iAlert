//
//  ContainerViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 28/04/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit
import CoreLocation

class ContainerViewController: UIViewController {
    var homeViewController:HomeViewController?
    var sideMenuViewController:SideMenuViewController?
    var centerNavigationController:UINavigationController?
    var animateSideMenuDirectionFunc:(()->Void)?
    var selfNavigationToSafePlaceFunc:((CLLocationCoordinate2D)->Void)?
    var remoteNavigationToSafePlaceFunc:((Int,CLLocationCoordinate2D)->Void)?
    var currentRedAlertId:Int?
    var pickedLanguageId:String!
    var currentLocation:CLLocationCoordinate2D?
    var loaderVC:UIAlertController?
    var isMenuVisible:Bool = false
    var isAskForLocationManually = false
    var isAvailable:Bool = true
    var globalLocker:NSObject = NSObject()
    var selfLocationLocker:NSObject = NSObject()
    var locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initHomeViewController()
        initAnimationDirectionFunc()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func lockAvilability() ->Bool
    {
        objc_sync_enter(globalLocker)
        let beforeIsAvailable = isAvailable
        if isAvailable
        {
            isAvailable = !isAvailable
        }
        objc_sync_exit(globalLocker)
        return beforeIsAvailable
    }
    
    func remoteNavigationToSafePlace(redAlertId:Int)
    {
        guard lockAvilability() else {return}
        startRemoteNavigationToSafePlace(redAlertId: redAlertId)
    }
    
    func selfNavigationToSafePlace(){
        guard lockAvilability() else {return}
        self.startSelfNavigationToSafePlace()
    }
    
    
    func askUserForWishingNavigation(alertId:Int)
    {
        guard lockAvilability() else {return}
        showWishingNavigationDialog(alertId: alertId)
    }
    
    func showWishingNavigationDialog(alertId:Int)
    {
        let alert = UIAlertController(title: "guide dialog title".localized, message: "guide dialog message".localized, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { [weak self] _ in
            self?.startRemoteNavigationToSafePlace(redAlertId: alertId)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: {[weak self]_ in
            self?.isAvailable = true}))
        
        self.present(alert, animated: true)
    }
    
    func showLoaderView()
    {
        loaderVC = UIAlertController(title: "safe place".localized, message: "wait".localized, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 12, y: 10, width: 80, height: 80))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        loaderVC?.view.addSubview(loadingIndicator)
        present(loaderVC!, animated: true, completion: nil)
    }
    
    func hideLoaderView(completion:(()->Void)?)
    {
        loaderVC?.dismiss(animated: true, completion: completion)
    }
    
    
    func sampleLocation()
    {
        isAskForLocationManually = true
        locationManager.requestLocation()
    }
    
    func startRemoteNavigationToSafePlace(redAlertId:Int)
    {
        showLoaderView()
        
        remoteNavigationToSafePlaceFunc = nil
        selfNavigationToSafePlaceFunc = nil
        currentRedAlertId = nil
        
        if let currentLocation = currentLocation
        {
            remoteNavigationToSafePlace(redAlertId: redAlertId, coordinate: currentLocation)
        }
        else if let currentLocation = homeViewController?.gmsMapView?.myLocation?.coordinate
        {
            remoteNavigationToSafePlace(redAlertId: redAlertId, coordinate: currentLocation)
        }
        else
        {
            remoteNavigationToSafePlaceFunc = self.remoteNavigationToSafePlace
            currentRedAlertId = redAlertId
            sampleLocation()
        }
    }
    
    func startSelfNavigationToSafePlace()
    {
        showLoaderView()
        remoteNavigationToSafePlaceFunc = nil
        selfNavigationToSafePlaceFunc = nil
        currentRedAlertId = nil
        
        if let currentLocation = currentLocation
        {
            selfNavigationToSafePlace(coordinate: currentLocation)
        }
        else if let currentLocation = homeViewController?.gmsMapView?.myLocation?.coordinate
        {
            selfNavigationToSafePlace(coordinate: currentLocation)
        }
        else
        {
            selfNavigationToSafePlaceFunc = self.selfNavigationToSafePlace
            sampleLocation()
        }
    }
    
    func selfNavigationToSafePlace(coordinate:CLLocationCoordinate2D)
    {
        iAlertService.shared.getSelfClosestSafePlace(for: coordinate){
            [weak self] safePlace,err in
            
            if let _ = err
            {
                self?.showErrorDialog()
                return
            }
            
            if let safePlace = safePlace
            {
                DispatchQueue.main.sync {
                    self?.hideLoaderView {
                        let navVC = NavigateViewController()
                        navVC.safePlace = safePlace
                        navVC.delegate = self
                        self?.present(navVC,animated: true)
                    }
                }
            }
            else
            {
                self?.showNotFoundDialog()
            }
        }
    }
    
    func remoteNavigationToSafePlace(redAlertId:Int,coordinate:CLLocationCoordinate2D)
    {
        iAlertService.shared.getSafePlaceAfterNotification(redAlertId: redAlertId, coordinate: coordinate){[weak self]
            latitude,longitude,time,isFound,error in
            
            if !isFound
            {
                if let _ = error
                {
                    self?.showErrorDialog()
                    return
                }
                else
                {
                    self?.showNotFoundDialog()
                    return
                }
            }
            
            
            let safePlace = SafePlace(longitude: longitude!, latitude: latitude!, address: nil, time: time!, redAlertId: redAlertId)
            
            DispatchQueue.main.sync {
                self?.hideLoaderView {
                    let navVC = NavigateViewController()
                    navVC.safePlace = safePlace
                    navVC.delegate = self
                    self?.present(navVC,animated: true)
                }
            }
        }
    }
    
    func showErrorDialog()
    {
        hideLoaderView{ [weak self] in
            self?.showAlert(title: "safe place".localized, message: "error".localized){
                self?.isAvailable = true
            }
        }
    }
    
    func showNotFoundDialog()
    {
        hideLoaderView{ [weak self] in
            self?.showAlert(title: "safe place".localized, message: "not arrived".localized){
                self?.isAvailable = true
            }
        }
    }
    
    func showAlert(title:String?,message:String?,completion:(()->Void)?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default,handler:{_ in
            completion?()
        }))
        present(alert, animated: true, completion: completion)
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
        self.present(alert,animated: true)
    }
    
    private func showChooseAreas()
    {
        iAlertService.shared.GetAllAreasWithPreffered { areas in
            if let areas = areas
            {
                let areasVC = AreasTableViewController()
                areasVC.allAreas = areas
                DispatchQueue.main.sync {
                    self.present(UINavigationController(rootViewController: areasVC),animated: true)
                }
                
            }
        }
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let homeViewController = homeViewController,((homeViewController.view?.subviews.last) as? TransparentView) != nil,isMenuVisible == true
        {
            isMenuVisible = !isMenuVisible
            toggleSideMenu(shouldExpand: isMenuVisible)
        }
    }
}

extension ContainerViewController:NavigateViewControllerDelegate
{
    func finishNavigation() {
        self.isAvailable = true
    }
}

extension ContainerViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else
        {
            showErrorDialog()
            return
        }
        if(location.timestamp.timeIntervalSinceNow <= 60)
        {
            currentLocation = location.coordinate
        }
        
        objc_sync_enter(selfLocationLocker)
        if isAskForLocationManually
        {
            isAskForLocationManually = false
            objc_sync_exit(selfLocationLocker)
            if let method = remoteNavigationToSafePlaceFunc,let redAlertId = currentRedAlertId
            {
                method(redAlertId,location.coordinate)
                return
            }
            if let method = selfNavigationToSafePlaceFunc
            {
                method(location.coordinate)
                return
            }
        }
        else
        {
            objc_sync_exit(selfLocationLocker)
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showErrorDialog()
    }
}

extension ContainerViewController:HomeViewControllerDelegate
{
    func navigateMeButtonPressed() {
        selfNavigationToSafePlace()
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
