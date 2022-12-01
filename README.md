# MTPush Swift Demo

Offically supported Swift Demo for EngageLab MTPush iOS SDK. 

## MTPush SDK 集成步骤

#### 手动导入

* 在 Xcode 中选择 “Add files to 'Your project name'...”，将解压后的 lib 子文件夹（包含  MTPushService.h,、mtpush-ios-x.x.x.a ）添加到你的工程目录中。

* 添加 Framework 
  ○ CFNetwork.framework
  ○ CoreFoundation.framework
  ○ CoreTelephony.framework
  ○ SystemConfiguration.framework
  ○ CoreGraphics.framework
  ○ Foundation.framework
  ○ UIKit.framework
  ○ Security.framework
  ○ libz.tbd（Xcode 7 以下版本是 libz.dylib）
  ○ UserNotifications.framework（Xcode 8 及以上）
  ○ libresolv.tbd（Xcode 7 以下版本是 libresolv.dylib）
  ○ libsqlite3.tbd
  

##### Build Settings

如果你的工程需要支持小于 7.0 的 iOS 系统，请到 Build Settings 关闭 bitCode 选项，否则将无法正常编译通过。

* 设置 Search Paths 下的 User Header Search Paths 和 Library Search Paths，比如 SDK 文件夹（默认为 lib ）与工程文件在同一级目录下，则都设置为 "$(SRCROOT)/{静态库所在文件夹名称}" 即可。

##### Capabilities

如使用 Xcode 8 及以上环境开发，请开启 Application Target 的 Capabilities->Push Notifications 选项。

如使用 Xcode 10 及以上环境开发，请开启 Application Target 的 Capabilities-> Access WIFI Infomation 选项。 


#### Cocoapods 导入

```
pod 'MTPush'
```

* 如果需要安装指定版本则使用以下方式（以 MTPush 3.0.0 版本为例）：

```
pod 'MTPush', '3.0.0'
```


#### 在工程中新建一个 Objective-C Bridging Header 文件


#### 在刚生成的Objective-C Bridging Header文件中导入 mtpush 头文件

```
#import "MTPushService.h"
```

#### 在Appdelegate.swift 文件的 didFinishLaunching 方法中添加如下代码


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
          // 可以自定义 categories
        } else {
        }
    
        MTPushService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        // init
        MTPushService.setup(withOption: launchOptions, appKey: appKey, channel: channel, apsForProduction: isProduction)
    
    return true
  }
```

#### 在Appdelegate.swift 文件的 didRegisterForRemoteNotificationsWithDeviceToken 方法中添加如下代码


```
  func application(application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
      print("get the deviceToken  \(deviceToken)")
    MTPushService.registerDeviceToken(deviceToken)
      
  }
```

#### 添加处理 APNs 通知回调方法

在Appdelegate.swift 实现该回调方法并添加回调方法中的代码

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
        print("iOS6及以下系统，收到通知:\(userInfo)")
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        MTPushService.handleRemoteNotification(userInfo)
        print("iOS7及以上系统，收到通知:\(userInfo)")
        completionHandler(.newData)
    }
    
```

#### 成功运行

真机调试该项目，如果控制台输出以下日志则代表您已经集成成功。

```
2021-08-19 17:12:12.745823 219b28[1443:286814] | MTP | I - [MTCORETcpEventController] 
----- login result -----
uid:123456 
registrationID:171976fa8a8620a14a4 
idc:0
```

到此 已经完成集成 MTPush sdk 的基本功能，若需要更多功能请参考Demo工程


