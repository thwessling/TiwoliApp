//
//  QuotationDisplayViewController.swift
//  LiterJahrTur
//
//  Created by thb on 15/04/15.
//  Copyright (c) 2015 thb. All rights reserved.
//

import UIKit


protocol NavigationButtonHandler {
    func pressedNext()
    func pressedPrevious()
}

protocol LanguageButtonHandler {
    func pressedChangeLanguage(quotationViewController: QuotationDisplayViewController)
}

class QuotationDisplayViewController: UIViewController, Shareable {

    @IBOutlet weak var quoteText: UIWebView?
    @IBOutlet weak var quoteAuthor: UILabel?
    @IBOutlet weak var book: UILabel?
    @IBOutlet weak var source: UIButton?
    @IBOutlet weak var picSource: UIButton?
    @IBOutlet weak var image: UIImageView?
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var quotationLanguageButton: UIButton!
    
    
    @IBOutlet weak var textView: UITextView!
    
    var delegateHandler: NavigationButtonHandler?
    var languageChangeHandler: LanguageButtonHandler?
    var quoteString = "No quote yet."
    var quoteAuthorString = ""
    var authorWPString = ""
    var bookString = ""
    var sourceString = ""
    var picSourceString = ""
    var imageString = ""
    var currentId: String?
    var currentIndex: Int?
    var headlineString: String?
    var currentLanguage = Languages.English
    var currentDateId = ""
    
    override func viewDidLoad() {

//        var url = NSURL()
        self.automaticallyAdjustsScrollViewInsets = false
        self.quoteText?.loadHTMLString(quoteString, baseURL: nil)
        

        self.quoteAuthor?.text = quoteAuthorString
        self.book?.text = bookString
//      self.source?.text = sourceString
//      self.picSource?.text = picSourceString
        let image = UIImage(named:  imageString + ".jpg")
        self.image?.image = image
        self.headline?.text = self.headlineString
        let quoteLanguageString = NSLocalizedString("quoteLanguage", comment: "comment")

        
        let languageString = NSLocalizedString(self.currentLanguage.rawValue, comment: "comment")
        
        self.quotationLanguageButton.setTitle(quoteLanguageString + languageString +  " 🔄", forState: UIControlState.Normal)
        print(currentDateId)
        super.viewDidLoad()
        
    }
    
    @IBAction func wpClicked(sender: UIButton) {
        let escpaedUrl = self.authorWPString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: escpaedUrl!)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func pressedImage(sender: UITapGestureRecognizer) {
        self.quoteSourceClicked(sender)
    }
  
    @IBAction func quoteSourceClicked(sender: AnyObject) {
        let escpaedUrl = self.sourceString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: escpaedUrl!)
        if let url = url {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    @IBAction func picSourceClicked(sender: AnyObject) {
        let escpaedUrl = self.picSourceString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: escpaedUrl!)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
   // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
  //  }
   
    
    
    func shareQuote() {
        let pageString = self.quoteText?.stringByEvaluatingJavaScriptFromString("document.documentElement.textContent")
        let author = self.quoteAuthor!.text
        let book = self.book!.text
        let stringToShare = "\"\(pageString!)\" -- \(author!) (\(book!))"
        shareString(stringToShare)
    }
    
    func shareWebsite() {
        shareString("http://literjahrtur.wannauchimmer.de/")
    }
    
    func shareString(message: String) {
        let activityView = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        self.presentViewController(activityView, animated: true, completion: nil)
    }
    
    
   // func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
   //     if buttonIndex == 0 {
   //         shareQuote()
   //     } else if buttonIndex == 1{
   //         shareWebsite()
   //     }
   // }
    
    @IBAction func quotationLanguageChanged(sender: AnyObject) {
        self.languageChangeHandler?.pressedChangeLanguage(self);
    }
    
    
    func pressedShared(presentingVC: UIViewController) {
        let actionSheet = UIAlertController(title: NSLocalizedString("shareHeading", comment:""), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let quoteAction = UIAlertAction(title: NSLocalizedString("shareQuote", comment:""), style: UIAlertActionStyle.Default) {
            (action) in self.shareQuote()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelButton", comment: ""), style: UIAlertActionStyle.Cancel) {
            (action) in actionSheet.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let websiteQuoteAction = UIAlertAction(title: NSLocalizedString("shareWebsite", comment:""), style: UIAlertActionStyle.Default) {
            (action) in self.shareWebsite()
        }
        
        actionSheet.addAction(quoteAction)
        actionSheet.addAction(websiteQuoteAction)
        actionSheet.addAction(cancelAction)
//        self.navigationController!.presentViewController(actionSheet, animated: true, completion: nil)
        //self.presentViewController(actionSheet, animated: true, completion: nil)
        presentingVC.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
}
