//
//  QuotationDisplayViewController.swift
//  LiterJahrTur
//
//  Created by thb on 15/04/15.
//  Copyright (c) 2015 thb. All rights reserved.
//

import UIKit


class QuotationDisplayViewController: UIViewController {

    @IBOutlet weak var quoteText: UIWebView?
    @IBOutlet weak var quoteAuthor: UILabel?
    @IBOutlet weak var book: UILabel?
    @IBOutlet weak var source: UIButton?
    @IBOutlet weak var picSource: UIButton?
    @IBOutlet weak var image: UIImageView?
    @IBOutlet weak var headline: UILabel!
    
    
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
    
    override func viewDidLoad() {

//        var url = NSURL()
        self.automaticallyAdjustsScrollViewInsets = false
        self.quoteText?.loadHTMLString(quoteString, baseURL: nil)
        self.quoteAuthor?.text = quoteAuthorString
        self.book?.text = bookString
//        self.source?.text = sourceString
//        self.picSource?.text = picSourceString
        var image = UIImage(named:  imageString + ".jpg")
        self.image?.image = image
        print("Image: \(image), imagestring: \(imageString)")
        self.headline?.text = self.headlineString
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func wpClicked(sender: UIButton) {
        let url = NSURL(string: self.authorWPString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
  
    @IBAction func quoteSourceClicked(sender: AnyObject) {
        let url = NSURL(string: self.sourceString)
        UIApplication.sharedApplication().openURL(url!)

    }   
    
    
    @IBAction func picSourceClicked(sender: AnyObject) {
        let url = NSURL(string: self.picSourceString)
        UIApplication.sharedApplication().openURL(url!)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
   // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
  //  }
   
    
    @IBAction func pressedNextDay(segue: UIStoryboardSegue) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextQuote =
        storyBoard.instantiateViewControllerWithIdentifier("QuotationDisplayViewController") as! QuotationDisplayViewController
        
        self.navigationController!.pushViewController(nextQuote, animated: true)
        
        
        println("Pressed next day")
    }
    
    
    func shareQuote() {
        let pageString = self.quoteText?.stringByEvaluatingJavaScriptFromString("document.documentElement.textContent")
        let author = self.quoteAuthor!.text
        let book = self.book!.text
        var stringToShare = "\"\(pageString!)\" -- \(author) (\(book))"
        shareString(stringToShare)
    }
    
    func shareWebsite() {
        shareString("website")
    }
    
    func shareString(message: String) {
        let activityView = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        self.presentViewController(activityView, animated: true, completion: nil)
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            shareQuote()
        } else {
            shareWebsite()
        }
    }
    
    func pressedShared() {
        let actionSheet = UIAlertController(title: NSLocalizedString("shareHeading", comment:""), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let quoteAction = UIAlertAction(title: NSLocalizedString("shareQuote", comment:""), style: UIAlertActionStyle.Default) {
            (action) in self.shareQuote()
        }
        let websiteQuoteAction = UIAlertAction(title: NSLocalizedString("shareWebsite", comment:""), style: UIAlertActionStyle.Default) {
            (action) in self.shareWebsite()
        }
        
        actionSheet.addAction(quoteAction)
        actionSheet.addAction(websiteQuoteAction)
        self.navigationController!.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
}
