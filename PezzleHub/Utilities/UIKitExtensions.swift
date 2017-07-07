//
//  UIKitExtensions.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

extension UITableView {
    
    func registerCell(_ klass: UITableViewCell.Type) {
        
        let className = stringFromClass(klass)
        let nib = UINib(nibName: className, bundle: nil)
        
        self.register(klass, forCellReuseIdentifier: className)
        self.register(nib, forCellReuseIdentifier: className)
    }
    
    func dequeueReusableCell <T: UITableViewCell> (_ klass: T.Type, indexPath: IndexPath) -> T {
        
        let cellIdentifier = stringFromClass(klass)
        return self.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! T
    }
}

extension UICollectionView {
    
    func registerCell(_ klass: UICollectionViewCell.Type) {
        
        let className = stringFromClass(klass)
        let nib = UINib(nibName: className, bundle: nil)
        
        self.register(klass, forCellWithReuseIdentifier: className)
        self.register(nib, forCellWithReuseIdentifier: className)
    }
    
    func dequeueReusableCell <T: UICollectionViewCell> (_ klass: T.Type, indexPath: IndexPath) -> T {
        
        let cellIdentifier = stringFromClass(klass)
        return self.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! T
    }
}

extension UIStoryboard {
    
    class func instantiateViewController <T: UIViewController>(_ identifier: String, storyboardName: String) -> T {
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
}

extension UIColor {
    
    convenience init(decimalRed red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hexString: String) {
        
        let characterSet = CharacterSet(charactersIn: "#")
        let colorCodeString = hexString.trimmingCharacters(in: characterSet).uppercased() as NSString
        
        if colorCodeString.length != 6 {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        let redString = colorCodeString.substring(with: NSRange(location: 0, length: 2))
        let greenString = colorCodeString.substring(with: NSRange(location: 2, length: 2))
        let blueString = colorCodeString.substring(with: NSRange(location: 4, length: 2))
        

        var red: UInt32 = 0
        var green: UInt32 = 0
        var blue: UInt32 = 0
        
        Scanner(string: redString).scanHexInt32(&red)
        Scanner(string: greenString).scanHexInt32(&green)
        Scanner(string: blueString).scanHexInt32(&blue)
        
        self.init(decimalRed: Int(red), green: Int(green), blue: Int(blue))
    }
}

class PHBarColor {
    
    let backgroundColor: UIColor
    let tintColor: UIColor
    
    init(tint: UIColor, background: UIColor) {
        
        tintColor = tint
        backgroundColor = background
    }
}

extension UINavigationBar {
    
    func setColor(_ color: PHBarColor) {
        
        self.tintColor = color.tintColor
        self.barTintColor = color.backgroundColor
        
        if self.titleTextAttributes != nil {
            self.titleTextAttributes![NSForegroundColorAttributeName] = color.tintColor
            
        } else {
            self.titleTextAttributes = [
                NSForegroundColorAttributeName: color.tintColor
            ]
        }
    }
}

var PHNavigationBarColorKey = "PHNavigationBarColorKey"
var PHNavigationBarHiddenKey = "PHNavigationBarHiddenKey"

extension UINavigationItem {
    
    var navigationBarColor: PHBarColor? {
        set(newValue) {
            objc_setAssociatedObject(self, &PHNavigationBarColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &PHNavigationBarColorKey) as? PHBarColor
        }
    }
    
    var navigationBarHidden: Bool? {
        set(newValue) {
            objc_setAssociatedObject(self, &PHNavigationBarHiddenKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &PHNavigationBarHiddenKey) as? Bool
        }
    }
}

extension UIImage {
    
    func coloredImage(_ color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(.normal)
        
        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        
        context?.clip(to: rect, mask: self.cgImage!)
        
        color.setFill()
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if self.capInsets != UIEdgeInsets.zero {
            return newImage!.resizableImage(withCapInsets: self.capInsets, resizingMode: self.resizingMode)
        }

        return newImage!
    }
    
    func resizedImage(_ newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizeImage!
    }
}
