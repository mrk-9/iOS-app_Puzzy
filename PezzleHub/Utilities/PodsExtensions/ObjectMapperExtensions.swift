//
//  ObjectMapperExtensions.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/27/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper

class PHToOneRelationTransform<T>: TransformType where T: Mappable {
    public func transformFromJSON(_ value: Any?) -> T? {
        let mapper = Mapper<T>()
        return mapper.map(JSONObject: value)
    }

    
    typealias Object = T
    typealias JSON = [String: AnyObject]
    
    func transformFromJSON(_ value: AnyObject?) -> Object? {
        
        let mapper = Mapper<T>()
        return mapper.map(JSONObject: value)
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        
        guard let value = value else {
            return nil
        }
        
        let mapper = Mapper<T>()
        return mapper.toJSON(value) as PHToOneRelationTransform.JSON?
    }
}


class PHToManyRelationTransform<T>: TransformType where T: Mappable {
    public func transformFromJSON(_ value: Any?) -> Array<T>? {
        var result: Object = []
        if let tempArr = value as? [AnyObject] {
            
            let mapper = Mapper<T>()
            for entry in tempArr {
                let model = mapper.map(JSONObject: entry)
                result.append(model!)
            }
        }
        return result
    }



    typealias Object = [T]
    typealias JSON = [AnyObject]
    
    func transformFromJSON(_ value: AnyObject?) -> Object? {
        
        var result: Object = []
        if let tempArr = value as? [AnyObject] {
            
            let mapper = Mapper<T>()
            for entry in tempArr {
                let model = mapper.map(JSONObject: entry)
                result.append(model!)
            }
        }
        return result
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        
        guard let value = value else {
            return []
        }
        
        var result: JSON = []
        let mapper = Mapper<T>()
        
        for entry in value {
            
            let JSONObject = mapper.toJSON(entry)
            result.append(JSONObject as AnyObject)
        }
        return result
    }
}

class PHIntTransform<T>: TransformType {
    public func transformFromJSON(_ value: Any?) -> Int? {
        if let value = value as? String {
            return Int(value)
        }
        return nil
    }

    
    typealias Object = Int
    typealias JSON = String
    
    func transformFromJSON(_ value: AnyObject?) -> Object? {
        
        if let value = value as? String {
            return Int(value)
        }
        return nil
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        
        if let value = value {
            return String(value)
        }
        return nil
    }
}

class PHFloatTransform<T>: TransformType {
    public func transformFromJSON(_ value: Any?) -> Float? {
        if let value = value as? String {
            return Float(value)
        }
        return nil
    }

    
    typealias Object = Float
    typealias JSON = String
    
   public func transformFromJSON(_ value: AnyObject?) -> Object? {
        
        if let value = value as? String {
            return Float(value)
        }
        return nil
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        
        if let value = value {
            return String(value)
        }
        return nil
    }
}
