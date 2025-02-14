
import Foundation

public final class KlatUIKitSDK {
    
    private static var version: String {
        let bundleIdentifier = "com.neptunez.KlatUIKit"
        let uikitVersionKey = "KlatUIKitVersion"
        
        if let bundle = Bundle(identifier: bundleIdentifier),
            let version = bundle.infoDictionary?[uikitVersionKey]
        {
            return "\(version)"
        } else {
            let bundle = Bundle(for: KlatUIKitSDK.self)
            if let version = bundle.infoDictionary?[uikitVersionKey] {
                return "\(version)"
            }
        }
        return "0.0.0"
    }
    
    /// Klat UIKit SDK version string
    public static var versionString: String {
        return KlatUIKitSDK.version
    }
    
}
