//
//  setLocalNotificationViewController.swift
//  jpush-swift-demo
//
//  Created by oshumini on 16/1/21.
//  Copyright © 2016年 HuminiOS. All rights reserved.
//

import UIKit
import CoreLocation

class setLocalNotificationViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var subtitleTF: UITextField!
    @IBOutlet weak var bodyTF: UITextField!
    @IBOutlet weak var badgeTF: UITextField!
    @IBOutlet weak var actionTF: UITextField!
    @IBOutlet weak var soundTF: UITextField!
    @IBOutlet weak var cateforyIdentifierTF: UITextField!
    @IBOutlet weak var threadIDTF: UITextField!
    @IBOutlet weak var summaryArgumentTF: UITextField!
    @IBOutlet weak var summaryArgCountTF: UITextField!
    @IBOutlet weak var requestIdentifierTF: UITextField!
    @IBOutlet weak var repeatSW: UISwitch!
    @IBOutlet weak var deliveredSW: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTF.delegate = self
        subtitleTF.delegate = self
        bodyTF.delegate = self
        badgeTF.delegate = self
        actionTF.delegate = self
        soundTF.delegate = self
        cateforyIdentifierTF.delegate = self
        threadIDTF.delegate = self
        summaryArgumentTF.delegate = self
        summaryArgumentTF.delegate = self
        requestIdentifierTF.delegate = self
    }
    
    
    @IBAction func addNotificationWithDateTrigger(_ sender: Any) {
        
        let trigger = MTPushNotificationTrigger()
        
        if #available(iOS 10.0, *) {
            var components = DateComponents()
            components.weekday = 2
            components.hour = 8
            trigger.dateComponents = components
        } else {
            let fireDate = Date.init(timeIntervalSinceNow: 20)
            trigger.fireDate = fireDate
        }
        
        trigger.repeat = self.repeatSW.isOn;
        let request = MTPushNotificationRequest.init()
        request.content = generateNotificationCotent()
        request.trigger = trigger;
        request.completionHandler = { result in
            // iOS10以上成功则result为UNNotificationRequest对象，失败则result为nil
            // iOS10以下成功result为UILocalNotification对象，失败则result为nil
            if let result {
              print("添加日期通知成功 --- \(result)");
//              _notification = result;
               var message = "";
                if #available(iOS 10.0, *) {
                message = "iOS10以上，\(trigger.dateComponents) 触发"
              }else {
                  let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                  let dateStr = dateFormatter.string(from: trigger.fireDate)
                message = "iOS10以下，\(dateStr)触发"
              }
                self.showAlertControllerWithTitle("添加 date 通知成功", message: message)
            }else {
                self.showAlertControllerWithTitle("添加 date 通知失败", message: nil)
            }
          }
        request.requestIdentifier = self.requestIdentifierTF.text
        MTPushService.addNotification(request)
       
    }
    
    @IBAction func addNotificationWithRegionTrigger(_ sender: Any) {
        let trigger = MTPushNotificationTrigger()
        if #available(iOS 8.0, *) {
            let cen = CLLocationCoordinate2DMake(22.5531706, 113.9025006)
            let region = CLCircularRegion.init(center: cen, radius: 2000.0, identifier: "EngageLab")
            trigger.region = region
            trigger.repeat = self.repeatSW.isOn
        }else {
            print("region 触发通知只在 iOS8 以上有效哦……")
            self.showAlertControllerWithTitle(nil, message: "region 触发通知只在 iOS8 以上有效")
            return
        }
        
        let request = MTPushNotificationRequest()
        request.content = generateNotificationCotent()
        request.trigger = trigger
        request.completionHandler = { result in
            if let result {
                print("添加地理位置通知成功 --- \(result)")
                let message = "\(String(describing: trigger.region))"
                self.showAlertControllerWithTitle("添加 region 通知成功", message: message)
            }else {
                self.showAlertControllerWithTitle("添加 region 通知失败", message: nil)
            }
        }
        request.requestIdentifier = self.requestIdentifierTF.text
        MTPushService.addNotification(request)
    }
    
    @IBAction func addNotificationWithTimeintervalTrigger(_ sender: Any) {
        let trigger = MTPushNotificationTrigger()
        var timeInterval = 0.0
        if #available(iOS 10.0, *) {
            trigger.timeInterval = 20
            if (trigger.timeInterval < 60) {
                trigger.repeat = false
            }else {
                trigger.repeat = self.repeatSW.isOn
            }
            timeInterval = trigger.timeInterval
        } else {
            print("timeInterval 触发通知只在 iOS10 以上有效哦……")
            self.showAlertControllerWithTitle(nil, message: "timeInterval 触发通知只在 iOS10 以上有效")
            return
        }
        
        let request = MTPushNotificationRequest()
        request.content = generateNotificationCotent()
        request.trigger = trigger
        request.completionHandler = {result in
            if let result {
                print("添加 timeInterval 通知成功 --- \(result)")
                let message = "iOS10以上，\(timeInterval)秒后触发"
                self.showAlertControllerWithTitle("添加 timeInterval 通知成功", message: message)
            }else {
                self.showAlertControllerWithTitle("添加 timeInterval 通知失败", message: nil)
            }
        }
        request.requestIdentifier = self.requestIdentifierTF.text
        MTPushService.addNotification(request)
    }
    
    @IBAction func findNotifationWithIdentifier(_ sender: Any) {
        let identifier = MTPushNotificationIdentifier()
        guard let identify = requestIdentifierTF.text else {
            return
        }
        if identify.count == 0 {
            print("通知identifier不能为空")
            self.showAlertControllerWithTitle("通知identifier不能为空", message: nil)
            return
        }
        identifier.identifiers = [identify]
        if #available(iOS 10.0, *) {
            identifier.delivered = self.deliveredSW.isOn
        }
        identifier.findCompletionHandler = { results in
            print("查找指定通知 - 返回结果为：\(String(describing: results))")
            let title = "查找指定通知 \(String(describing: results?.count)) 条"
            let message = "\(String(describing: results))"
            self.showAlertControllerWithTitle(title, message: message)
        }
        MTPushService.findNotification(identifier)
    }
    
    @IBAction func findAllNotification(_ sender: Any) {
        let identifier = MTPushNotificationIdentifier()
        identifier.identifiers = nil
        if #available(iOS 10.0, *) {
            identifier.delivered = self.deliveredSW.isOn
        }
        identifier.findCompletionHandler = { results in
            print("查找全部通知 - 返回结果为：\(String(describing: results))")
            let title = "查找全部通知 \(String(describing: results?.count)) 条"
            let message = "\(String(describing: results))"
            self.showAlertControllerWithTitle(title, message: message)
        }
        MTPushService.findNotification(identifier)
    }
    
    @IBAction func removeNotificationWithIdentifier(_ sender: Any) {
        guard let identify = requestIdentifierTF.text else {
            return
        }
        let identifier = MTPushNotificationIdentifier.init()
        identifier.identifiers = [identify]
        if #available(iOS 10.0, *) {
            identifier.delivered = self.deliveredSW.isOn
        } else {
            // Fallback on earlier versions
        }
        MTPushService.removeNotification(identifier)
        print("删除指定通知")
        self.showAlertControllerWithTitle(nil, message: "删除指定通知")
    }
    
    @IBAction func removeAllNotification(_ sender: Any) {
        MTPushService.removeNotification(nil)
        self.showAlertControllerWithTitle(nil, message: "删除所有通知")
    }
    
    
    func generateNotificationCotent() -> MTPushNotificationContent {
      let content = MTPushNotificationContent()
      content.title = self.titleTF.text;
      content.subtitle = self.subtitleTF.text;
      content.body = self.bodyTF.text;
      content.badge = Int(self.badgeTF.text ?? "0") as NSNumber?
      content.action = self.actionTF.text
      content.categoryIdentifier = self.cateforyIdentifierTF.text
        if #available(iOS 10.0, *) {
            content.threadIdentifier = self.threadIDTF.text
        }
      //注意@"_j_private_cloud" : @"EngageLab"必须存在，否则无法使用本地推送
      content.userInfo = ["hello" : "how are you", "msg" : "success", "_j_private_cloud" : "EngageLab"]
    //  content.userInfo = @{@"extra":@"xxxx"};
    //  UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"pushTest" URL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ios7" ofType:@"png"]] options:nil error:nil];
    //  content.attachments = @[attachment];
    //  content.launchImageName = @"";
        
        if #available(iOS 10.0, *) {
        let soundSetting = MTPushNotificationSound()
        soundSetting.soundName = self.soundTF.text;
        //如果是告警通知
        if #available(iOS 12.0, *) {
          soundSetting.criticalSoundName = "sound.caf";
          soundSetting.criticalSoundVolume = 0.9;
        }
        content.soundSetting = soundSetting;
      }else {
        content.sound = self.soundTF.text;
      }
       if #available(iOS 12.0, *) {
        content.summaryArgument = self.summaryArgumentTF.text;
        content.summaryArgumentCount = UInt(self.summaryArgCountTF.text ?? "") ?? 0
      }
        if #available(iOS 15.0, *) {
            content.relevanceScore = 1
            content.interruptionLevel = 1
        }
        
      if #available(iOS 10.0, *) {
        if (self.requestIdentifierTF.text?.count == 0) {
            self.showAlertControllerWithTitle(nil, message: "通知identifier不能为空")
        }
      }
      return content;
    }
   
    func showAlertControllerWithTitle(_ title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "ok")
            alert.show()
        }
    }
    
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
