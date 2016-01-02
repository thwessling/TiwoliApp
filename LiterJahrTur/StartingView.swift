//
//  StartingView.swift
//  LiterJahrTur
//
//  Created by thb on 15/04/15.
//  Copyright (c) 2015 thb. All rights reserved.
//

import UIKit

protocol Shareable {
    func pressedShared(presentingVC: UIViewController)
}

class StartingView: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, LanguageButtonHandler {

    @IBOutlet weak var pickerBar: UIView!

    var quotesPerDayDE: [String: JSON]? // = ["1201": 10]
    var quotesPerDayEN: [String: JSON]? // = ["":0]
    
    
    var currentQuotesPerDay: [String: JSON]?
    var currentQuotations: [String: JSON]?
    
    var sortedIndizesDE = [String]()
    var sortedIndizesEN = [String]()
    var currentSortedIndices = [String]()
    
    var pageViewController: UIPageViewController?;
    var delegate: Shareable?
    var currentId = "null"
    var displayedId = "null"
    
    var quotationsDE: [String: JSON]?
    var quotationsEN: [String: JSON]?
    
    var currentLanguage = Languages.English;
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var datePicker: UIPickerView!
    
    @IBOutlet weak var showQuoteButton: UIButton!
    
    @IBOutlet weak var currentLanguageLabel: UILabel!
    
    // MARK: - Data loading and initialization

    // load index for number of quotes per day (day -> number of quotes)
    func readNumberOfQuotes(fileName: String, inout target: [String: JSON]?)  {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
            let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
                target = json.dictionary!
            }
        }
    }
    
    // Load quotations
    func loadDataThreaded() {
        self.loadData("quotations-de", varquoteDict: &self.quotationsDE, indices: &self.sortedIndizesDE)
        self.loadData("quotations-en", varquoteDict: &self.quotationsEN, indices: &self.sortedIndizesEN)
        self.readNumberOfQuotes("date-to-number-of-quotes", target: &self.quotesPerDayDE)
        self.readNumberOfQuotes("date-to-number-of-quotes-en", target: &self.quotesPerDayEN)
    }
    
    func loadData(quoteFile: String, inout varquoteDict: [String: JSON]?, inout indices: [String]) {
        if let path = NSBundle.mainBundle().pathForResource(quoteFile, ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                
                varquoteDict = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil).dictionary!
                    var indizes = [String]()
                    for key in varquoteDict!.keys {
                        indizes.append(key)
                    }
                    indizes.sortInPlace()
                    indices = indizes
            }
        }
    }
    
    override func viewDidLoad() {
        // load quotations from files in threaded mode
        //NSThread.detachNewThreadSelector(Selector("loadDataThreaded"), toTarget: self, withObject: nil)
        self.loadDataThreaded()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.datePicker.dataSource = self
        self.datePicker.delegate = self
        
        self.datePicker.showsSelectionIndicator = true;
        self.segment.selectedSegmentIndex = 0
        self.segment.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        self.segment.selectedSegmentIndex = -1

        // load current language from settings
        let quotationLanguage = NSUserDefaults.standardUserDefaults().stringForKey("quotatationLanguage")
        if let quotationLanguage = quotationLanguage {
            self.currentLanguage = Languages(rawValue: quotationLanguage)!
        } else {
            self.currentLanguage = Languages.English;
        }
        self.changeCurrentLanguageLabel()
        self.changeCurrentLanguageDictionaries()

        // handle notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showQuote", name: "showQuote", object: nil)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.currentId != "null" {
                    let dateString = self.currentId.componentsSeparatedByString("-")[0]
                    let month = Int(dateString.substringToIndex(dateString.startIndex.advancedBy(2)))
                    let day = Int(dateString.substringFromIndex(dateString.startIndex.advancedBy(2)))
                    self.datePicker.selectRow(month!-1, inComponent: 0, animated: true)
                    self.datePicker.selectRow(day!-1, inComponent: 1, animated: true)
        }
        super.viewDidAppear(animated)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - User interaction
    
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
        print(self.datePicker.selectedRowInComponent(0))
        self.currentId = "null"
    }
    
    func showQuote() {
        self.pressedToday()
        showQuoteButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    @IBAction func pressedShowQuote(sender: AnyObject) {
        let month = String(format: "%02d", self.datePicker.selectedRowInComponent(0)+1)
        let day = String(format: "%02d", self.datePicker.selectedRowInComponent(1)+1)
  
        let dateString = "\(month)\(day)"
        let id = "\(dateString)-0"
        
        let index =  self.currentSortedIndices.indexOf(id)

        self.currentId = id
        
        let nextQuote = self.viewControllerAtIndex(id, index: index!)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        self.pageViewController =
            storyBoard.instantiateViewControllerWithIdentifier("PageViewController") as? UIPageViewController
        
        self.pageViewController!.dataSource = self
        var startingViewControllers = [QuotationDisplayViewController]()
        startingViewControllers.append(nextQuote)
        
        pageViewController!.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)

        // add share item to navigation bar
        let shareItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "pressedShared")
        //self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
        self.pageViewController!.navigationItem.rightBarButtonItem = shareItem
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red: 100.0, green: 149.0, blue: 237.0, alpha: 1.0)
        
        self.navigationController!.pushViewController(pageViewController!, animated: true)
        self.pageViewController?.didMoveToParentViewController(self.navigationController)
    }
    
 
    func pressedShared() {
        self.delegate?.pressedShared(self)
    }
    
    
    func pressedToday() {
        let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Day, NSCalendarUnit.Month], fromDate: NSDate())
        self.datePicker.selectRow(components.month-1, inComponent: 0, animated: true)
        self.datePicker.selectRow(components.day-1, inComponent: 1, animated: true)
        self.currentId = "null"
    }
    
    
    
    func getDateForId(id: String) -> String {
        let dateString = id.componentsSeparatedByString("-")[0]
        let month = dateString.substringToIndex(dateString.startIndex.advancedBy(2))
        let day = dateString.substringFromIndex(dateString.startIndex.advancedBy(2))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM dd"
        let date = dateFormatter.dateFromString("\(month) \(day)")
        if let date = date {
            dateFormatter.locale = NSLocale.currentLocale()
            let dateString = NSDateFormatter.dateFormatFromTemplate("MM dd", options: 0, locale: NSLocale.currentLocale())
            dateFormatter.dateFormat = dateString
            return dateFormatter.stringFromDate(date)
        } else {
            print("Couldn't parse date")
            return "no date"
        }
    }
    
    func viewControllerAtIndex(id: String, index: Int) -> QuotationDisplayViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextQuote =
        storyBoard.instantiateViewControllerWithIdentifier("QuotationDisplayViewController") as! QuotationDisplayViewController
        
        let dateId = id.componentsSeparatedByString("-")[0]
        let enumeratorId = id.componentsSeparatedByString("-")[1]
        let quoteEnumerator = Int(enumeratorId)! + 1
        let numberOfQuotes = self.currentQuotesPerDay![dateId]?.intValue
        
        print(self.currentLanguage)
        if let quotationJson = currentQuotations![id] {
            if let  quote = quotationJson.dictionary {
                nextQuote.quoteString = (quote["quote"]?.string!)!
                nextQuote.quoteAuthorString = quote["author"]!.string!
                nextQuote.authorWPString = quote["authorWP"]!.string!
                nextQuote.bookString = quote["book"]!.string!
                nextQuote.sourceString = quote["source"]!.string!
                nextQuote.picSourceString = quote["picSource"]!.string!
                nextQuote.imageString = quote["authorPic"]!.string!
                nextQuote.currentLanguage = self.currentLanguage;
            }
        }
        nextQuote.languageChangeHandler = self

        let dateString = getDateForId(id)
        nextQuote.headlineString = NSLocalizedString("quoteHeading", comment: "comment") + "\(dateString)"
        if let numberOfQuotes = numberOfQuotes {
            nextQuote.headlineString = nextQuote.headlineString! + " [\(quoteEnumerator)/\(numberOfQuotes+1)]"

        }
            
        self.delegate = nextQuote
        nextQuote.currentIndex = index
        nextQuote.currentDateId = dateId;
        
        return nextQuote
    }
    
     // MARK: - PageViewController
    

    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            let quoteViewController = viewController as! QuotationDisplayViewController
            if let idx = quoteViewController.currentIndex {
                if idx == 0 {
                    return nil
                }
                let newId = self.currentSortedIndices[idx-1]
                //self.currentId = newId
                return self.viewControllerAtIndex(newId, index: idx-1)
            } else {
                print("No quote id?")
                return nil
            }
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            let quoteViewController = viewController as! QuotationDisplayViewController
            if let idx = quoteViewController.currentIndex {
                var newId: String
                if idx > self.currentSortedIndices.count-2 {
                    return nil
                } else {
                    newId = self.currentSortedIndices[idx+1]
                }
                //self.currentId = newId
                return self.viewControllerAtIndex(newId, index: idx+1)
            } else {
                print("No quote id?")
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
    // MARK: - Date picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2;
    }
    
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12;
        } else {
            let components = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: NSDate())
            
            components.month = pickerView.selectedRowInComponent(0)+1
            components.day     = 1
            components.year  = 2012
            let specifiedDate: NSDate = NSCalendar.currentCalendar().dateFromComponents(components)!

            
            let dayRange = NSCalendar.currentCalendar().rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: specifiedDate)
            return dayRange.length
       
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
    }
    
    // MARK: - Changing language
    
    
    func changeCurrentLanguageLabel() {
        let languageString = NSLocalizedString(self.currentLanguage.rawValue, comment: "comment")
        self.currentLanguageLabel.text = languageString;
    }
    
    // perform post-processing
    func changeCurrentLanguageDictionaries() {
        switch self.currentLanguage {
        case .English:
            self.currentQuotations = self.quotationsEN;
            self.currentQuotesPerDay = self.quotesPerDayEN;
            self.currentSortedIndices = self.sortedIndizesEN;
        case .German:
            self.currentQuotations = self.quotationsDE;
            self.currentQuotesPerDay = self.quotesPerDayDE;
            self.currentSortedIndices = self.sortedIndizesDE;
        }
    }
    
    
    @IBAction func changeLanguagePressed(sender: AnyObject) {
        switch self.currentLanguage {
        case .English:
            self.currentLanguage = Languages.German;
        case .German:
            self.currentLanguage = Languages.English;
        }
        self.changeCurrentLanguageLabel();
        self.changeCurrentLanguageDictionaries();
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return  NSDateFormatter().monthSymbols[row] as String
        } else {
            return "\(row+1)."
        }
    }
    
    // MARK: - language change protocol

    func pressedChangeLanguage(quotationViewController: QuotationDisplayViewController) {
        switch self.currentLanguage {
        case .English:
            self.currentLanguage = Languages.German;
        case .German:
            self.currentLanguage = Languages.English;
        }
        self.changeCurrentLanguageLabel();
        self.changeCurrentLanguageDictionaries();

        let index = self.currentSortedIndices.indexOf(quotationViewController.currentDateId + "-0")
        
        let nextQuote = self.viewControllerAtIndex(quotationViewController.currentDateId + "-0", index: index!)
        
        var startingViewControllers = [QuotationDisplayViewController]()
        startingViewControllers.append(nextQuote)
        
        pageViewController!.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
}
