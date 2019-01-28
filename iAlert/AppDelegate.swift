
import UIKit
import UserNotifications
import CoreLocation
import Firebase
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    static let geoCoder = CLGeocoder()
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Shelter")
        do{
            let items = try context.fetch(fetchRequest)
            items.forEach{print($0.value(forKey: "address"))}
        }
        catch let err{
            print(err)
        }
        /*let entity = NSEntityDescription.entity(forEntityName: "Shelter", in: context)
         var shelter = NSManagedObject(entity: entity!, insertInto: context)
         shelter.setValue(34.5, forKeyPath: "latitude")
         shelter.setValue("aasdsd", forKeyPath: "address")
         shelter.setValue(32, forKeyPath: "longitude")
         
         do {
         try context.save()
         }
         catch {
         print("Failed saving")
         }*/
        
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
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                print(error)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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
                iAlertService.shared.fetch(type: .Register(uniqueId: fcmToken, prevId: token))
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
            iAlertService.shared.fetch(type: .Register(uniqueId: fcmToken, prevId: nil))
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
        iAlertService.shared.fetch(type: .AllClosestsShelters(uniqueId: token, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)){
            data,err,response in
            guard let httpResponse = response as? HTTPURLResponse else {return}
            if httpResponse.statusCode < 400,let data = data, let dicJson = try? JSONSerialization.jsonObject(with: data, options: []),let element = dicJson as? [String:Any],let result = element["result"] as? [[String:Any]]{
                iAlertService.shared.removeAllShelters()
                iAlertService.shared.saveShelters(shelters: result)
                if let shelters = iAlertService.shared.loadShelters()
                {
                    print("final!!!!!!!!!!!!!!!!!!!!!! \(shelters)")
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
}

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
    
    private func checkNotification(with redAlertId:Int, time:Int)
    {
        if let navCtrl = self.window?.rootViewController as? UINavigationController,let loadingViewCtrl = navCtrl.topViewController as? LoadingViewController
        {
            let safePlace = SafePlace(redAlertId: redAlertId,time: time)
            //set safe place at loadingViewCtrl
            loadingViewCtrl.safePlace = safePlace
            loadingViewCtrl.takeCurrentLocation()
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let l = notification.request.content.userInfo
        print(l)
        if let redAlertId = convertAlertIdToInt(for: notification.request.content.userInfo),let time = convertTimeToInt(for: notification.request.content.userInfo)
        {
            checkNotification(with: redAlertId,time: time)
        }
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let redAlertId = convertAlertIdToInt(for: response.notification.request.content.userInfo),let time = convertTimeToInt(for: response.notification.request.content.userInfo)
        {
            checkNotification(with: redAlertId,time: time)
        }
        completionHandler()
    }
}






