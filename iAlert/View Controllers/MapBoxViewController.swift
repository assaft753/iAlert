//
//  MapBoxViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 05/02/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

class MapBoxViewController: UIViewController {
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var panel: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet var container: UIView!
    
    var route: Route?
    var currentCoordinate: CLLocationCoordinate2D!
    var safePlace:SafePlace!
    var isRedAlertId:Bool!
    var timer:Timer!
    var countDown:Int?
    var language:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneBtn.setTitle("done".localized, for: .normal)
        self.countDown = safePlace.time
        panel.isHidden = true
        self.language = UserDefaults.standard.string(forKey: ConstsKey.PREFFERED_LANGUAGE)
        let origin = Waypoint(coordinate: /*CLLocationCoordinate2D(latitude: 31.784159, longitude: 34.634969)*/currentCoordinate)
        let destination = Waypoint(coordinate:/* CLLocationCoordinate2D(latitude: 31.785882, longitude: 34.633005)*/safePlace.coordinate)
        
        let options = NavigationRouteOptions(waypoints: [origin, destination],profileIdentifier: MBDirectionsProfileIdentifier.walking)
        
        
        options.locale = Locale(identifier: self.language)
        options.distanceMeasurementSystem = .metric
        Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first else { return }
            self.route = route
            self.startEmbeddedNavigation()
            
        }
        
    }
    
    @objc func countDownAction(){
        countDown! -= 1
        timeLeftLabel.text = "\(countDown!)"
        if countDown == 0 {
            timer.invalidate()
        }
    }
    @IBAction func buttonAction(_ sender: Any) {
    self.navigationController?.popToRootViewController(animated: true)
    }
    
    func startEmbeddedNavigation() {
        guard let route = route else { return }
        let navigationService = MapboxNavigationService(route: route, simulating:.always)
        let nav = NavigationViewController(for: route, styles: [CustomDayStyle(), CustomNightStyle()], navigationService: navigationService)
        nav.mapView?.delegate = self
        nav.delegate = self
        addChildViewController(nav)
        panel.isHidden = false
        container.addSubview(nav.view)
        nav.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nav.view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            nav.view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            nav.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            nav.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
            ])
        self.didMove(toParentViewController: self)
        
        if isRedAlertId
        {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDownAction), userInfo: nil, repeats: true)
        }
        else
        {
            self.timeLeftLabel.isHidden = true
        }
    }
    
}

class CustomDayStyle: DayStyle {
    
    private let backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.337254902, blue: 0.3019607843, alpha: 1)
    private let darkBackgroundColor = #colorLiteral(red: 0.9803921569, green: 0.337254902, blue: 0.3019607843, alpha: 1)
    private let secondaryBackgroundColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
    private let blueColor = #colorLiteral(red: 0.26683864, green: 0.5903761983, blue: 1, alpha: 1)
    private let lightGrayColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    private let darkGrayColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    private let primaryLabelColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private let secondaryLabelColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9)
    
    required init() {
        super.init()
        styleType = .day
    }
    
    override func apply() {
        super.apply()
        ArrivalTimeLabel.appearance().isHidden = true
        //BottomBannerView.appearance().backgroundColor = secondaryBackgroundColor
        //BottomBannerContentView.appearance().backgroundColor = secondaryBackgroundColor
        BottomBannerView.appearance().isHidden = true
        BottomBannerContentView.appearance().isHidden = true
        Button.appearance().textColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        Button.appearance().isHidden = true
        CancelButton.appearance().tintColor = lightGrayColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).unitTextColor = secondaryLabelColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).valueTextColor = primaryLabelColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).unitTextColor = lightGrayColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).valueTextColor = darkGrayColor
        DistanceRemainingLabel.appearance().textColor = lightGrayColor
        DismissButton.appearance().textColor = darkGrayColor
        FloatingButton.appearance().backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        FloatingButton.appearance().tintColor = blueColor
        InstructionsBannerView.appearance().backgroundColor = backgroundColor
        InstructionsBannerContentView.appearance().backgroundColor = backgroundColor
        LanesView.appearance().backgroundColor = darkBackgroundColor
        LaneView.appearance().primaryColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        ManeuverView.appearance().backgroundColor = backgroundColor
        ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).primaryColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).secondaryColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).primaryColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).secondaryColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).primaryColor = darkGrayColor
        ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).secondaryColor = lightGrayColor
        MarkerView.appearance().pinColor = blueColor
        NextBannerView.appearance().backgroundColor = backgroundColor
        NextInstructionLabel.appearance().textColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        NavigationMapView.appearance().tintColor = blueColor
        NavigationMapView.appearance().routeCasingColor = #colorLiteral(red: 0.1968861222, green: 0.4148176908, blue: 0.8596113324, alpha: 1)
        NavigationMapView.appearance().trafficHeavyColor = #colorLiteral(red: 0.9995597005, green: 0, blue: 0, alpha: 1)
        NavigationMapView.appearance().trafficLowColor = blueColor
        NavigationMapView.appearance().trafficModerateColor = #colorLiteral(red: 1, green: 0.6184511781, blue: 0, alpha: 1)
        NavigationMapView.appearance().trafficSevereColor = #colorLiteral(red: 0.7458544374, green: 0.0006075350102, blue: 0, alpha: 1)
        NavigationMapView.appearance().trafficUnknownColor = blueColor
        PrimaryLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = primaryLabelColor
        PrimaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = darkGrayColor
        ResumeButton.appearance().backgroundColor = secondaryBackgroundColor
        ResumeButton.appearance().tintColor = blueColor
        SecondaryLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = secondaryLabelColor
        SecondaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = darkGrayColor
        TimeRemainingLabel.appearance().isHidden = true
        //TimeRemainingLabel.appearance().trafficLowColor = darkBackgroundColor
        //TimeRemainingLabel.appearance().trafficUnknownColor = darkGrayColor
        WayNameLabel.appearance().normalTextColor = blueColor
        WayNameView.appearance().backgroundColor = secondaryBackgroundColor
    }
}

class CustomNightStyle: NightStyle {
    
    private let backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.337254902, blue: 0.3019607843, alpha: 1)
    private let darkBackgroundColor = #colorLiteral(red: 0.9803921569, green: 0.337254902, blue: 0.3019607843, alpha: 1)
    private let secondaryBackgroundColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
    private let blueColor = #colorLiteral(red: 0.26683864, green: 0.5903761983, blue: 1, alpha: 1)
    private let lightGrayColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    private let darkGrayColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    private let primaryLabelColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private let secondaryLabelColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9)
    
    required init() {
        super.init()
        styleType = .night
    }
    
    override func apply() {
        super.apply()
        ArrivalTimeLabel.appearance().isHidden = true
       // BottomBannerView.appearance().backgroundColor = secondaryBackgroundColor
        //BottomBannerContentView.appearance().backgroundColor = secondaryBackgroundColor
        BottomBannerView.appearance().isHidden = true
        BottomBannerContentView.appearance().isHidden = true
        Button.appearance().textColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        Button.appearance().isHidden = true
        CancelButton.appearance().tintColor = lightGrayColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).unitTextColor = secondaryLabelColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).valueTextColor = primaryLabelColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).unitTextColor = lightGrayColor
        DistanceLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).valueTextColor = darkGrayColor
        DistanceRemainingLabel.appearance().textColor = lightGrayColor
        DismissButton.appearance().textColor = darkGrayColor
        FloatingButton.appearance().backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        FloatingButton.appearance().tintColor = blueColor
        InstructionsBannerView.appearance().backgroundColor = backgroundColor
        InstructionsBannerContentView.appearance().backgroundColor = backgroundColor
        LanesView.appearance().backgroundColor = darkBackgroundColor
        LaneView.appearance().primaryColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        ManeuverView.appearance().backgroundColor = backgroundColor
        ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).primaryColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).secondaryColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).primaryColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).secondaryColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).primaryColor = darkGrayColor
        ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).secondaryColor = lightGrayColor
        MarkerView.appearance().pinColor = blueColor
        NextBannerView.appearance().backgroundColor = backgroundColor
        NextInstructionLabel.appearance().textColor = #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        NavigationMapView.appearance().tintColor = blueColor
        NavigationMapView.appearance().routeCasingColor = #colorLiteral(red: 0.1968861222, green: 0.4148176908, blue: 0.8596113324, alpha: 1)
        NavigationMapView.appearance().trafficHeavyColor = #colorLiteral(red: 0.9995597005, green: 0, blue: 0, alpha: 1)
        NavigationMapView.appearance().trafficLowColor = blueColor
        NavigationMapView.appearance().trafficModerateColor = #colorLiteral(red: 1, green: 0.6184511781, blue: 0, alpha: 1)
        NavigationMapView.appearance().trafficSevereColor = #colorLiteral(red: 0.7458544374, green: 0.0006075350102, blue: 0, alpha: 1)
        NavigationMapView.appearance().trafficUnknownColor = blueColor
        PrimaryLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = primaryLabelColor
        PrimaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = darkGrayColor
        ResumeButton.appearance().backgroundColor = secondaryBackgroundColor
        ResumeButton.appearance().tintColor = blueColor
        SecondaryLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = secondaryLabelColor
        SecondaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = darkGrayColor
        TimeRemainingLabel.appearance().isHidden = true
        //TimeRemainingLabel.appearance().trafficLowColor = darkBackgroundColor
        //TimeRemainingLabel.appearance().trafficUnknownColor = darkGrayColor
        WayNameLabel.appearance().normalTextColor = blueColor
        WayNameView.appearance().backgroundColor = secondaryBackgroundColor
    }
}


extension MapBoxViewController:NavigationViewControllerDelegate,MGLMapViewDelegate
{
    func navigationViewController(_ navigationViewController: NavigationViewController, shouldRerouteFrom location: CLLocation) -> Bool {
        return false
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        if let fcmToken = UserDefaults.standard.string(forKey: "token"),isRedAlertId
        {
            print("fetch arrive")
            iAlertService.shared.fetch(type: .Arrive(redAlertId: safePlace.redAlertId, uniqueId: fcmToken))
        }
        return false;
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        style.localizeLabels(into: Locale(identifier: self.language))
    }
}
