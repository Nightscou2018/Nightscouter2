//
//  StorageType.swift
//  Nightscouter
//
//  Created by Peter Ina on 3/15/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public protocol SitesDataSourceProvider: Dateable {
    var sites: [Site] { get }
}
public extension SitesDataSourceProvider {
    var milliseconds: Double {
        return AppConfiguration.Constant.knownMilliseconds.inThePast
    }
}

/**
 Storage location
 
 - LocalKeyValueStore: NSUserDefaults.
 - iCLoudKeyValueStore: NSUbiquitousKeyValueStore.
 - CloudKit: Cloud kit records.
 */
public enum StorageLocation: String {
    case LocalKeyValueStore, iCLoudKeyValueStore, CloudKit
}

// move to a protocol for storage conformance
public protocol SiteStoreType {
    ///
    /// Storage location type.
    ///
    var storageLocation: StorageLocation { get }
    ///
    /// Deliver all the sites from storage.
    ///
    var sites: [Site] { get }
    ///
    /// Create a new site and add it to the storage location.
    ///
    /// - parameter site: A fully formed site.
    /// - returns: True if things were successful.
    ///
    func createSite(site: Site, atIndex index: Int?) -> Bool
    ///
    /// Update a specific site in storage.
    ///
    /// - parameter site: A fully formed site.
    /// - returns: True if things were successful.
    ///
    func updateSite(site: Site)  ->  Bool
    ///
    /// Delete a site from storage.
    ///
    /// - parameter atIndex: Index of a site in the storage array.
    /// - returns: True if things were successful.
    ///
    func deleteSite(site: Site) -> Bool
    ///
    /// Last viewed site.
    ///
    var lastViewedSite: Site? { get }
    ///
    /// Last Viewed Site Index
    ///
    var lastViewedSiteIndex: Int { set get }
    ///
    /// Handle payload received through `WatchConnectivity`.
    ///
    /// - parameter payload: The application context dictionary received from the counterpart app.
    ///
    func handleApplicationContextPayload(payload:[String: AnyObject])
    ///
    /// Remove all sites from the store.
    /// - returns Bool: True if things were successful.
    ///
    func clearAllSites() -> Bool
    ///
    /// Save all site data to long-term storage.
    /// -returns Bool: True if things were successful.
    ///
    func saveData(dictionary: [String: AnyObject]) -> (savedLocally: Bool, updatedApplicationContext: Bool)
    ///
    /// Load all site data from long-term storage
    /// -returns Bool: True if things were successful.
    ///
    func loadData() -> [Site]?
}

public extension SiteStoreType {
    ///
    /// Uses the last viewed site index (Int) to fetch a site from the store.
    ///
    var lastViewedSite: Site? {
        return sites[lastViewedSiteIndex]
    }
}

public protocol SessionManagerType {
    /// The store to interact with.
    var store: SiteStoreType? { get set }
    ///
    /// Send the updated application context payload to the counterpart app.
    ///
    /// - parameter applicationContext: The fresh application context payload.
    ///
    func updateApplicationContext(applicationContext: [String : AnyObject]) throws
    /// Start the WatchConnectivity session.
    ///
    /// Call this method after initialization to send/receive payload between the counterparts.
    ///
    func startSession()
    
    #if os(watchOS)
    ///
    ///
    ///
    func requestCompanionAppUpdate()
    #endif
}