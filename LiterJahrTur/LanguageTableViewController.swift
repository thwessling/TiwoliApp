//
//  LanguageTableViewController.swift
//  Tiwoli
//
//  Created by thb on 29/07/15.
//  Copyright © 2015 thb. All rights reserved.
//

import UIKit


class LanguageTableViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    var items: [String] = ["Deutsch", "Englisch"]
    
    var selectedRow = 0;
    
    @IBOutlet weak var tableView: UITableView!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! 
        
        cell.textLabel?.text = self.items[(indexPath as NSIndexPath).row]
        if ((indexPath as NSIndexPath).row == self.selectedRow) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell;
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Language";
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = (indexPath as NSIndexPath).row;
        self.tableView.reloadData()
    }
    
}
