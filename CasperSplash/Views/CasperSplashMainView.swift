import Foundation
import AppKit

class CasperSplashMainView: NSView {
    
    override func viewWillDraw() {
        self.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        self.layer?.cornerRadius = 10
        self.layer?.shadowOpacity = 0.5
        self.layer?.shadowRadius = 2
        self.layer?.borderWidth = 0.2
    }
}
