//
//  AppDelegate.swift
//  MTPushSwiftDemo
//
//  Created by huangshuni on 2022/11/30.
//

import UIKit
import UserNotifications

let appKey = "c571017eb5459d84170c8bf0"
let channel = "Publish channel"
let isProduction = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MTPushRegisterDelegate {
    
    var window: UIWindow?
    
    var rootViewController: RootViewController?

    @IBOutlet var rootController: UITabBarController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //init push
        setupPush(launchOptions)
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        Bundle.main.loadNibNamed("MTPushTabBarViewController", owner: self)
        window?.rootViewController = self.rootController
        window?.makeKeyAndVisible()
        self.rootViewController = self.rootController.viewControllers?[0] as! RootViewController
        
        return true
    }
    
    
    func setupPush(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        let entity = MTPushRegisterEntity()
        if #available(iOS 12.0, *) {
            
            let types = MTPushAuthorizationOptions(rawValue: (MTPushAuthorizationOptions.alert.rawValue |
                                                              MTPushAuthorizationOptions.sound.rawValue |
                                                              MTPushAuthorizationOptions.badge.rawValue |
                                                              MTPushAuthorizationOptions.providesAppNotificationSettings.rawValue))
            
            entity.types = Int(types.rawValue)

        } else {
            let types = MTPushAuthorizationOptions(rawValue: (MTPushAuthorizationOptions.alert.rawValue |
                                                              MTPushAuthorizationOptions.sound.rawValue |
                                                              MTPushAuthorizationOptions.badge.rawValue
                                                              ))
            entity.types = Int(types.rawValue)
        }
        
        if #available(iOS 10.0, *) {
          // 可以自定义 categories
        } else {
        }
    
        MTPushService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        // init
        MTPushService.setup(withOption: launchOptions, appKey: appKey, channel: channel, apsForProduction: isProduction)
        
        // get registrationID
        MTPushService.registrationIDCompletionHandler { resCode, registrationID in
            if (resCode == 0) {
                print("registrationID get success",registrationID ?? "")
            }else {
                print("registrationID get error")
            }
        }
        
        // 检测通知授权情况。可选项，不一定要放在此处，可以运行一定时间后再调用
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            MTPushService.requestNotificationAuthorization { status in
                print("notification authorization status:\(status)")
                self.alertNotificationAuthorization(status)
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        MTPushService.handleRemoteNotification(userInfo)
        print("iOS6及以下系统，收到通知:\(userInfo)")
        rootViewController?.addNotificationCount()
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        MTPushService.handleRemoteNotification(userInfo)
        print("iOS7及以上系统，收到通知:\(userInfo)")
        if (Float(UIDevice.current.systemVersion)! < 10.0 || application.applicationState.rawValue > 0){
            rootViewController?.addNotificationCount()
        }
        completionHandler(.newData)
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 向SDK注册DeviceToken
        MTPushService.registerDeviceToken(deviceToken)
        
        self.rootViewController?.deviceTokenValueLabel.text = "\(deviceToken)"
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did Fail To Register For Remote Notifications With Error: ", error);
    }
    
    
    // MTPushRegisterDelegate
    @available(iOS 10.0, *)
    func mtpNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo
        let request = notification.request
        let content = request.content
        
        let badge = content.badge
        let body = content.body
        let sound = content.sound
        let subtitle = content.subtitle
        let title = content.title
        
        if ((notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self)) != nil) {
            MTPushService.handleRemoteNotification(userInfo)
            print("iOS10 receive remote notification:\(userInfo)")
            
            rootViewController?.addNotificationCount()
        }else {
            print("iOS10 receive local notification:{\nbody:\(body)，\ntitle:\(title)，\nsubtitle:\(subtitle), \nbadge：\(badge ?? 0)，\nsound：\(String(describing: sound))，\nuserInfo：\(userInfo)\n}")
        }
        completionHandler(NSInteger(UNNotificationPresentationOptions.alert.rawValue) |
                          NSInteger(UNNotificationPresentationOptions.sound.rawValue) |
                          NSInteger(UNNotificationPresentationOptions.badge.rawValue) )
    }
    
    @available(iOS 10.0, *)
    func mtpNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        let request = response.notification.request
        let content = request.content
        
        let badge = content.badge
        let body = content.body
        let sound = content.sound
        let subtitle = content.subtitle
        let title = content.title
        
        if ((response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self)) != nil) {
            MTPushService.handleRemoteNotification(userInfo)
            print("iOS10 click remote notification:\(userInfo)")
            
            rootViewController?.addNotificationCount()
        }else {
            print("iOS10 click local notification:{\nbody:\(body)，\ntitle:\(title)，\nsubtitle:\(subtitle), \nbadge：\(String(describing: badge))，\nsound：\(String(describing: sound))，\nuserInfo：\(userInfo)\n}")
        }
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    func mtpNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
    }
    
    func mtpNotificationAuthorization(_ status: MTPushAuthorizationStatus, withInfo info: [AnyHashable : Any]!) {
        print("receive notification authorization status:\(status), info:\(String(describing: info))")
       alertNotificationAuthorization(status)
    }
    
    func alertNotificationAuthorization(_ status: MTPushAuthorizationStatus) {
        if (status == .statusDenied || status == .notDetermined) {
            DispatchQueue.main.async {
                let alert = UIAlertView(title: "允许通知", message: "是否进入设置允许通知?", delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
                alert.show()
            }
        }
    }

}

