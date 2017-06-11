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
    
    @IBAction func languageToggleChange(_ sender: AnyObject) {
        switch languageSegmentControl.selectedSegmentIndex {
        case 0:
            UserDefaults.init(suiteName: "group.tiwoli")?.set(Languages.German.rawValue, forKey: "quotatationLanguage")
        case 1:
            UserDefaults.init(suiteName: "group.tiwoli")?.set(Languages.English.rawValue, forKey: "quotatationLanguage");
        case 2:
            UserDefaults.init(suiteName: "group.tiwoli")?.set(Languages.Spanish.rawValue, forKey: "quotatationLanguage");
        default:
            UserDefaults.init(suiteName: "group.tiwoli")?.set(Languages.German.rawValue, forKey: "quotatationLanguage")
        }
        
    }
    
    
    
    @IBAction func notificationToggleChange(_ sender: AnyObject) {
       if notificationToggle.isOn {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.sound, UIUserNotificationType.alert], categories: nil))
            self.datePicker.isHidden = false
            self.timeLabel.isHidden = false
       } else {
        UIApplication.shared.cancelAllLocalNotifications()
        self.datePicker.isHidden = true
        self.timeLabel.isHidden = true

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.init(suiteName: "group.tiwoli")?.bool(forKey: "enableNotifications"))! {
            // user setting: enable notif
            self.notificationToggle.setOn(true, animated: true)
            self.datePicker.isHidden = false
            self.timeLabel.isHidden = false

            let dateString = UserDefaults.init(suiteName: "group.tiwoli")?.string(forKey: "notificationTime")
            if let dateString = dateString {
                let formatter = DateFormatter()
                formatter.setLocalizedDateFormatFromTemplate("YYYY-MM-DD HH:mm")
                let dateObj = formatter.date(from: dateString)
                if let dateObj = dateObj {
                    print("Retrieved date obj: \(dateObj)")
                    self.datePicker.setDate(dateObj, animated: true)
                }
            }
        } else {
            self.notificationToggle.setOn(false, animated: true)
        }
        
        let languageString = UserDefaults.init(suiteName: "group.tiwoli")?.string(forKey: "quotatationLanguage");
        print(languageString)
        if let languageString = languageString {
            let language = Languages(rawValue: languageString)
            switch language!  {
            case Languages.Spanish:
                self.languageSegmentControl.selectedSegmentIndex = 2
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if notificationToggle.isOn {
            UserDefaults.init(suiteName: "group.tiwoli")?.set(true, forKey: "enableNotifications")

            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("YYYY-MM-DD HH:mm")
            let dateString = formatter.string(from: self.datePicker.date)
            print("date:  + \(dateString)")
            UserDefaults.init(suiteName: "group.tiwoli")?.set(dateString, forKey: "notificationTime")
            
            print("Local notification at \(datePicker.date)")
            UIApplication.shared.cancelAllLocalNotifications()
            let notification =  UILocalNotification()
            
            notification.fireDate = datePicker.date
            notification.timeZone = TimeZone.current
            let bodyString = NSLocalizedString("notificationBody", comment: "")

            notification.alertBody = bodyString
            notification.alertAction = NSLocalizedString("notificationAction", comment: "")
            (Calendar.current as NSCalendar).components([NSCalendar.Unit.day,NSCalendar.Unit.month], from: Date())
            

            notification.alertTitle = NSLocalizedString("notificationTitle", comment: "")
            notification.repeatInterval = NSCalendar.Unit.day
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
            print("Schedulded for \(notification.fireDate)")
        } else {
            UserDefaults.init(suiteName: "group.tiwoli")?.set(false, forKey: "enableNotifications")
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
