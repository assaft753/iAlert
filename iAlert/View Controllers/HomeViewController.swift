//
//  HomeViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 28/04/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class HomeViewController: UIViewController {
    
    
    
    var gmsMapView:GMSMapView?
    var navigateMeButtonView:UIButton?
    weak var delegate:HomeViewControllerDelegate?
    let locationManager:CLLocationManager = CLLocationManager()
    var toFollow:Bool = true
    var firstTimeCircularRegion:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        updateUI()
    }
    
    override func loadView() {
        super.loadView()
        initGMSMapView()
        initBottomButtonView()
        initNavigationBarView()
    }
    
    
    func initBottomButtonView(){
        
        let buttonView = UIButton(type: .system)
        buttonView.backgroundColor = UIColor.SECONDARY_COLOR
        buttonView.tintColor = UIColor.PRIMARY_COLOR
        buttonView.setTitle("navigateBtn".localized, for: .normal)
        buttonView.setTitleColor(.white, for: .normal)
        buttonView.titleLabel?.font = UIFont.DEFAULT_FONT.withSize(20)
        buttonView.titleLabel?.adjustsFontForContentSizeCategory = true
        
        buttonView.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20)
        buttonView.layoutIfNeeded()
        buttonView.layer.cornerRadius = 20
        
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        buttonView.layer.shadowOpacity = 0.5
        buttonView.layer.shadowRadius = 4
        buttonView.layer.masksToBounds = false
        
        view.addSubview(buttonView)
        view.bringSubview(toFront: buttonView)
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        
        buttonView.addTarget(self, action: #selector(navigateMeButtonPressed(_:)), for: .touchUpInside)
        
        self.navigateMeButtonView = buttonView
        
    }
    
    func initGMSMapView(){
        
        guard gmsMapView == nil else{return}
        
        let gmsMapView = GMSMapView.init(frame: CGRect.zero)
        gmsMapView.delegate = self
        view.addSubview(gmsMapView)
        view.sendSubview(toBack: gmsMapView)
        gmsMapView.isMyLocationEnabled = true
        gmsMapView.settings.myLocationButton = true
        gmsMapView.translatesAutoresizingMaskIntoConstraints = false
        gmsMapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        gmsMapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        gmsMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gmsMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.gmsMapView = gmsMapView
    }
    
    func initNavigationBarView(){
        navigationController?.navigationBar.barTintColor = UIColor.PRIMARY_COLOR
        navigationController?.navigationBar.barStyle = .blackOpaque
        
        let barImage = #imageLiteral(resourceName: "rocket")
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = barImage
        
        navigationItem.titleView = imageView
    }
    
    
    @objc func toggleMenu()
    {
        delegate?.toggleMenu()
    }
    
    @objc func navigateMeButtonPressed(_ sender:UIButton)
    {
        delegate?.navigateMeButtonPressed()
    }
}


extension HomeViewController{
    
    func updateUI()
    {
        if Settings.shared.direction == Direction.LTR
        {
            updateLTRUI()
        }
        else
        {
            updateRTLUI()
        }
        updateNonDirectionalsUI()
    }
    
    private func updateNonDirectionalsUI()
    {
        self.navigateMeButtonView?.setTitle("navigateBtn".localized, for: .normal)
    }
    
    private func updateRTLUI()
    {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(toggleMenu))
    }
    
    private func updateLTRUI()
    {
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(toggleMenu))
        
        updateNonDirectionalsUI()
    }
    
    private func pinSafePlacesToGMSMapView(safePlaces:[SafePlace]?)
    {
        guard let googleMap = gmsMapView else {
            return
        }
        
        if let safePlaces = safePlaces,safePlaces.count > 0 {
            safePlaces.forEach{
                let marker = GMSMarker(position: $0.coordinate)
                let icon = #imageLiteral(resourceName: "marker")
                marker.icon = icon
                marker.map = googleMap
            }
        }
    }
    
    private func updateSafePlaces(for coordinate:CLLocationCoordinate2D)
    {
        
        iAlertService.shared.getAndSaveAllClosestsSafePlaces(for: coordinate){
            safePlaces in
            DispatchQueue.main.async {
               [weak self] in self?.pinSafePlacesToGMSMapView(safePlaces: safePlaces)
            }
        }
    }
}

extension CLCircularRegion
{
    static func createExitCLCircularRegion(for center:CLLocationCoordinate2D)->CLCircularRegion
    {
        let circularRegion = CLCircularRegion(center: center, radius: ConstsKey.CIRCULAR_EXIT_REGION_RADIUS, identifier: ConstsKey.CIRCULAR_EXIT_REGION_ID)
        circularRegion.notifyOnExit = true
        circularRegion.notifyOnEntry = true
        return circularRegion
    }
}

extension HomeViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            return
        }
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        if location.timestamp.timeIntervalSinceNow > 60
        {
            return
        }
        
        
        if firstTimeCircularRegion
        {
            firstTimeCircularRegion = !firstTimeCircularRegion
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
            gmsMapView?.animate(to: camera)
            gmsMapView?.camera = camera
            manager.startMonitoring(for: CLCircularRegion.createExitCLCircularRegion(for: location.coordinate))
            setGMSCircle(for:location.coordinate)
        }
        else if toFollow
        {
            print(gmsMapView!.camera.zoom)
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: gmsMapView!.camera.zoom)
            gmsMapView?.animate(to: camera)
            gmsMapView?.camera = camera
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let coordinate = gmsMapView?.myLocation?.coordinate
        {
            manager.startMonitoring(for: CLCircularRegion.createExitCLCircularRegion(for: coordinate))
            setGMSCircle(for: coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(region)
    }
    
    func setGMSCircle(for center:CLLocationCoordinate2D)
    {
        gmsMapView?.clear()
        /*let gmsCircle = GMSCircle(position: center, radius: ConstsKey.CIRCULAR_EXIT_REGION_RADIUS)
        gmsCircle.fillColor = .red
        gmsCircle.strokeColor = .red
        gmsCircle.strokeWidth = 5
        gmsCircle.map = gmsMapView*/
        updateSafePlaces(for: center)
    }
    
}

extension HomeViewController:GMSMapViewDelegate
{
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture
        {
            toFollow = false
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        toFollow = true
        return false
    }
}
