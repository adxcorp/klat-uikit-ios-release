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
    
    enum Button {
        static let klatDefaultColor:UIColor = { UIColor.white }()
    }

    enum TableView {
        static let klatDefaultColor:UIColor = { UIColor.black }()
    }
    
    enum TextField {
        static let klatDefaultColor:UIColor = { UIColor.black }()
    }
    
    enum Label {
        static let klatDefaultColor:UIColor = { UIColor.black }()
        static let klatTextGrayColor1:UIColor = { UIColor.init(klatHexCode: "#888888") }()
        static let klatTextGrayColor2:UIColor = { UIColor.init(klatHexCode: "#436666") }()
        static let klatTextGrayColor3:UIColor = { UIColor.init(klatHexCode: "#999999") }()
        static let klatTextWhiteColor:UIColor = { UIColor.init(klatHexCode: "#FFFFFF") }()
        static let klatTextBlackColor1:UIColor = { UIColor.init(klatHexCode: "#1C1B1F") }()
        static let klatTextBlackColor2:UIColor = { UIColor.init(klatHexCode: "#243333") }()
    }
    
    enum TableViewCell {
        static let klatDefaultColor:UIColor = { UIColor.black }()
    }
    
    enum Background {
        static let klatDefaultColor:UIColor = { UIColor.init(klatHexCode: "#00BFBF") }()
        static let buttonColor:UIColor = { UIColor.init(klatHexCode: "#00BFBF") }()
        static let layerGrayColor1:UIColor = { UIColor.init(klatHexCode: "#888888") }()
        static let layerGrayColor2:UIColor = { UIColor.init(klatHexCode: "#EEEEEE") }()
        static let textFieldColor:UIColor = { UIColor.init(klatHexCode: "#F3F3F3") }()
        static let containerColor1:UIColor = { UIColor.init(klatHexCode: "#EEEEEE") }()
        static let containerColor2:UIColor = { UIColor.init(klatHexCode: "#00BFBF") }()
        static let containerColor3:UIColor = { UIColor.init(klatHexCode: "#E9F7F6") }()
    }
    
    enum Border {
        static let klatDefaultColor:UIColor = { UIColor.init(klatHexCode: "#EEEEEE") }()
    }
    
    enum UIView {
        static let klatDefaultColor:UIColor = { UIColor.init(klatHexCode: "#00BFBF") }()
    }
}
