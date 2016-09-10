//
//  StartingView.swift
//  LiterJahrTur
//
//  Created by thb on 15/04/15.
//  Copyright (c) 2015 thb. All rights reserved.
//

import UIKit

protocol Shareable {
    func pressedShared(_ presentingVC: UIViewController)
}

class StartingView: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, LanguageButtonHandler {

    @IBOutlet weak var pickerBar: UIView!

    var quotesPerDayDE: [String: JSON]? // = ["1201": 10]
    var quotesPerDayEN: [String: JSON]? // = ["":0]
    var quotesPerDayES: [String: JSON]? // = ["":0]
    
    
    var currentQuotesPerDay: [String: JSON]?
    var currentQuotations: [String: JSON]?
    
    var sortedIndizesDE = [String]()
    var sortedIndizesES = [String]()
    var sortedIndizesEN = [String]()
    var currentSortedIndices = [String]()
    
    var pageViewController: UIPageViewController?;
    var delegate: Shareable?
    var currentId = "null"
    var displayedId = "null"
    
    var quotationsDE: [String: JSON]?
    var quotationsEN: [String: JSON]?
    var quotationsES: [String: JSON]?
    
    var currentLanguage = Languages.English;
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var datePicker: UIPickerView!
    
    @IBOutlet weak var showQuoteButton: UIButton!
    
    @IBOutlet weak var currentLanguageLabel: UILabel!
    
    // MARK: - Data loading and initialization

    // load index for number of quotes per day (day -> number of quotes)
    func readNumberOfQuotes(_ fileName: String, target: inout [String: JSON]?)  {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            let json = JSON(data: data, options: JSONSerialization.ReadingOptions.allowFragments, error: nil)
                target = json.dictionary!
            }
        }
    }
    
    // Load quotations
    func loadDataThreaded() {
        self.loadData("quotations-de", varquoteDict: &self.quotationsDE, indices: &self.sortedIndizesDE)
        self.loadData("quotations-en", varquoteDict: &self.quotationsEN, indices: &self.sortedIndizesEN)
        self.loadData("quotations-es", varquoteDict: &self.quotationsES, indices: &self.sortedIndizesES)
        self.readNumberOfQuotes("date-to-number-of-quotes", target: &self.quotesPerDayDE)
        self.readNumberOfQuotes("date-to-number-of-quotes-en", target: &self.quotesPerDayEN)
        self.readNumberOfQuotes("date-to-number-of-quotes-es", target: &self.quotesPerDayES)
    }
    
    func loadData(_ quoteFile: String, varquoteDict: inout [String: JSON]?, indices: inout [String]) {
        if let path = Bundle.main.path(forResource: quoteFile, ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                
                varquoteDict = JSON(data: data, options: JSONSerialization.ReadingOptions.allowFragments, error: nil).dictionary!
                    var indizes = [String]()
                    for key in varquoteDict!.keys {
                        indizes.append(key)
                    }
                    indizes.sort()
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
        self.segment.sendActions(for: UIControlEvents.valueChanged)
        self.segment.selectedSegmentIndex = -1

        // load current language from settings
        let quotationLanguage = UserDefaults.standard.string(forKey: "quotatationLanguage")
        if let quotationLanguage = quotationLanguage {
            self.currentLanguage = Languages(rawValue: quotationLanguage)!
        } else {
            self.currentLanguage = Languages.English;
        }
        self.changeCurrentLanguageLabel()
        self.changeCurrentLanguageDictionaries()

        // handle notifications
        NotificationCenter.default.addObserver(self, selector: #selector(StartingView.showQuote), name: NSNotification.Name(rawValue: "showQuote"), object: nil)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.currentId != "null" {
                    let dateString = self.currentId.components(separatedBy: "-")[0]
                    let month = Int(dateString.substring(to: dateString.characters.index(dateString.startIndex, offsetBy: 2)))
                    let day = Int(dateString.substring(from: dateString.characters.index(dateString.startIndex, offsetBy: 2)))
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
    
    @IBAction func dateSelectionClicked(_ sender: UISegmentedControl) {
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
        let days = UInt32(self.datePicker.numberOfRows(inComponent: 1))
        let day = Int(arc4random_uniform(days))
        self.datePicker.selectRow(day, inComponent: 1, animated: true)
        print(self.datePicker.selectedRow(inComponent: 0))
        self.currentId = "null"
    }
    
    func showQuote() {
        self.pressedToday()
        showQuoteButton.sendActions(for: UIControlEvents.touchUpInside)
    }
    
    @IBAction func pressedShowQuote(_ sender: AnyObject) {
        let month = String(format: "%02d", self.datePicker.selectedRow(inComponent: 0)+1)
        let day = String(format: "%02d", self.datePicker.selectedRow(inComponent: 1)+1)
  
        let dateString = "\(month)\(day)"
        let id = "\(dateString)-0"
        
        let index =  self.currentSortedIndices.index(of: id)

        self.currentId = id
        
        let nextQuote = self.viewControllerAtIndex(id, index: index!)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        self.pageViewController =
            storyBoard.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        
        self.pageViewController!.dataSource = self
        var startingViewControllers = [QuotationDisplayViewController]()
        startingViewControllers.append(nextQuote)
        
        pageViewController!.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)

        // add share item to navigation bar
        let shareItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(StartingView.pressedShared))
        //self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
        self.pageViewController!.navigationItem.rightBarButtonItem = shareItem
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red: 100.0, green: 149.0, blue: 237.0, alpha: 1.0)
        
        self.navigationController!.pushViewController(pageViewController!, animated: true)
        self.pageViewController?.didMove(toParentViewController: self.navigationController)
    }
    
 
    func pressedShared() {
        self.delegate?.pressedShared(self)
    }
    
    
    func pressedToday() {
        let components = (Calendar.current as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month], from: Date())
        self.datePicker.selectRow(components.month!-1, inComponent: 0, animated: true)
        self.datePicker.selectRow(components.day!-1, inComponent: 1, animated: true)
        self.currentId = "null"
    }
    
    
    
    func getDateForId(_ id: String) -> String {
        let dateString = id.components(separatedBy: "-")[0]
        let month = dateString.substring(to: dateString.characters.index(dateString.startIndex, offsetBy: 2))
        let day = dateString.substring(from: dateString.characters.index(dateString.startIndex, offsetBy: 2))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM dd"
        let date = dateFormatter.date(from: "\(month) \(day)")
        if let date = date {
            dateFormatter.locale = Locale.current
            let dateString = DateFormatter.dateFormat(fromTemplate: "MM dd", options: 0, locale: Locale.current)
            dateFormatter.dateFormat = dateString
            return dateFormatter.string(from: date)
        } else {
            print("Couldn't parse date")
            return "no date"
        }
    }
    
    func viewControllerAtIndex(_ id: String, index: Int) -> QuotationDisplayViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextQuote =
        storyBoard.instantiateViewController(withIdentifier: "QuotationDisplayViewController") as! QuotationDisplayViewController
        
        let dateId = id.components(separatedBy: "-")[0]
        let enumeratorId = id.components(separatedBy: "-")[1]
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
    

    
    func pageViewController(_ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
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
    
    func pageViewController(_ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
    
    @IBAction func unwindToMainScreen(_ segue: UIStoryboardSegue)  {
    }

    /*
        Date picker 
    */
    // MARK: - Date picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2;
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12;
        } else {
            var components = (Calendar.current as NSCalendar).components(NSCalendar.Unit.month, from: Date())
            
            components.month = pickerView.selectedRow(inComponent: 0)+1
            components.day     = 1
            components.year  = 2012
            let specifiedDate: Date = Calendar.current.date(from: components)!

            
            let dayRange = (Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: specifiedDate)
            return dayRange.length
       
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
        case .Spanish:
            self.currentQuotations = self.quotationsES;
            self.currentQuotesPerDay = self.quotesPerDayES;
            self.currentSortedIndices = self.sortedIndizesES;
        }
    }
    
    
    @IBAction func changeLanguagePressed(_ sender: AnyObject) {
        switch self.currentLanguage {
        case .English:
            self.currentLanguage = Languages.German;
        case .German:
            self.currentLanguage = Languages.Spanish;
        case .Spanish:
            self.currentLanguage = Languages.English;
        }
        self.changeCurrentLanguageLabel();
        self.changeCurrentLanguageDictionaries();
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return  DateFormatter().monthSymbols[row] as String
        } else {
            return "\(row+1)."
        }
    }
    
    // MARK: - language change protocol

    func pressedChangeLanguage(_ quotationViewController: QuotationDisplayViewController) {
        switch self.currentLanguage {
        case .English:
            self.currentLanguage = Languages.German;
        case .German:
            self.currentLanguage = Languages.Spanish;
        case .Spanish:
            self.currentLanguage = Languages.English;
        }
        self.changeCurrentLanguageLabel();
        self.changeCurrentLanguageDictionaries();

        let index = self.currentSortedIndices.index(of: quotationViewController.currentDateId + "-0")
        
        let nextQuote = self.viewControllerAtIndex(quotationViewController.currentDateId + "-0", index: index!)
        
        var startingViewControllers = [QuotationDisplayViewController]()
        startingViewControllers.append(nextQuote)
        
        pageViewController!.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
    }
    
}
