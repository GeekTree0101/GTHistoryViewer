import Foundation
import UIKit

extension UIColor {
    
    static var randomColor: UIColor {
        let vividColorList: [UIColor] = [.vividRed, .vividBlue,
                                         .vividGreen, .vividOrange,
                                         .vividYellow]
        let randIndex: Int = Int(arc4random_uniform(UInt32(vividColorList.count)))
        return vividColorList[randIndex]
    }
    
    static var vividRed: UIColor {
        return UIColor.init(red: 237.0 / 255.0,
                            green: 67.0 / 255.0,
                            blue: 67.0 / 255.0,
                            alpha: 1.0)
    }
    
    static var vividBlue: UIColor {
        return UIColor.init(red: 32.0 / 255.0,
                            green: 119.0 / 255.0,
                            blue: 153.0 / 255.0,
                            alpha: 1.0)
    }
    
    static var vividGreen: UIColor {
        return UIColor.init(red: 48.0 / 255.0,
                            green: 136.0 / 255.0,
                            blue: 102.0 / 255.0,
                            alpha: 1.0)
    }
    
    static var vividOrange: UIColor {
        return UIColor.init(red: 249.0 / 255.0,
                            green: 176.0 / 255.0,
                            blue: 146.0 / 255.0,
                            alpha: 1.0)
    }
    
    static var vividYellow: UIColor {
        return UIColor.init(red: 249.0 / 255.0,
                            green: 230.0 / 255.0,
                            blue: 146.0 / 255.0,
                            alpha: 1.0)
    }
    
    func getColorName() -> String {
        switch self {
        case .vividRed:
            return "VividRed"
        case .vividBlue:
            return "VividBlue"
        case .vividGreen:
            return "VividGreen"
        case .vividYellow:
            return "VividYellow"
        case .vividOrange:
            return "VividOrange"
        default: return "Unknown"
        }
    }
}
