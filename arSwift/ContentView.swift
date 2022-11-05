//
//  ContentView.swift
//  arSwift
//
//  Created by Rinaldi Alfian on 05/11/22.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmed: Model?
    
    private var model: [Model] = {
        // Dynamically get our model filenames
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try?
                filemanager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableModel: [Model] = []
        for fileName in files where fileName.hasSuffix("usdz") {
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            let models = Model(modelName: modelName)
            
            availableModel.append(models)
        }
        return availableModel
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmed: self.$modelConfirmed)
            
            if self.isPlacementEnabled {
                PlacementButtonView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmed: self.$modelConfirmed)
            }else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, model: self.model)
            }
           
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmed: Model?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        if let models = self.modelConfirmed {
            
            if let modelEntity = models.modelEntity {
                print("Debug: adding model to scene - \(models.modelName)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                
                uiView.scene.addAnchor(anchorEntity)
            }else {
                print("Debug: Unnable to load modelEntity for - \(models.modelName)")
            }
            
            
            
            DispatchQueue.main.async {
                self.modelConfirmed = nil
            }
        }
    }
    
}

struct PlacementButtonView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmed: Model?
    
    var body: some View {
        
        HStack{
            // cancel button
            Button(action: {
                print("Debug: cancel")
                self.resetPlacement()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            // confirm button
            Button(action: {
                print("Debug: confirm")
                
                self.modelConfirmed = self.selectedModel
                
                self.resetPlacement()
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    func resetPlacement() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var model: [Model]
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0 ..< self.model.count) {
                    index in
                    Button(action: {print("Debug selected model with name: \(self.model[index].modelName)")
                        
                        self.selectedModel = self.model[index]
                        self.isPlacementEnabled = true
                    }) {
                        Image(uiImage: self.model[index].image)
                            .resizable()
                            .frame(height: 100)
                            .aspectRatio(1/1, contentMode: .fit)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
