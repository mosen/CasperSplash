//
//  CasperSplashWebView.swift
//  CasperSplash
//
//  Created by testpilotfinal on 04/08/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa
import WebKit

class CasperSplashWebView: WebView {
    
    override func awakeFromNib() {
        self.mainFrameURL = Preferences.sharedInstance.htmlAbsolutePath ?? ""
    }
    
    override func viewWillDraw() {
        self.layer?.borderWidth = 1.0
        self.layer?.borderColor = NSColor.lightGray.cgColor
        self.layer?.isOpaque = true
    }
}
