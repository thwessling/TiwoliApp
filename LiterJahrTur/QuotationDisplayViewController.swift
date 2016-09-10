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
    func pressedChangeLanguage(_ quotationViewController: QuotationDisplayViewController)
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
        let languageChangeString = NSLocalizedString("quoteLanguageChange", comment: "comment")
        self.quotationLanguageButton.setTitle(quoteLanguageString + languageString +  " (" + languageChangeString + ")", for: UIControlState())
        print(currentDateId)
        super.viewDidLoad()
        
    }
    
    @IBAction func wpClicked(_ sender: UIButton) {
        let escpaedUrl = self.authorWPString.addingPercentEscapes(using: String.Encoding.utf8)
        let url = URL(string: escpaedUrl!)
        UIApplication.shared.openURL(url!)
    }
    
    @IBAction func pressedImage(_ sender: UITapGestureRecognizer) {
        self.quoteSourceClicked(sender)
    }
  
    @IBAction func quoteSourceClicked(_ sender: AnyObject) {
        let escpaedUrl = self.sourceString.addingPercentEscapes(using: String.Encoding.utf8)
        let url = URL(string: escpaedUrl!)
        if let url = url {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    @IBAction func picSourceClicked(_ sender: AnyObject) {
        let escpaedUrl = self.picSourceString.addingPercentEscapes(using: String.Encoding.utf8)
        let url = URL(string: escpaedUrl!)
        UIApplication.shared.openURL(url!)
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
   // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
  //  }
   
    
    
    func shareQuote() {
        let pageString = self.quoteText?.stringByEvaluatingJavaScript(from: "document.documentElement.textContent")
        let author = self.quoteAuthor!.text
        let book = self.book!.text
        let stringToShare = "\"\(pageString!)\" -- \(author!) (\(book!))"
        shareString(stringToShare)
    }
    
    func shareWebsite() {
        shareString("http://literjahrtur.wannauchimmer.de/")
    }
    
    func shareString(_ message: String) {
        let activityView = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        self.present(activityView, animated: true, completion: nil)
    }
    
    
   // func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
   //     if buttonIndex == 0 {
   //         shareQuote()
   //     } else if buttonIndex == 1{
   //         shareWebsite()
   //     }
   // }
    
    @IBAction func quotationLanguageChanged(_ sender: AnyObject) {
        self.languageChangeHandler?.pressedChangeLanguage(self);
    }
    
    
    func pressedShared(_ presentingVC: UIViewController) {
        let actionSheet = UIAlertController(title: NSLocalizedString("shareHeading", comment:""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let quoteAction = UIAlertAction(title: NSLocalizedString("shareQuote", comment:""), style: UIAlertActionStyle.default) {
            (action) in self.shareQuote()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelButton", comment: ""), style: UIAlertActionStyle.cancel) {
            (action) in actionSheet.dismiss(animated: true, completion: nil)
        }
        
        let websiteQuoteAction = UIAlertAction(title: NSLocalizedString("shareWebsite", comment:""), style: UIAlertActionStyle.default) {
            (action) in self.shareWebsite()
        }
        
        actionSheet.addAction(quoteAction)
        actionSheet.addAction(websiteQuoteAction)
        actionSheet.addAction(cancelAction)
//        self.navigationController!.presentViewController(actionSheet, animated: true, completion: nil)
        //self.presentViewController(actionSheet, animated: true, completion: nil)
        presentingVC.present(actionSheet, animated: true, completion: nil)
    }
    
}
