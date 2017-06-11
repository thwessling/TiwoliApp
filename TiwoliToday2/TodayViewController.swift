//
//  TodayViewController.swift
//  TiwoliToday2
//
//  Created by thb on 10/09/16.
//  Copyright © 2016 thb. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var quoteString: UILabel!
    
    @IBOutlet weak var headingString: UILabel!
    
    var sortedIndizesDE = [String]()
    var quotationsDE: [String: JSON]?
    
    var currentLanguage = Languages.English;

    
    var currentIndex = ""

    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadData() {
        var quoteFile = "quotations-de"
        
        switch self.currentLanguage {
            case .English:
                quoteFile = "quotations-en";
            case .Spanish:
                quoteFile = "quotations-es";
        default:
            quoteFile = "quotations-de";
        }
        
        if let path = Bundle.main.path(forResource: quoteFile, ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                
                quotationsDE = JSON(data: data).dictionary!

                sortedIndizesDE = [String]()
                for key in quotationsDE!.keys {
                    sortedIndizesDE.append(key)
                }
                sortedIndizesDE.sort()
            }
        }
    }
    
    
    
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        let components = (Calendar.current as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month], from: Date())
        let month = String(format: "%02d", components.month!)
        let day = String(format: "%02d", components.day!)
        
        let dateString = "\(month)\(day)"
        print(dateString)
        
        let id = "\(dateString)-0"
        
        
        // already the current quote: no update required
        if (self.currentIndex == id) {
            completionHandler(NCUpdateResult.noData)
            return
        }
        
        // update required: load quotation data and show current quote
        
        // load quotation language setting
        let quotationLanguage = UserDefaults.init(suiteName: "group.tiwoli")?.string(forKey: "quotatationLanguage")
        if let quotationLanguage = quotationLanguage {
            self.currentLanguage = Languages(rawValue: quotationLanguage)!
        } else {
            self.currentLanguage = Languages.English;
        }
        
        self.loadData()
        
        self.currentIndex = id
        
        let headline = NSLocalizedString("widgetHeading", comment: "comment")

        
        if let quotationJson = quotationsDE![id] {
            if let  quote = quotationJson.dictionary {
                self.headingString.text = headline + (quote["author"]?.string!)!
                let str = (quote["quote"]?.string!)!
                let index1 = str.index(str.startIndex, offsetBy: 140)
                self.quoteString.text = str.substring(to: index1) + "…"
                let imageString = (quote["authorPic"]?.string!)!
                self.image.image = UIImage(named:  imageString + ".jpg")

            }
        }
        
        
        completionHandler(NCUpdateResult.newData)
        
    }
    
}
