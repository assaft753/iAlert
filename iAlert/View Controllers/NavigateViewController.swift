//
//  NavigateViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 08/05/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit
import GoogleMaps


class NavigateViewController: UIViewController {

    
    var gmsMapView:GMSMapView?
    var distanceButton:UIButton?
    var addressLabel:UILabel?
    var bottomView:UIView?
    
    var timeLabel:UILabel?
    var closeButton:UIButton?
    var topView:UIView?
    
    var safePlace:SafePlace! = SafePlace(longitude: 34.629111, latitude: 31.784373, address: "aaaaaaaaaaaaa")
    
    var toFollow:Bool = true
    let locationManager:CLLocationManager = CLLocationManager()
    var isFirstTimeLocation:Bool = true
    
    var distanceStr:String!
    {
        didSet {
            let str = "\(distanceStr!) \("Meter".localized)"
            distanceButton?.setTitle(str, for: .normal)
            distanceButton?.layoutIfNeeded()
            distanceButton?.layer.cornerRadius = ((distanceButton?.frame.width) ?? 0) / 2
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override var modalPresentationStyle: UIModalPresentationStyle{
    get {
        return UIModalPresentationStyle.fullScreen
    }
    set{
        self.modalPresentationStyle = newValue
    }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSafePlaceMarkerInGMSMap(for: safePlace.coordinate)
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    override func loadView() {
        super.loadView()
        initBottomView()
        initTopView()
        initGMSMapView()
    }
    
    func initTopView()
    {
        let topView = UIView(frame: CGRect.zero)
        topView.backgroundColor = UIColor.SECONDARY_COLOR
        
        view.addSubview(topView)
        view.bringSubview(toFront: topView)
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.topView = topView
        
        initTopViewSubViews()
    }
    
    func initTopViewSubViews()
    {
        let timeLabel = UILabel(frame: CGRect.zero)
        let closeButton = UIButton(frame: CGRect.zero)
        
        topView?.addSubview(timeLabel)
         topView?.addSubview(closeButton)
        
        timeLabel.numberOfLines = 1
        timeLabel.minimumScaleFactor = 8;
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.text = "1:20"
        timeLabel.textColor = .white
        timeLabel.font = UIFont.DEFAULT_FONT.withSize(32)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.centerXAnchor.constraint(equalTo: topView!.centerXAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: topView!.bottomAnchor,constant: -8).isActive = true
        timeLabel.layoutIfNeeded()
        
        closeButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        closeButton.rightAnchor.constraint(equalTo: topView!.rightAnchor,constant: -8).isActive = true
        
        self.closeButton = closeButton
        self.timeLabel = timeLabel
    }
    
    @objc func close(_ sender:UIButton)
    {
        self.dismiss(animated: true)
    }
    
    func initBottomView()
    {
        let bottomView = UIView(frame: CGRect.zero)
        bottomView.backgroundColor = UIColor.SECONDARY_COLOR
        
        view.addSubview(bottomView)
        view.bringSubview(toFront: bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        bottomView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        bottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        bottomView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.bottomView = bottomView
        
        initBottomViewSubViews()
    }
    
    
    func initBottomViewSubViews()
    {
        let addressLabel:UILabel = UILabel(frame: CGRect.zero)
        
        let distanceButton:UIButton = UIButton(frame: CGRect.zero)
        self.addressLabel = addressLabel
        self.distanceButton = distanceButton
        
        bottomView?.addSubview(addressLabel)
        bottomView?.addSubview(distanceButton)
        
        distanceButton.titleLabel?.numberOfLines = 1
        distanceButton.layer.masksToBounds = false
        distanceButton.clipsToBounds = true
        distanceButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        distanceButton.titleLabel?.font = UIFont.DEFAULT_FONT.withSize(18)
        distanceButton.setTitleColor(.black, for: .normal)
        distanceButton.backgroundColor = .white
        distanceButton.isUserInteractionEnabled = false
        
        distanceButton.translatesAutoresizingMaskIntoConstraints = false
        
    distanceButton.addConstraint(NSLayoutConstraint(item: distanceButton, attribute: .height, relatedBy: .equal, toItem: distanceButton, attribute: .width, multiplier: 1, constant: 0))
        
        distanceButton.centerYAnchor.constraint(equalTo: bottomView!.centerYAnchor,constant: 0).isActive = true
        
        addressLabel.numberOfLines = 0
        addressLabel.minimumScaleFactor = 8;
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.textColor = .white
        addressLabel.font = UIFont.DEFAULT_FONT.withSize(20)
        
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addressLabel.centerYAnchor.constraint(equalTo: bottomView!.centerYAnchor, constant: 0).isActive = true
        
        if Settings.shared.direction == Direction.LTR
        {
            initLTRBottomViewSubViews()
        }
        else if Settings.shared.direction == Direction.RTL
        {
                        initRTLBottomViewSubViews()
        }
        
        bottomView?.layoutIfNeeded()
        
    }
    
    func initLTRBottomViewSubViews()
    {
        addressLabel!.textAlignment = .left
        
        addressLabel!.leftAnchor.constraint(equalTo: bottomView!.leftAnchor, constant: 16).isActive = true
        
        addressLabel!.rightAnchor.constraint(equalTo: distanceButton!.leftAnchor).isActive = true
        
        distanceButton!.rightAnchor.constraint(equalTo: bottomView!.rightAnchor, constant: -16).isActive = true
    }
    
    func             initRTLBottomViewSubViews()
    {
        
        addressLabel!.textAlignment = .right
       
        addressLabel!.rightAnchor.constraint(equalTo: bottomView!.rightAnchor, constant: -16).isActive = true
        
        addressLabel!.leftAnchor.constraint(equalTo: distanceButton!.rightAnchor,constant: 8).isActive = true
       
        
        distanceButton!.leftAnchor.constraint(equalTo: bottomView!.leftAnchor, constant: 16).isActive = true
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
        
        let mapInsets = UIEdgeInsets(top:0, left: 0.0, bottom: bottomView!.frame.height, right: 0)
        gmsMapView.padding = mapInsets
        
        self.gmsMapView = gmsMapView
    }
}

extension NavigateViewController:GMSMapViewDelegate
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
    
    func setSafePlaceMarkerInGMSMap(for coordinate:CLLocationCoordinate2D)
    {
        let safePlaceMarker:GMSMarker = GMSMarker(position: coordinate)
        safePlaceMarker.map = gmsMapView
    }
    
    func drawPolygon(from source:CLLocationCoordinate2D, to destination:CLLocationCoordinate2D)
    {
        gmsMapView?.clear()
        setGMSCircle(for: safePlace.coordinate)
        setSafePlaceMarkerInGMSMap(for: safePlace.coordinate)
        let path = GMSMutablePath()
        path.addLatitude(source.latitude, longitude: source.longitude)
        path.addLatitude(destination.latitude, longitude: destination.longitude)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 10.0
        polyline.map = gmsMapView
    }
    
    func setGMSCircle(for center:CLLocationCoordinate2D)
    {
        let gmsCircle = GMSCircle(position: center, radius: ConstsKey.CIRCULAR_ENTER_REGION_RADIUS)
        gmsCircle.fillColor = .red
        gmsCircle.strokeColor = .red
        gmsCircle.strokeWidth = 5
        gmsCircle.map = gmsMapView
    }
}

extension NavigateViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let coordinate = locations.last?.coordinate else { return }
        
        if isFirstTimeLocation {
            isFirstTimeLocation = !isFirstTimeLocation
            gmsMapView?.camera = GMSCameraPosition.camera(withTarget:coordinate , zoom: 15.8)
        }
        else if toFollow
        {
            let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: gmsMapView!.camera.zoom)
            gmsMapView?.animate(to: camera)
            gmsMapView?.camera = camera
        }
        drawPolygon(from: coordinate,to: safePlace.coordinate)
        setDistanceAndLocation(for: coordinate)
    }
    
    
    func setDistanceAndLocation(for source:CLLocationCoordinate2D)
    {
        let distance = Int(GMSGeometryDistance(source, safePlace.coordinate))
        distanceStr = "\(distance)"
        if(distance <= 5)
        {
            //TODO: user arrived to safeplace logic
        }
        iAlertGeoCoder(coordinate: source, GMSLanguageCode: Settings.shared.GMSLanguageId).reverseGeocodeCoordinate {
           [weak self] place in
            guard let place = place else {return}
            let desc = "\(place)"
            guard desc != "" else{return}
            DispatchQueue.main.sync {
                self?.addressLabel?.text = desc
            }
            
        }
    }
    
    func getUnitCharInCurrentLanguage()
    {
    }
}

extension CLCircularRegion
{
    static func createEnterCLCircularRegion(for center:CLLocationCoordinate2D)->CLCircularRegion
    {
        let circularRegion = CLCircularRegion(center: center, radius: ConstsKey.CIRCULAR_ENTER_REGION_RADIUS, identifier: ConstsKey.CIRCULAR_ENTER_REGION_ID)
        circularRegion.notifyOnEntry = true
        return circularRegion
    }
}
