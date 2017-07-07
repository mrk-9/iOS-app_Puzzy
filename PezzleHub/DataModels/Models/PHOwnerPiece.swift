//
//  PHOwnerPiece.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper

class PHOwnerPiece: PHPiece {
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
    }
}

// MARK: - Concrete pieces
class PHURLPiece: PHOwnerPiece {
    
    var URL: String!
    var imagePath: String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.URL    <- map["url"]
        self.imagePath  <- map["image_path"]
    }
}

class PHPicturePiece: PHOwnerPiece {
    
    var imagePath: String!
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.imagePath  <- map["image_path"]
    }
}

class PHOwnerTextPiece: PHOwnerPiece {
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
    }
}

class PHArticlePiece: PHURLPiece {
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.URL    <- map["file_path"]
    }
}

class PHPDFPiece: PHURLPiece {
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.URL    <- map["file_path"]
    }
}

class PHAudioPiece: PHURLPiece {
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.URL    <- map["file_path"]
    }
}

class PHVideoPiece: PHURLPiece {
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.URL    <- map["file_path"]
    }
}

class PHEPubPiece: PHURLPiece {
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
    }
}
