//
//  ImpressumViewController.swift
//  Tiwoli
//
//  Created by thb on 19/04/15.
//  Copyright (c) 2015 thb. All rights reserved.
//

import UIKit

class ImpressumViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let htmlFile = NSBundle.mainBundle().pathForResource("impressum_de", ofType:"html");
        let htmlString : String
        do {
            htmlString = try String(contentsOfFile: htmlFile!, encoding: NSUTF8StringEncoding)
        } catch {
            htmlString = "No quote."
        }
        self.webView.loadHTMLString(htmlString, baseURL: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
