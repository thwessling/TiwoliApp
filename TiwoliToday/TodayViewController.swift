//
//  TodayViewController.swift
//  TiwoliToday
//
//  Created by thb on 23/04/15.
//  Copyright (c) 2015 thb. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var quotations: [String: JSON]?
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSThread.detachNewThreadSelector(Selector("loadDataThreaded"), toTarget: self, withObject: nil)
    }
    
    
    func loadDataThreaded() {
        self.loadData()
    }
    
    func loadData() {
        println("Load data")
        if let path = NSBundle.mainBundle().pathForResource("quotations-de", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                var startDate = NSDate()
                self.quotations = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil).dictionary
                println("Elements: \(self.quotations?.count)")
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay|NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())
        var month = String(format: "%02d", components.month)
        var day = String(format: "%02d", components.day)
        
        let dateString = "\(month)\(day)-0"
        println("datestring: \(dateString)")
        if let quotations = self.quotations {
            var quote = quotations[dateString]!.dictionary!
            let quoteString = quote["quote"]!.string!
            self.webView?.loadHTMLString(quoteString, baseURL: nil)
            println("Loaded quote")
        }
        

        
        completionHandler(NCUpdateResult.NewData)
    }
    
}
