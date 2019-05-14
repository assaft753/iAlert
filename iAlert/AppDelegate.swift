
import UIKit
import UserNotifications
import CoreLocation
import Firebase
import CoreData
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var isDid:Bool?
    let locationManager = CLLocationManager()
    let center = UNUserNotificationCenter.current()
    var locker:NSObject? = nil
    //let TO_LOCK_KEY = "lock"
    
    static let geoCoder = CLGeocoder()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self as MessagingDelegate
        locationManager.delegate = self
        GMSServices.provideAPIKey(GMSServices.GMS_MAPS_API_KEY)
        
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
        locationManager.startMonitoringSignificantLocationChanges()
        //TODO: check if launch happend because of a loaction update
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController =  /*NavigateViewController()*/ContainerViewController() //TODO: change it back to ContainerViewController
        
        return true
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        locker = NSObject()
    }
    
    
    func sendLocalNotificationWith(title:String?,body:String?)
    {
        let content = UNMutableNotificationContent()
        
        if let title = title
        {
            content.title = title
        }
        else
        {
            content.title = ""
        }
        
        if let body = body
        {
            content.body = body
        }
        else
        {
            content.body = ""
        }
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        self.center.add(request, withCompletionHandler: nil)
    }
    
}

/*extension AppDelegate: CLLocationManagerDelegate {
    
    func newLocationReceived( location: CLLocation,city: String, description: String) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {return}
        iAlertService.shared.fetch(type: .AllClosestsShelters(uniqueId: token, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)){
            data,err,response in
            guard let httpResponse = response as? HTTPURLResponse else {return}
            if httpResponse.statusCode < 400,let data = data, let dicJson = try? JSONSerialization.jsonObject(with: data, options: []),let element = dicJson as? [String:Any],let result = element["result"] as? [[String:Any]]{
                DispatchQueue.main.async {
                    iAlertService.shared.removeAllShelters()
                    iAlertService.shared.saveShelters(shelters: result)
                    if let shelters = iAlertService.shared.loadShelters()
                    {
                        print("final!!!!!!!!!!!!!!!!!!!!!! \(shelters)")
                    }
                }
            }
        }
        
        iAlertService.shared.fetch(type: .Update(latitude:location.coordinate.latitude, langitude: location.coordinate.longitude, city: city, uniqueId: token, language: "english")){
            data,err,response in
            if let httpResponse = response as? HTTPURLResponse
            {
                let title:String = "status code \(httpResponse.statusCode)"
                var body:String = ""
                if let data = data
                {
                    body = "with data: \(String(data: data, encoding: .utf8)!)"
                }
                else if let error = err
                {
                    body = "with error: \(error)"
                }
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = "\(description) with body \(body)"
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
                self.center.add(request, withCompletionHandler: nil)
            }
            
            if let data = data
            {
                print("in data!!! \(String.init(data: data, encoding: String.Encoding.utf8))")
            }
            print("in err!!! \(err)")
            print("in response!!! \(response as? HTTPURLResponse)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "location recv"
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        self.center.add(request, withCompletionHandler: nil)
        
        AppDelegate.geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            
            let content = UNMutableNotificationContent()
            content.title = "location geocoder"
            content.sound = UNNotificationSound.default()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
            self.center.add(request, withCompletionHandler: nil)
            
            if let place = placemarks?.first {
                
                let content = UNMutableNotificationContent()
                content.title = "\(place)"
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
                self.center.add(request, withCompletionHandler: nil)
                
                if let city = place.locality
                {
                    let description = "New Location: \(place)"
                    self.newLocationReceived(location: location, city: city, description: description)
                }
            }
        }
    }
}*/


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    private func convertAlertIdToInt(for userInfo: [AnyHashable : Any]) -> Int?
    {
        if let dic = userInfo as? [String:Any], let redAlertIdStr = dic["redAlertId"] as? String, let redAlertId = Int(redAlertIdStr)
        {
            return redAlertId
        }
        return nil
    }
    
    private func convertTimeToInt(for userInfo: [AnyHashable : Any]) -> Int?
    {
        if let dic = userInfo as? [String:Any], let timeStr = dic["max_time_to_arrive_to_shelter"] as? String, let time = Int(timeStr)
        {
            return time
        }
        return nil
    }
    
    private func checkNotification(with redAlertId:Int, time:Int,isWillPresent:Bool)
    {
        /*if let navCtrl = self.window?.rootViewController as? UINavigationController,let loadingViewCtrl = navCtrl.topViewController as? LoadingViewController
        {
            let safePlace = SafePlace(redAlertId: redAlertId,time: time)
            loadingViewCtrl.safePlace = safePlace
            if isWillPresent == false
            {
                loadingViewCtrl.isWillPresent = false
                if loadingViewCtrl.afterWillAppear == true
                {
                    loadingViewCtrl.startProcessingLocationNavigation(isLocalShelter: false)
                    loadingViewCtrl.isWillPresent = nil
                }
            }
            else if isWillPresent == true
            {
                loadingViewCtrl.startProcessingLocationNavigation(isLocalShelter: false)
                loadingViewCtrl.isWillPresent = true
            }
        }*/
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will!!!")
        print(print(notification.request.content.userInfo))
        print(self.window?.rootViewController)
        print(self.window?.rootViewController as? ContainerViewController)
        let userInfo = notification.request.content.userInfo
        if let dic = userInfo as? [String:Any],
            let timeStr = dic["max_time_to_arrive_to_shelter"] as? String,
            let time = Int(timeStr),
            let redAlertIdStr = dic["redAlertId"] as? String,
            let redAlertId = Int(redAlertIdStr),
            let containerVC = self.window?.rootViewController as? ContainerViewController
        {
            containerVC.askUserForWishingNavigation(alertId: redAlertId, time: time)
        }
        /*if let redAlertId = convertAlertIdToInt(for: notification.request.content.userInfo),let time = convertTimeToInt(for: notification.request.content.userInfo)
        {
            checkNotification(with: redAlertId, time: time, isWillPresent: true)
        }*/
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("did!!!")
        print(response.notification.request.content.userInfo)
        print(self.window?.rootViewController)
        print(self.window?.rootViewController as? ContainerViewController)
        /*if let redAlertId = convertAlertIdToInt(for: response.notification.request.content.userInfo),let time = convertTimeToInt(for: response.notification.request.content.userInfo)
        {
            checkNotification(with: redAlertId, time: time, isWillPresent: false)
        }*/
        completionHandler()
    }
}






