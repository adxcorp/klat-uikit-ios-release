
import UIKit

class KlatImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

extension UIImage {
    
    static func loadImage(from urlString: String, completion: @escaping (UIImage?, Bool) -> Void) {
        
        if let cachedImage = KlatImageCache.shared.object(forKey: urlString as NSString) {
            DispatchQueue.main.async { completion(cachedImage, true) }
            return
        }
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { completion(nil, false) }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                DispatchQueue.main.async { completion(nil, false) }
                return
            }
            KlatImageCache.shared.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async { completion(image, false) }
        }.resume()
    }
    
}
