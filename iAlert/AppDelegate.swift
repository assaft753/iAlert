//
//  AppDelegate.swift
//  TurnByTurn2
//
//  Created by Sapir Kaplan on 10/07/2018.
//  Copyright © 2018 Sapir Kaplan. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        locationManager.requestAlwaysAuthorization()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
        }
            
        else
        {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        return true
    }
    
    private func calculate()
    {
        let loc1 = CLLocation(latitude: 31.784229, longitude: 34.6346413)
        let loc2 = CLLocation(latitude: 31.790746, longitude: 34.6394848)
        print("\(loc1.distance(from: loc2)) meters")
        // print(distance(lat1:Double(31.784229), lon1: Double(34.6346413), lat2: Double(31.7853747), lon2: Double(34.63619440000002), unit: "K"), "Kilometers")
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let navCtrl = self.window?.rootViewController as? UINavigationController,let loadingViewCtrl = navCtrl.topViewController as? LoadingViewController
        {
            if let jsonString = notification.request.content.userInfo["coords"] as? String,let safePlaces = SafePlace.parseSafePlaces(from: jsonString)
            {
                loadingViewCtrl.calculateAndPush(safePlaces: safePlaces)
            }
            
        }
        completionHandler([])
        print("finish will")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        /*if let navCtrl = window?.rootViewController as? UINavigationController,let id = navCtrl.childViewControllers[navCtrl.childViewControllers.count-1].restorationIdentifier,id == "first"
         {
         let viewCtrl = navCtrl.childViewControllers[navCtrl.childViewControllers.count-1] as! FirstViewController
         viewCtrl.changeToPush(true)
         }*/
        completionHandler()
        print("finish did")
    }
}




