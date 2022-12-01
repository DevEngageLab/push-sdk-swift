//
//  SendBadgeViewController.swift
//  jpush-swift-demo
//
//  Created by oshumini on 16/1/21.
//  Copyright © 2016年 HuminiOS. All rights reserved.
//

import UIKit

class OtherViewController: UIViewController {

    @IBOutlet weak var badgeCountTF: UITextField!
    @IBOutlet weak var mobileNumTF: UITextField!
    
    override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
    
    @IBAction func reportBadge(_ sender: Any) {
        view.endEditing(true)
        guard let stringBadge = badgeCountTF.text else{
            print("please input badge count")
            showAlertControllerWithTitle(nil, message: "please input badge count")
            return
        }
        guard let value = Int(stringBadge) else{
            print("请填入正确的数值")
            return
        }
        print("send badge:\(String(describing: value)) to mtpush server")
        showAlertControllerWithTitle(nil, message: "send badge:\(String(describing: value)) to mtpush server")
        MTPushService.setBadge(value)
    }
    
    @IBAction func reportMobileNumber(_ sender: Any) {
        view.endEditing(true)
        guard let mobileStr = self.mobileNumTF.text else {
            print("please input valid mobile number")
            showAlertControllerWithTitle(nil, message: "please input valid mobile number")
            return
        }
        
        MTPushService.setMobileNumber(mobileStr) { error in
            if (error == nil) {
              print("report mobile number success!")
                self.showAlertControllerWithTitle(nil, message: "report mobile number success!")
            }else {
                print("report mobile number error: \(String(describing: error))");
                self.showAlertControllerWithTitle(nil, message: "report mobile number error: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func clearAllInput(_ sender: Any) {
        view.endEditing(true)
        badgeCountTF.text = ""
        mobileNumTF.text = ""
    }
    
    func showAlertControllerWithTitle(_ title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "ok")
            alert.show()
        }
    }
    
}

