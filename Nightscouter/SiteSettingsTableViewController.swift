//
//  SiteSettingsTableViewController.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/26/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import UIKit
import NightscouterKit

struct SettingsModelViewModel {
    var title: String
    var subTitle: String?
    var switchOn: Bool?
    var cellIdentifier: Celltype
    var intent: SettingIntent

    enum Celltype: String {
        case cellBasic, cellSubtitle, cellBasicDisclosure
    }
    
    init(title: String, intent: SettingIntent, subTitle: String? = nil, switchOn: Bool? = nil, cellIdentifier: Celltype = .cellBasic){
        self.title = title
        self.subTitle = subTitle
        self.switchOn = switchOn
        self.cellIdentifier = cellIdentifier
        self.intent = intent
    }
    
}

enum SettingIntent: String {
    case PreventLocking, SetDefault, Edit, GoToSafari
}

protocol SiteSettingsDelegate {
    var settings: [SettingsModelViewModel] { get }
    func settingDidChange(setting: SettingsModelViewModel, atIndexPath: NSIndexPath, inViewController: SiteSettingsTableViewController) -> Void
}

class SiteSettingsTableViewController: UITableViewController {
    var delegate: SiteSettingsDelegate?
    var settings: [SettingsModelViewModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = 88.0 // UITableViewAutomaticDimension
        self.tableView.reloadData()
        self.title = LocalizedString.viewTitleSettings.localized
        
        if let delegate =  delegate{
            settings = delegate.settings
        }
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return settings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let setting = settings[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(setting.cellIdentifier.rawValue, forIndexPath: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = setting.title
        cell.detailTextLabel?.text = setting.subTitle
        
        if let switchSetting = setting.switchOn {
            
            let switchControl = UISwitch()
            switchControl.userInteractionEnabled = false
            switchControl.on = switchSetting
            cell.accessoryView = switchControl
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var setting = settings[indexPath.row]
        
        if let switchValue = setting.switchOn {
            setting.switchOn = !switchValue
            settings[indexPath.row] = setting
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            let switchControl = UISwitch()
            switchControl.userInteractionEnabled = false
            switchControl.on = !switchValue
            cell?.accessoryView = switchControl
        }
        
        print("Did select row: \(indexPath.row), which is: \(settings[indexPath.row])")
        
        delegate?.settingDidChange(setting, atIndexPath: indexPath, inViewController: self)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
