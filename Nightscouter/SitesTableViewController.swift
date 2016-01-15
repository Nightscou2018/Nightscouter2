//
//  SitesTableViewController.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/13/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import UIKit
import NightscouterKit

protocol SitesDataSourceProvider: Dateable {
    var sites: [Site] { get }
}

public struct CellIdentifiers {
    public static let SiteTableViewStyleLarge = "siteCellLarge"
}


class SitesTableViewController: UITableViewController, SitesDataSourceProvider {
    
    var sites: [Site] = SitesDataSource().sites
    
    var milliseconds: Double = 0 {
        didSet{
            let str = String(stringInterpolation:LocalizedString.lastUpdatedDateLabel.localized, AppConfiguration.lastUpdatedDateFormatter.stringFromDate(date))
            self.refreshControl?.attributedTitle = NSAttributedString(string:str, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        }
    }
    
    
    /**
     Holds the indexPath of an accessory that was tapped.
     Used for triggering a transition into edit mode.
     */
    var accessoryIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        milliseconds = AppConfiguration.Constant.knownMilliseconds
        // Common setup.
        configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if we should display a form.
        shouldIShowNewSiteForm()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sites.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.SiteTableViewStyleLarge, forIndexPath: indexPath) as! SiteTableViewCell
        
        let model = SiteSummaryModelViewModel(withSite: sites[indexPath.row])
        cell.configure(withDataSource: model!, delegate: model!)
        return cell
    }
    
    // MARK: Table wiew delegate
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let highlightView = UIView()
        highlightView.backgroundColor = NightscouterAssetKit.darkNavColor
        cell?.selectedBackgroundView = highlightView
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete object form data source.
            // AppDataManageriOS.sharedInstance.deleteSiteAtIndex(indexPath.row)
            
            // Delete the row from the data source
            // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // If the site array is empty show add form.
            shouldIShowNewSiteForm()
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        // Pull the site that was moved from the data source at its current (fromIndexPath) location.
        // let site = sites[fromIndexPath.row]
        
        // Remove the site from the data source from its orginal (fromIndexPath) location.
        // AppDataManageriOS.sharedInstance.deleteSiteAtIndex(fromIndexPath.row)
        
        // Insert the site into the data source at its new (toIndexPath) location.
        // AppDataManageriOS.sharedInstance.addSite(site, index: toIndexPath.row)
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        if sites.count == 1 { return false }
        return true
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        accessoryIndexPath = indexPath
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return LocalizedString.tableViewCellRemove.localized
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    
    // MARK: Interface Builder Actions
    
    @IBAction func refreshTable(sender: UIRefreshControl) {
        updateData()
    }
    
    // MARK: Private Methods
    func configureView() -> Void {
        // The following line displys an Edit button in the navigation bar for this view controller.
        navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // Only allow the edit button to be enabled if there are items in the sites array.
        clearsSelectionOnViewWillAppear = true
        
        // Configure table view properties.
        tableView.rowHeight = 240
        tableView.backgroundView = BackgroundView() // TODO: Move this out to a theme manager.
        tableView.separatorColor = NightscouterAssetKit.darkNavColor
        
        // Position refresh control above background view
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.layer.zPosition = tableView.backgroundView!.layer.zPosition + 1
        
        // Make sure the idle screen timer is turned back to normal. Screen will time out.
        //AppDataManageriOS.sharedInstance.shouldDisableIdleTimer = false
        UIApplication.sharedApplication().idleTimerDisabled = false
        
    }
    
    func updateData(){
        // Do not allow refreshing to happen if there is no data in the sites array.
        if sites.isEmpty == false {
            if refreshControl?.refreshing == false {
                refreshControl?.beginRefreshing()
                tableView.setContentOffset(CGPointMake(0, tableView.contentOffset.y-refreshControl!.frame.size.height), animated: true)
            }
            //            for (index, site) in sites.enumerate() {
            //                refreshDataFor(site, index: index)
            //            }
            refreshControl?.endRefreshing()
            
        } else {
            // No data in the sites array. Cancel the refreshing!
            refreshControl?.endRefreshing()
        }
    }
    
    
    func shouldIShowNewSiteForm() {
        // If the sites array is empty show a vesion of the form that does not allow escape.
        if sites.isEmpty{
            // let vc = storyboard?.instantiateViewControllerWithIdentifier(Constants.StoryboardViewControllerIdentifier.SiteFormViewController.rawValue) as! SiteFormViewController
            //self.parentViewController!.presentViewController(vc, animated: true, completion: { () -> Void in
            // println("Finished presenting SiteFormViewController.")
            
            // })
        }
    }
    
    // Attempt to handle an error.
    func presentAlertDialog(siteURL:NSURL, index: Int, error: NSError) {
        
        let alertController = UIAlertController(title: LocalizedString.uiAlertBadSiteTitle.localized, message: String(format: LocalizedString.uiAlertBadSiteMessage.localized, siteURL, error.localizedDescription), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: LocalizedString.generalCancelLabel.localized, style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let retryAction = UIAlertAction(title: LocalizedString.generalRetryLabel.localized, style: .Default) { (action) in
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            //let site = AppDataManageriOS.sharedInstance.sites[indexPath.row]
            //site.disabled = false
            //AppDataManageriOS.sharedInstance.updateSite(site)
            
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        alertController.addAction(retryAction)
        
        let editAction = UIAlertAction(title: LocalizedString.generalEditLabel.localized, style: .Default) { (action) in
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            //let tableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)
            self.accessoryIndexPath = indexPath
//            self.performSegueWithIdentifier(Constants.SegueIdentifier.EditSite.rawValue, sender:tableViewCell)
        }
        alertController.addAction(editAction)
        
        let removeAction = UIAlertAction(title: LocalizedString.tableViewCellRemove.localized, style: .Destructive) { (action) in
            self.tableView.beginUpdates()
            //AppDataManageriOS.sharedInstance.deleteSiteAtIndex(index)
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
        alertController.addAction(removeAction)
        
        alertController.view.tintColor = NightscouterAssetKit.darkNavColor
        
        self.view.window?.tintColor = nil
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
        self.presentViewController(alertController, animated: true) {
            // remove nsnotification observer?
            // ...
        }
    }
    
    
}
