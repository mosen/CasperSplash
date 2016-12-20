import Foundation

class JAMFLog {
    
    let handle: FileHandle
    var scanner: Scanner?
    
    init?(path: String) {
        guard let handle = FileHandle(forReadingAtPath: path) else {
            return nil
        }
        
        self.handle = handle
        self.scanner = Scanner()
    }
    
    func read() {
        var logData: Data = self.handle.availableData
        
        while logData.count > 0 {
            self.scanner = Scanner(string: String(data: logData, encoding: .utf8)!)
            
            logData = self.handle.availableData
        }
    }
}
