# MTPush Swift Demo

Offically supported Swift Demo for EngageLab MTPush iOS SDK. 

## MTPush SDK SetUp

#### Manual

* Select "Add files to 'Your project name'..." in Xcode and add the decompressed lib subfolder (containing mtpush-ios-x.x.x.xcframework) to your project directory.

* add Framework 
  ○ CFNetwork.framework
  ○ CoreFoundation.framework
  ○ CoreTelephony.framework
  ○ SystemConfiguration.framework
  ○ CoreGraphics.framework
  ○ Foundation.framework
  ○ UIKit.framework
  ○ Security.framework
  ○ libz.tbd
  ○ UserNotifications.framework
  ○ libresolv.tbd
  ○ libsqlite3.tbd
  

##### Build Settings

* Set the `User Header Search Paths` and `Library Search Paths` under `Search Paths`. For example, if the SDK folder (default is lib) and the project file are in the same directory, set them to "$(SRCROOT)/{name of the folder where the static library is located} ".

##### Capabilities

If you are developing using Xcode 8 or above environment, please turn on the `Capabilities->Push Notifications ` option of Application Target.

If you are developing using Xcode 10 or above environment, please turn on the `Capabilities->Access WIFI Infomation` option of Application Target.


#### Cocoapods 导入

```
pod 'MTPush'
```

* If you need to install a specific version, use the following method (taking MTPush 4.4.0 version as an example):

```
pod 'MTPush', '4.4.0'
```


#### Create a new Objective-C `Bridging Header file` in the project


#### Import the mtpush header file into the newly generated Objective-C `Bridging Header file`

```
#import "MTPushService.h"
```

#### Add the following code in the didFinishLaunching method of the Appdelegate.swift file


```
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
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
         
        } else {
        }
    
        MTPushService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        // init
        MTPushService.setup(withOption: launchOptions, appKey: appKey, channel: channel, apsForProduction: isProduction)
    
    return true
  }
```

#### Add the following code in the didRegisterForRemoteNotificationsWithDeviceToken method of the Appdelegate.swift file


```
  func application(application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
      print("get the deviceToken  \(deviceToken)")
    MTPushService.registerDeviceToken(deviceToken)
      
  }
```

#### Added callback method for handling APNs notifications

Implement the callback method in Appdelegate.swift and add the code in the callback method

```
func mtpNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
                
        if ((notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self)) != nil) {
            MTPushService.handleRemoteNotification(userInfo)
                    }
        completionHandler(NSInteger(UNNotificationPresentationOptions.alert.rawValue) |
                          NSInteger(UNNotificationPresentationOptions.sound.rawValue) |
                          NSInteger(UNNotificationPresentationOptions.badge.rawValue) )
    }
    
    @available(iOS 10.0, *)
    func mtpNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
                
        if ((response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self)) != nil) {
            MTPushService.handleRemoteNotification(userInfo)
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
    
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        MTPushService.handleRemoteNotification(userInfo)
        print("iOS6 and below systems, notification received:\(userInfo)")
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        MTPushService.handleRemoteNotification(userInfo)
        print("iOS7 and above systems, notification received:\(userInfo)")
        completionHandler(.newData)
    }
    
```

#### Run successfully

Debug the project on a real machine. If the console outputs the following log, it means that you have successfully integrated.

```
2021-08-19 17:12:12.745823 219b28[1443:286814] | MTP | I - [MTCORETcpEventController] 
----- login result -----
uid:123456 
registrationID:171976fa8a8620a14a4 
idc:0
```

At this point, the basic functions of integrating MTPush sdk have been completed. If you need more functions, please refer to the Demo project.


