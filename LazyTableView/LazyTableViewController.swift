//
//  ViewController.swift
//  LazyTableView
//
//  Created by Godfather on 3/20/17.
//  Copyright © 2017 Godfather. All rights reserved.
//

import UIKit
@objc(LazyTableViewController)
class LazyTableViewController: UITableViewController {

    var entries: [AppRecord] = []
    private let kCustomRowCount = 1
    private let CellIdentifier = "LazyTableCell"
    private let PlaceHolderCell = "PlaceHolderCell"
    
    private var imageDownloadsInProgress: [IndexPath: IconDownloader] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageDownloadsInProgress = [:]
        tableView.tableFooterView = UIView()
    }

    func terminateAllDownloads() {
        let allDownloads = self.imageDownloadsInProgress.values
        for download in allDownloads {
            download.cacelDownload()
        }
        self.imageDownloadsInProgress.removeAll(keepingCapacity: false) // ??
    }
    // Hàm này gọi khi nào?
    deinit {
        self.terminateAllDownloads()
    }
    
    // Support
    private func startIconDownload(appRecord: AppRecord, indexPath: IndexPath) {
        var iconDownloader = self.imageDownloadsInProgress[indexPath]
        if iconDownloader == nil {
            iconDownloader = IconDownloader()
            iconDownloader!.appRecord = appRecord
            iconDownloader!.completionHandler = {
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.imageView?.image = appRecord.appIcon
                self.imageDownloadsInProgress.removeValue(forKey: indexPath)
            }
            self.imageDownloadsInProgress[indexPath] = iconDownloader
            iconDownloader!.startDownload()
        }
        
    }
    private func loadImagesForOnscreenRows() {
        if !self.entries.isEmpty {
            let visiblePaths = self.tableView.indexPathsForVisibleRows!
            for indexpath in visiblePaths {
                let appRecord = entries[indexpath.row]
                if appRecord.appIcon == nil {
                    self.startIconDownload(appRecord: appRecord, indexPath: indexpath)
                }
            }
        }
    }
    
    
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.loadImagesForOnscreenRows()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.loadImagesForOnscreenRows()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.terminateAllDownloads()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.entries.count
        if  count == 0 {
            return kCustomRowCount
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        let nodeCount = self.entries.count
        if nodeCount == 0 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: PlaceHolderCell, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
            
            if nodeCount > 0 {
                let appRecord = self.entries[indexPath.row]
                cell!.textLabel?.text = appRecord.appName
                cell?.detailTextLabel?.text = appRecord.artist
                if appRecord.appIcon == nil {
                    if !self.tableView.isDragging && !self.tableView.isDecelerating {
                        self.startIconDownload(appRecord: appRecord, indexPath: indexPath)
                    }
                    cell?.imageView?.image = UIImage(named: "Placeholder.png")
                } else {
                    cell!.imageView?.image = appRecord.appIcon
                }
            }
        }
        return cell!
    }
    
    

}

