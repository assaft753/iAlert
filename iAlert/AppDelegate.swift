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
        sendPostRequest(sent: "finish launch")
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
    
    private func checkNotification(with userInfo:[AnyHashable:Any])
    {
        if let navCtrl = self.window?.rootViewController as? UINavigationController,let loadingViewCtrl = navCtrl.topViewController as? LoadingViewController
        {
            if let jsonString = userInfo["coords"] as? String,let safePlaces = SafePlace.parseSafePlaces(from: jsonString)
            {
                loadingViewCtrl.calculateAndPush(safePlaces: safePlaces)
            }
            
        }
    }
    
    
    private func sendPostRequest(sent from:String)
    {
        let url = URL(string: "http://192.168.1.105:3001/")!
        var request = URLRequest(url: url)
        request.httpMethod="POST"
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        let encoder = JSONEncoder()
        do {
            let dic:[String:String] = ["method":from]
            let jsonData = try encoder.encode(dic)
            request.httpBody = jsonData
        } catch {
            print("error in json \(error)")
        }
        
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            if let error = responseError
            {
                print("error in session \(error)")
            }
            
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
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
        checkNotification(with: notification.request.content.userInfo)
        completionHandler([])
        print("finish will")
        sendPostRequest(sent: "finish will")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        checkNotification(with: response.notification.request.content.userInfo)
        completionHandler()
        print("finish did")
        sendPostRequest(sent: "finish did")
    }
}




