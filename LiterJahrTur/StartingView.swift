//
//  StartingView.swift
//  LiterJahrTur
//
//  Created by thb on 15/04/15.
//  Copyright (c) 2015 thb. All rights reserved.
//

import UIKit

class StartingView: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate {

    @IBOutlet weak var pickerBar: UIView!
    var quotations: JSON?
    var quotesPerDay: [String: Int] = ["":0]
    var sortedIndizes = [String]()
    var pageViewController: UIPageViewController?;
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var datePicker: UIPickerView!
    
    
    func readNumberOfQuotes()  {
        if let path = NSBundle.mainBundle().pathForResource("date-to-number-of-quotes", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
            let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
                for (key: String, subJson: JSON) in json {
                    self.quotesPerDay[key] = json[key].int
                }
            }
        }
    }
    
    override func viewDidLoad() {
        println("loaded view")
        
        if let path = NSBundle.mainBundle().pathForResource("quotations-de", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                var startDate = NSDate()

                self.quotations = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
                println("Time for parsing json: \(-startDate.timeIntervalSinceNow)s")
                startDate = NSDate()
                if let json = self.quotations {
                    var indizes = [String]()
                    for (key: String, subJson: JSON) in json {
                        indizes.append(key)
                    }
                    self.sortedIndizes = sorted(indizes)
                }
                println("Time for creating index: \(-startDate.timeIntervalSinceNow)s")
            }
        }
        
        self.readNumberOfQuotes()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.datePicker.dataSource = self
        self.datePicker.delegate = self
        
        self.datePicker.showsSelectionIndicator = true;
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.segment.selectedSegmentIndex = 0
        self.segment.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nextQuoteToShow(controller: QuotationDisplayViewController, text: String?) {
        println("Pressed next.")
    }
    
    func getIdForToday() -> String {
        return "";
    }
    
    
    @IBAction func dateSelectionClicked(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.pressedToday()
        } else {
            self.pressedRandom()
        }
        
    }
    
    func pressedRandom() {
        let month = Int(arc4random_uniform(12))
        self.datePicker.selectRow(month, inComponent: 0, animated: true)
        self.datePicker.reloadComponent(1)
        let days = UInt32(self.datePicker.numberOfRowsInComponent(1))
        let day = Int(arc4random_uniform(days))
        self.datePicker.selectRow(day, inComponent: 1, animated: true)
    }
    
    @IBAction func pressedShowQuote(sender: AnyObject) {
        var month = String(format: "%02d", self.datePicker.selectedRowInComponent(0)+1)
        var day = String(format: "%02d", self.datePicker.selectedRowInComponent(1)+1)
        
        let dateString = "\(month)\(day)"
        println("Date \(dateString)")
        
        let index = find(self.sortedIndizes, "\(dateString)-0")!

        let nextQuote = self.viewControllerAtIndex("\(dateString)-0", index: index)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        self.pageViewController =
            storyBoard.instantiateViewControllerWithIdentifier("PageViewController") as? UIPageViewController
        
        self.pageViewController!.dataSource = self
        var startingViewControllers = [QuotationDisplayViewController]()
        startingViewControllers.append(nextQuote)
        
        pageViewController!.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        
        
        // add share item to navigation bar
        let shareItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: nextQuote, action: "pressedShared")
        //self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
        self.pageViewController!.navigationItem.rightBarButtonItem = shareItem
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red: 100.0, green: 149.0, blue: 237.0, alpha: 1.0)
        
        self.navigationController!.pushViewController(pageViewController!, animated: true)
        self.pageViewController?.didMoveToParentViewController(self.navigationController)
        

    }
    
 
    
    
    func pressedToday() {
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay|NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())
        
//        let index = find(self.sortedIndizes, "0322-0")!
        self.datePicker.selectRow(components.month-1, inComponent: 0, animated: true)
        self.datePicker.selectRow(components.day-1, inComponent: 1, animated: true)
        
        println("Pressed today")
    }
    
    func getDateForId(id: String) -> String {
        let dateString = id.componentsSeparatedByString("-")[0]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMDD"
        let date = dateFormatter.dateFromString(dateString)
        if let date = date {
            dateFormatter.dateFormat = "MMMMd"
            dateFormatter.locale = NSLocale.currentLocale()
            let dateString = NSDateFormatter.dateFormatFromTemplate("MMMM dd", options: 0, locale: NSLocale.currentLocale())
            dateFormatter.dateFormat = dateString
            return dateFormatter.stringFromDate(date)
        } else {
            println("Couldn't parse date")
            return "no date"
        }
    }
    
    func viewControllerAtIndex(id: String, index: Int) -> QuotationDisplayViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextQuote =
        storyBoard.instantiateViewControllerWithIdentifier("QuotationDisplayViewController") as! QuotationDisplayViewController
        
        let dateId = id.componentsSeparatedByString("-")[0]
        var quoteEnumerator = id.componentsSeparatedByString("-")[1].toInt()! + 1
        var numberOfQuotes = self.quotesPerDay[dateId]
        
        if let json = self.quotations {
            var quote = json[id]["quote"].string
            nextQuote.quoteString = quote!
            nextQuote.quoteAuthorString = json[id]["author"].string!
            nextQuote.authorWPString = json[id]["authorWP"].string!
            nextQuote.bookString = json[id]["book"].string!
            nextQuote.sourceString = json[id]["source"].string!
            nextQuote.picSourceString = json[id]["picSource"].string!
            nextQuote.imageString = json[id]["authorPic"].string!
            //nextQuote.imageString = "literjahrtur512"
            let dateString = getDateForId(id)
            nextQuote.headlineString = NSLocalizedString("quoteHeading", comment: "comment") + "\(dateString)"
            if let numberOfQuotes = numberOfQuotes {
                
                nextQuote.headlineString = nextQuote.headlineString! + " [\(quoteEnumerator)/\(numberOfQuotes+1)]"

            }
            //nextQuote.headlineString = "Quote for \(dateString)"
            nextQuote.currentIndex = index
        }
        
        return nextQuote
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            println("-> previous quote.")
            let quoteViewController = viewController as! QuotationDisplayViewController
            if let idx = quoteViewController.currentIndex {
                if idx == 0 {
                    return nil
                }
                let newId = self.sortedIndizes[idx-1]
                return self.viewControllerAtIndex(newId, index: idx-1)
            } else {
                println("No quote id?")
                return nil
            }
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            println("-> next quote.")
            let quoteViewController = viewController as! QuotationDisplayViewController
            if let idx = quoteViewController.currentIndex {
                if idx > self.sortedIndizes.count-1 {
                    return nil
                }
                let newId = self.sortedIndizes[idx+1]
                return self.viewControllerAtIndex(newId, index: idx+1)
            } else {
                println("No quote id?")
                return nil
            }

    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindToMainScreen(segue: UIStoryboardSegue)  {
        
    }

    /*
        Date picker 
    */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2;
    }
    
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12;
        } else {
            let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())
            
            components.month = pickerView.selectedRowInComponent(0)+1
            components.day     = 1
            components.year  = 2012
            let specifiedDate: NSDate = NSCalendar.currentCalendar().dateFromComponents(components)!

            
            let dayRange = NSCalendar.currentCalendar().rangeOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: specifiedDate)
            return dayRange.length
       
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if component == 0 {
            return  NSDateFormatter().monthSymbols[row] as! String
        } else {
            return "\(row+1)."
        }
    }
    
}
