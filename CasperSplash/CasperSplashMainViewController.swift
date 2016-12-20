//
//  CasperSplashMainViewController.swift
//  CasperSplash
//
//  Created by François Levaux on 24.11.16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

class CasperSplashMainViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet var webView: CasperSplashWebView!
    @IBOutlet var softwareTableView: NSTableView!
    @IBOutlet weak var indeterminateProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var continueButton: NSButton?
    @IBOutlet var softwareArrayController: NSArrayController!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var installingLabel: NSTextField!
    //
    @IBOutlet var mainView: CasperSplashMainView!
    @IBOutlet weak var statusView: NSView!
    
    var mainWindowController: CasperSplashController!
    
    var installing: InstallStatus = .Installing {
        didSet {
            switch (installing) {
            case .Installing:
                self.indeterminateProgressIndicator.startAnimation(self)
                self.indeterminateProgressIndicator.isHidden = false
                self.installingLabel.stringValue = "Installing…"
                self.statusLabel.stringValue = ""
                self.continueButton?.isEnabled = false
            case .Error(let message):
                self.indeterminateProgressIndicator.isHidden = true
                self.installingLabel.stringValue = ""
                self.continueButton?.isEnabled = true
                self.statusLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                self.statusLabel.stringValue = message
            case .Success(let message):
                self.indeterminateProgressIndicator.isHidden = true
                self.installingLabel.stringValue = ""
                self.statusLabel.textColor = #colorLiteral(red: 0.2818343937, green: 0.5693024397, blue: 0.1281824261, alpha: 1)
                self.statusLabel.stringValue = message
            }
        }
    }
    
    dynamic var softwareArray = SoftwareArray.sharedInstance.array
    let predicate = NSPredicate.init(format: "displayToUser = true")

    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Do view setup here.
        
        
        mainWindowController = (self.view.window?.windowController)! as! CasperSplashController
        checkSoftwareStatus()
        
        //SoftwareArray.sharedInstance.addObserver(self, forKeyPath: "array", options: .new, context: nil)
        
        // Setup Web View
        
        
        //Preferences.sharedInstance.logFileHandle = FileHandle(forReadingAtPath: Preferences.sharedInstance.jamfLog)
        Preferences.sharedInstance.getPreferencesApplications(&softwareArray)
        
        //let appDelegate = NSApp.delegate as! AppDelegate
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func pressedContinueButton(_ sender: AnyObject) {
        
        let prefs2 = Preferences.sharedInstance.postInstallScript
        prefs2?.execute({ (isSuccessful) in
            if !isSuccessful {
                NSLog("Couldn't execute postInstall Script")
            }
            NSApplication.shared().terminate(self)
        })
        
    }
    
    
    func errorWhileInstalling(_failedSoftwareArray: [Software]) {
        self.installing = .Error("Some applications failed to install. Support has been notified.")
        
        if _failedSoftwareArray.count == 1 {
            if let failedDisplayName = _failedSoftwareArray[0].displayName {
                statusLabel.stringValue = "\(failedDisplayName) failed to install. Support has been notified."
            } else {
                statusLabel.stringValue = "An application failed to install. Support has been notified."
            }
            
        }
        
    }
    
    func doneInstallingCriticalSoftware() {
        continueButton?.isEnabled = true
    }
    func doneInstalling() {
        self.installing = .Success("All applications were installed. Please click continue.")
    }
    
    
    func failedSoftwareArray(_ _softwareArray: [Software]) -> [Software] {
        return _softwareArray.filter({ $0.status == .failed })
    }
    
    func canContinue(_ _softwareArray: [Software]) -> Bool {
        let criticalSoftwareArray = _softwareArray.filter({ $0.canContinue == false })
        return criticalSoftwareArray.filter({ $0.status == .success }).count == criticalSoftwareArray.count
    }
    
    func allInstalled(_ _softwareArray: [Software]) -> Bool {
        let displayedSoftwareArray = _softwareArray.filter({ $0.displayToUser == true })
        return displayedSoftwareArray.filter({ $0.status == .success }).count == displayedSoftwareArray.count
    }
    
    
    func checkSoftwareStatus() {
        if failedSoftwareArray(softwareArray).count > 0 {
            errorWhileInstalling(_failedSoftwareArray: failedSoftwareArray(softwareArray))
        } else if canContinue(softwareArray) {
            doneInstallingCriticalSoftware()
        } else {

        }
        
        if allInstalled(softwareArray) {
            doneInstalling()
        }
    }
    
    
    
    func readTimer() -> Void {
        
        DispatchQueue.global(qos: .background).async {
            if let logFileHandle = Preferences.sharedInstance.logFileHandle {
                if let lines = readLinesFromFile(logFileHandle) {
                    for line in lines {
                        if let software = getSoftwareFromRegex(line) {
                            DispatchQueue.main.async {
                                modifySoftwareArray(fromSoftware: software, softwareArray: &self.softwareArray)
                                
                                self.checkSoftwareStatus()
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    
}
