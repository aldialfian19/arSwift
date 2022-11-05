//
//  ModelAR.swift
//  arSwift
//
//  Created by Rinaldi Alfian on 05/11/22.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancelLable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        
        self.image = UIImage(named: modelName)!
        
        let fileName = modelName + ".usdz"
        self.cancelLable = ModelEntity.loadModelAsync(named: fileName)
            .sink(receiveCompletion: { loadCompletion in
                // handle the error
                print("Debug: Unable to load modelEntity for modelName: \(self.modelName)")
            }, receiveValue: { modelEntity in
                // get our model entity
                self.modelEntity = modelEntity
                print("Debug: Succesfully load modelEntity for modelName: \(self.modelName)")
            })
    }
}
