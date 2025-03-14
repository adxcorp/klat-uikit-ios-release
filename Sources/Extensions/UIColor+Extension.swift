import UIKit

extension UIColor {
    
    convenience init(klatHexCode: String, klatAlpha: CGFloat = 1.0) {
        var hexFormatted: String = klatHexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: klatAlpha)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    static let klatPrimaryColor = UIColor.init(klatHexCode: "#00BFBF")
    static let klatWhiteColor = UIColor.init(klatHexCode: "#FFFFFF")
    static let klatDarkTealColor = UIColor.init(klatHexCode: "#436666")
    static let klatLightMintColor = UIColor.init(klatHexCode: "#E9F7F6")
    static let klatRedColor = UIColor.red
    static let klatBrightRedColor = UIColor.init(klatHexCode: "#F53D3D")
    static let klatVividBlueColor = UIColor.init(klatHexCode: "#5D81FF")
    static let klatClearColor = UIColor.clear
    
    enum KlatBlackColors {
        static let blackColor1:UIColor = UIColor.black
        static let blackColor2:UIColor = { UIColor.init(klatHexCode: "#1C1B1F") }()
        static let blackColor3:UIColor = { UIColor.init(klatHexCode: "#243333") }()
    }
    
    enum KlatGrayColors {
        static let grayColor1:UIColor = { UIColor.init(klatHexCode: "#888888") }()
        static let grayColor2:UIColor = { UIColor.init(klatHexCode: "#999999") }()
        static let grayColor3:UIColor = { UIColor.init(klatHexCode: "#F3F3F3") }()
        static let grayColor4:UIColor = { UIColor.init(klatHexCode: "#EEEEEE") }()
    }
    
}
