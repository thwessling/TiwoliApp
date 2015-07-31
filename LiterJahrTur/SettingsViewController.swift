//
//  SettingsViewController.swift
//  LiterJahrTur
//
//  Created by thb on 17/04/15.
//  Copyright (c) 2015 thb. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var notificationToggle: UISwitch!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func notificationToggleChange(sender: AnyObject) {
       if notificationToggle.on {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound,UIUserNotificationType.Alert], categories: nil))
            self.datePicker.hidden = false
            self.timeLabel.hidden = false
       } else {
        print("Local notifications cancelled")
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        self.datePicker.hidden = true
        self.timeLabel.hidden = true

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if NSUserDefaults.standardUserDefaults().boolForKey("enableNotifications") {
            // user setting: enable notif
            self.notificationToggle.setOn(true, animated: true)
            self.datePicker.hidden = false
            self.timeLabel.hidden = false

            let dateString = NSUserDefaults.standardUserDefaults().stringForKey("notificationTime")
            if let dateString = dateString {
                let formatter = NSDateFormatter()
                formatter.setLocalizedDateFormatFromTemplate("YYYY-MM-DD HH:mm")
                let dateObj = formatter.dateFromString(dateString)
                if let dateObj = dateObj {
                    print("Retrieved date obj: \(dateObj)")
                    self.datePicker.setDate(dateObj, animated: true)
                }
            }
        } else {
            self.notificationToggle.setOn(false, animated: true)
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if notificationToggle.on {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "enableNotifications")

            let formatter = NSDateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("YYYY-MM-DD HH:mm")
            let dateString = formatter.stringFromDate(self.datePicker.date)
            print("date:  + \(dateString)")
            NSUserDefaults.standardUserDefaults().setObject(dateString, forKey: "notificationTime")
            
            print("Local notification at \(datePicker.date)")
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            let notification =  UILocalNotification()
            
            notification.fireDate = datePicker.date
            notification.timeZone = NSTimeZone.systemTimeZone()
            let bodyString = NSLocalizedString("notificationBody", comment: "")
            notification.alertBody = bodyString
            notification.alertAction = NSLocalizedString("notificationAction", comment: "")
            notification.alertTitle = NSLocalizedString("notificationTitle", comment: "")
            notification.repeatInterval = NSCalendarUnit.Day
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            print("Schedulded for \(notification.fireDate)")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "enableNotifications")
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
