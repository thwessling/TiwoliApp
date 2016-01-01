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
    @IBOutlet weak var languageSegmentControl: UISegmentedControl!
    
    @IBAction func languageToggleChange(sender: AnyObject) {
        print(Languages.German.rawValue)
        switch languageSegmentControl.selectedSegmentIndex {
        case 0:
            NSUserDefaults.standardUserDefaults().setObject(Languages.German.rawValue, forKey: "quotatationLanguage")
        case 1:
            NSUserDefaults.standardUserDefaults().setObject(Languages.English.rawValue, forKey: "quotatationLanguage");
        default:
            NSUserDefaults.standardUserDefaults().setObject(Languages.German.rawValue, forKey: "quotatationLanguage")
        }
        
    }
    
    
    
    @IBAction func notificationToggleChange(sender: AnyObject) {
       if notificationToggle.on {
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert], categories: nil))
            self.datePicker.hidden = false
            self.timeLabel.hidden = false
       } else {
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
        
        let languageString = NSUserDefaults.standardUserDefaults().stringForKey("quotatationLanguage");
        print(languageString)
        if let languageString = languageString {
            let language = Languages(rawValue: languageString)
            switch language!  {
            case Languages.English:
                self.languageSegmentControl.selectedSegmentIndex = 1
            case Languages.German:
                self.languageSegmentControl.selectedSegmentIndex = 0
            }
        } else {
            self.languageSegmentControl.selectedSegmentIndex = -1
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
            NSCalendar.currentCalendar().components([NSCalendarUnit.Day,NSCalendarUnit.Month], fromDate: NSDate())
            

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
