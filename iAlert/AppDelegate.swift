
import UIKit
import UserNotifications
import CoreLocation
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    static let geoCoder = CLGeocoder()
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
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
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
        
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
    
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let token = UserDefaults.standard.string(forKey: "token")
        {
            if token != fcmToken
            {
                UserDefaults.standard.set(fcmToken, forKey: "token")
                print("not the same token!!")
                iAlertService.shared.fetch(type: .Register(uniqueId: fcmToken, prevId: token)){
                    data,err in
                    print("in data!!! \(data)")
                    print("in err!!! \(err)")
                }
            }
            else
            {
                print("same tokens!!!!")
            }
        }
        else
        {
            print("upload new Token!!")
            UserDefaults.standard.set(fcmToken, forKey: "token")
            iAlertService.shared.fetch(type: .Register(uniqueId: fcmToken, prevId: nil)){
                data,err in
                print("in data!!! \(data)")
                print("in err!!! \(err)")
            }
        }
        print("Firebase registration token: \(fcmToken)")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func newLocationReceived( location: CLLocation,city: String, description: String) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {return}
        
        iAlertService.shared.fetch(type: .Update(latitude:location.coordinate.latitude, langitude: location.coordinate.longitude, city: city, uniqueId: token, language: "english")){
            data,err in
            if  data != nil && err == nil
            {
                let content = UNMutableNotificationContent()
                content.title = "New location sent to server"
                content.body = "\(description) in coords \(location)"
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
                
                self.center.add(request, withCompletionHandler: nil)
            }
            else
            {
                let content = UNMutableNotificationContent()
                content.title = "New location couldnt be sent to server"
                content.body = "\(description) in coords \(location)"
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
                
                self.center.add(request, withCompletionHandler: nil)
            }
            print("in data!!! \(data)")
            print("in err!!! \(err)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        AppDelegate.geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                if let city = place.locality
                {
                    let description = "New Location: \(place)"
                    self.newLocationReceived(location: location,city: city, description: description)
                }
            }
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        checkNotification(with: notification.request.content.userInfo)
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        checkNotification(with: response.notification.request.content.userInfo)
        completionHandler()
    }
}




