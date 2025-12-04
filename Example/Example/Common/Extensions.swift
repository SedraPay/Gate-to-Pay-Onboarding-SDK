import Foundation

extension UIColor {
  
  convenience init(_ hex: String, alpha: CGFloat = 1.0) {
    var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if cString.hasPrefix("#") { cString.removeFirst() }
    
    if cString.count != 6 {
      self.init("ff0000") // return red color for wrong hex input
      return
    }
    
    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: alpha)
  }

}

func decodeJSONFromFile<T: Decodable>(filename: String, type: T.Type) -> T? {
    // Find the file path
    guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
        print("File not found: \(filename).json")
        return nil
    }
    
    do {
        // Read the JSON data from file
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        
        // Decode JSON into the specified type
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(T.self, from: data)
        
        return decodedData
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale.init(identifier: "en-US")
        return dateFormatter.string(from: self)
    }
}




import UIKit

@IBDesignable
extension UIView {

    @IBInspectable var borderColor: UIColor? {
        get { UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor) }
        set { layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
