import Foundation
import AppKit

class CasperSplashStatusViewController: NSViewController {
    
    @IBOutlet var label: NSTextField!
    
    var status: InstallStatus = .Installing {
        didSet {
            switch status {
            case .Installing:
                self.label.stringValue = ""
            case .Error:
                self.label.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            case .Success(let message):
                self.label.textColor = #colorLiteral(red: 0.2818343937, green: 0.5693024397, blue: 0.1281824261, alpha: 1)
                self.label.stringValue = message
            }
        }
    }
}
