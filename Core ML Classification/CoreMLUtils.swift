//
//  CoreMLUtils.swift
//  Core ML Vision
//
//  Created by Nicholas Bourdakos on 2/10/19.
//

import UIKit
import CoreML
import Vision

class CoreMLUtils {
    class func classify(_ image: CGImage, for model: MLModel, completion: @escaping ([VNClassificationObservation]?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let classifier: VNCoreMLModel
            do {
                classifier = try VNCoreMLModel(for: model)
            } catch {
                let description = error.localizedDescription
                let userInfo = [NSLocalizedDescriptionKey: description]
                let error = NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 0, userInfo: userInfo)
                completion(nil, error)
                return
            }
            
            // construct classification request
            let request = VNCoreMLRequest(model: classifier) { request, error in
                if let error = error {
                    let description = error.localizedDescription
                    let userInfo = [NSLocalizedDescriptionKey: description]
                    let error = NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 0, userInfo: userInfo)
                    completion(nil, error)
                    return
                }
                guard let observations = request.results as? [VNClassificationObservation] else {
                    let description = "could not load model"
                    let userInfo = [NSLocalizedDescriptionKey: description]
                    let error = NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 0, userInfo: userInfo)
                    completion(nil, error)
                    return
                }
                completion(observations, nil)
            }
    
            // scale image (yields results in line with vision demo)
            request.imageCropAndScaleOption = .scaleFill
    
            // execute classification request
            do {
                let requestHandler = VNImageRequestHandler(cgImage: image)
                try requestHandler.perform([request])
            } catch {
                let description = "Failed to process classification request: \(error.localizedDescription)"
                let userInfo = [NSLocalizedDescriptionKey: description]
                let error = NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 0, userInfo: userInfo)
                completion(nil, error)
                return
            }
        }
    }
}
