//
//  AppDelegate.swift
//  LazyTableView
//
//  Created by Godfather on 3/20/17.
//  Copyright © 2017 Godfather. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NSURLConnectionDataDelegate {

    var window: UIWindow?
    let TopPaidAppsFeed =
    "http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml"
    
    private var queue: OperationQueue?
    private var parser: ParseOperation!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let urlRequest = URLRequest(url: URL(string: TopPaidAppsFeed)!)
        let sessionTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let actualError = error as NSError? {
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    var isATSError: Bool = false
                    if #available(iOS 9.0, *) {
                        isATSError = actualError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection
                    }
                    if isATSError {
                        abort()
                    } else {
                        self.handleError(actualError)
                    }
                }
            } else {
                self.queue = OperationQueue()
                self.parser = ParseOperation(data: data!)
                self.parser.errorHandler = {[weak self] (parseError) in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self?.handleError(parseError)
                    }
                }
                
                self.parser.completionBlock = {[weak self] in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let recordList = self?.parser.appRecordList {
                        DispatchQueue.main.async {
                            let rootViewController = (self?.window!.rootViewController as! UINavigationController?)?.topViewController as! LazyTableViewController
                            rootViewController.entries = recordList
                            rootViewController.tableView.reloadData()
                        }
                    }
                    self?.queue = nil
                }
                self.queue?.addOperation(self.parser)
            }
        }
        sessionTask.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return true
    }
    
    func handleError(_ error: Error) {
        let errorMessage = error.localizedDescription
        let alert = UIAlertController(title: "Cannot Show Top Paid Apps",
                                      message: errorMessage,
                                      preferredStyle: .actionSheet)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // Do something
        }
        alert.addAction(OKAction)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

