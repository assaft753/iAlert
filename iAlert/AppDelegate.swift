
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
        window?.rootViewController = ContainerViewController()
        
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


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will!!!")
        let userInfo = notification.request.content.userInfo
        if let dic = userInfo as? [String:Any],
            let redAlertIdStr = dic["redAlertId"] as? String,
            let redAlertId = Int(redAlertIdStr),
            let containerVC = self.window?.rootViewController as? ContainerViewController
        {
            containerVC.askUserForWishingNavigation(alertId: redAlertId)
        }
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("did!!!")
        let userInfo = response.notification.request.content.userInfo
        if let dic = userInfo as? [String:Any],
            let redAlertIdStr = dic["redAlertId"] as? String,
            let redAlertId = Int(redAlertIdStr),
            let containerVC = self.window?.rootViewController as? ContainerViewController
        {
            containerVC.remoteNavigationToSafePlace(redAlertId: redAlertId)
        }
        completionHandler()
    }
}






