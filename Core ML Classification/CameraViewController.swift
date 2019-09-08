/**
 * Copyright IBM Corporation 2017, 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit
import AVFoundation
import Vision
import CoreML
import SwiftyJSON
import NaturalLanguageUnderstanding


class CameraViewController: UIViewController {
    
    struct Globals {
        static var Brand:String = ""
        static var Product:String = ""
    }
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heatmapView: UIImageView!
    @IBOutlet weak var outlineView: UIImageView!
    @IBOutlet weak var focusView: UIImageView!
    @IBOutlet weak var simulatorTextView: UITextView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var updateModelButton: UIButton!
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var alphaSlider: UISlider!
    
    // MARK: - Variable Declarations
    
    let coreMLModel = Model().model
    
    let photoOutput = AVCapturePhotoOutput()
    lazy var captureSession: AVCaptureSession? = {
        guard let backCamera = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: backCamera) else {
                return nil
        }
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        captureSession.addInput(input)
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height)
            // `.resize` allows the camera to fill the screen on the iPhone X.
            previewLayer.videoGravity = .resize
            previewLayer.connection?.videoOrientation = .portrait
            cameraView.layer.addSublayer(previewLayer)
            return captureSession
        }
        return nil
    }()
    
    var editedImage = UIImage()
    var originalConfs = [VNClassificationObservation]()
    var heatmaps = [String: HeatmapImages]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession?.startRunning()
        resetUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let drawer = pulleyViewController?.drawerContentViewController as? ResultsTableViewController else {
            return
        }
        drawer.delegate = self
    }
    
    
    
    // MARK: - Image Classification
    
    func classifyImage(_ image: UIImage, localThreshold: Double = 0.0) {
        guard let croppedImage = cropToCenter(image: image, targetSize: CGSize(width: 224, height: 224)) else {
            return
        }
        
        editedImage = croppedImage
        
        showResultsUI(for: image)
        
        guard let cgImage = editedImage.cgImage else {
            return
        }
        
        CoreMLUtils.classify(cgImage, for: coreMLModel) { classifications, error in
            // Make sure that an image was successfully classified.
            guard let classifications = classifications else {
                return
            }
            
            DispatchQueue.main.async {
                self.push(results: classifications)
                Globals.Product = classifications[0].identifier
                if(classifications[0].identifier == "soylent"){
                    Globals.Brand = "Soylent"
                } else if(classifications[0].identifier == "rice krispie treat"){
                    Globals.Brand = "Kellogg's"
                }
                
                let host = "https://newsapi.org/v2/everything?q="+CameraViewController.Globals.Brand+"%20drink&apiKey=e443b5309d904830bbe102d3a5af11ff&language=en&sortBy=popularity&pageSize=30&qInTitle="+CameraViewController.Globals.Product
                
                if let url = URL(string: host){
                    var request = URLRequest(url: url, timeoutInterval: 720)
                    var agg = 0.0
                    request.httpMethod = "GET"
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        if let error = error {
                            print(error)
                        } else if let p = data {
                            do{
                                let json = try JSON(data: p)
                                for (_,value) in json["articles"]{
                                    let keyword = [CameraViewController.Globals.Brand]
                                    let str = value["description"].string!
                                    let naturalLanguageUnderstanding = NaturalLanguageUnderstanding(version: "2019-07-12", apiKey: "zoJzrFwHBvke1PvG4jSs8pKD1BHOQ-Rzq0PBFSeb5epv")
                                    naturalLanguageUnderstanding.serviceURL = "https://gateway.watsonplatform.net/natural-language-understanding/api"
                                    
                                    let sentiment = SentimentOptions(targets: keyword)
                                    let features = Features(sentiment: sentiment)
                                    let cool = naturalLanguageUnderstanding.analyze(features: features, text: str) {
                                        response, error in
                                        
                                        guard let analysis = response?.result else {
                                            print(error?.localizedDescription ?? "unknown error")
                                            return
                                        }
                                        
                                        if let score = analysis.sentiment?.document?.score{
                                            print(score)
                                            DispatchQueue.main.async {
                                                self.progressView.setProgress(self.progressView.progress+Float(score), animated: true)
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            } catch {
                                
                            }
                        } else {
                            print("No data received in response.")
                        }
                    }
                    print("----------------------------------------")
                    print(CameraViewController.Globals.Brand)
                    print("----------------------------------------")
                    task.resume()
                }
                
                let rawhost2 = "https://d.joinhoney.com/v3?query=query%20searchProduct(%24query%3A%20String!%2C%20%24meta%3A%20SearchMetaInput)%20%7B%0A%20%20searchProduct(query%3A%20%24query%2C%20meta%3A%20%24meta)%0A%7D%0A&operationName=searchProduct&variables=%7B%22query%22%3A%22"+CameraViewController.Globals.Product.replacingOccurrences(of: " ", with: "%20")+"%20%22%2C%22meta%22%3A%7B%22walletEnabledFilter%22%3Afalse%7D%7D"
                
                let host2 = rawhost2
                if let url2 = URL(string: host2){
                    var request2 = URLRequest(url: url2, timeoutInterval: 720)
                    request2.httpMethod = "GET"
                    let task2 = URLSession.shared.dataTask(with: request2) { (data, response, error) in
                        if let error = error {
                            print(error)
                        } else if let p = data {
                            do{
                                let json = try JSON(data: p)
                                for (_,product) in json["data"]["searchProduct"]["products"] {
                                    /*print(product["imageUrlPrimaryTransformed"]["small"])
                                     print(product["title"])
                                     print(product["brand"])
                                     print(product["priceCurrent"].doubleValue / 100.0)*/
                                }
                            } catch {
                                
                            }
                        } else {
                            print("No data received in response.")
                        }
                    }
                    task2.resume()
                }
            }
            
            self.originalConfs = classifications
        }
    }
    
    func startAnalysis(classToAnalyze: String, localThreshold: Double = 0.0) {
        if let heatmapImages = heatmaps[classToAnalyze] {
            heatmapView.image = heatmapImages.heatmap
            outlineView.image = heatmapImages.outline
            return
        }
        
        var confidences = [[Double]](repeating: [Double](repeating: -1, count: 17), count: 17)
        
        DispatchQueue.main.async {
            SwiftSpinner.show("analyzing")
        }
        
        let chosenClasses = originalConfs.filter({ return $0.identifier == classToAnalyze })
        guard let chosenClass = chosenClasses.first else {
            return
        }
        let originalConf = Double(chosenClass.confidence)
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        DispatchQueue.global(qos: .background).async {
            for down in 0 ..< 11 {
                for right in 0 ..< 11 {
                    confidences[down + 3][right + 3] = 0
                    dispatchGroup.enter()
                    let maskedImage = self.maskImage(image: self.editedImage, at: CGPoint(x: right, y: down))
                    guard let cgImage = maskedImage.cgImage else {
                        return
                    }
                    guard let bucketId = UserDefaults.standard.string(forKey: "bucket_id") else {
                        return
                    }
                    CoreMLUtils.classify(cgImage, for: self.coreMLModel) { [down, right] classifications, _ in
                        
                        defer { dispatchGroup.leave() }
                        
                        // Make sure that an image was successfully classified.
                        guard let classifications = classifications else {
                            return
                        }
                        
                        let usbClass = classifications.filter({ return $0.identifier == classToAnalyze })
                        
                        guard let usbClassSingle = usbClass.first else {
                            return
                        }
                        
                        let score = Double(usbClassSingle.confidence)
                        
                        print(".", terminator:"")
                        
                        confidences[down + 3][right + 3] = score
                    }
                }
            }
            dispatchGroup.leave()
            
            dispatchGroup.notify(queue: .main) {
                print()
                print(confidences)
                
                guard let image = self.imageView.image else {
                    return
                }
                
                let heatmap = self.calculateHeatmap(confidences, originalConf)
                let heatmapImage = self.renderHeatmap(heatmap, color: .black, size: image.size)
                let outlineImage = self.renderOutline(heatmap, size: image.size)
                
                let heatmapImages = HeatmapImages(heatmap: heatmapImage, outline: outlineImage)
                self.heatmaps[classToAnalyze] = heatmapImages
                
                self.heatmapView.image = heatmapImage
                self.outlineView.image = outlineImage
                self.heatmapView.alpha = CGFloat(self.alphaSlider.value)
                
                self.heatmapView.isHidden = false
                self.outlineView.isHidden = false
                self.alphaSlider.isHidden = false
                
                SwiftSpinner.hide()
            }
        }
    }
    
    func maskImage(image: UIImage, at point: CGPoint) -> UIImage {
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        image.draw(at: .zero)
        
        let rectangle = CGRect(x: point.x * 16, y: point.y * 16, width: 64, height: 64)
        
        UIColor(red: 1, green: 0, blue: 1, alpha: 1).setFill()
        UIRectFill(rectangle)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func cropToCenter(image: UIImage, targetSize: CGSize) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let offset = abs(CGFloat(cgImage.width - cgImage.height) / 2)
        let newSize = CGFloat(min(cgImage.width, cgImage.height))
        
        let cropRect: CGRect
        if cgImage.width < cgImage.height {
            cropRect = CGRect(x: 0.0, y: offset, width: newSize, height: newSize)
        } else {
            cropRect = CGRect(x: offset, y: 0.0, width: newSize, height: newSize)
        }
        
        guard let cropped = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        let image = UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
        let resizeRect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: resizeRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func dismissResults() {
        push(results: [], position: .closed)
    }
    
    func push(results: [VNClassificationObservation], position: PulleyPosition = .partiallyRevealed) {
        guard let drawer = pulleyViewController?.drawerContentViewController as? ResultsTableViewController else {
            return
        }
        drawer.classifications = results
        pulleyViewController?.setDrawerPosition(position: position, animated: true)
        drawer.tableView.reloadData()
    }
    
    func showResultsUI(for image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        simulatorTextView.isHidden = true
        closeButton.isHidden = false
        captureButton.isHidden = true
        choosePhotoButton.isHidden = true
        updateModelButton.isHidden = true
        focusView.isHidden = true
    }
    
    func resetUI() {
        heatmaps = [String: HeatmapImages]()
        if captureSession != nil {
            simulatorTextView.isHidden = true
            imageView.isHidden = true
            captureButton.isHidden = false
            focusView.isHidden = false
        } else {
            simulatorTextView.isHidden = false
            imageView.isHidden = false
            captureButton.isHidden = true
            focusView.isHidden = true
        }
        heatmapView.isHidden = true
        outlineView.isHidden = true
        alphaSlider.isHidden = true
        closeButton.isHidden = true
        choosePhotoButton.isHidden = false
        updateModelButton.isHidden = false
        dismissResults()
    }
    
    // MARK: - IBActions
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = CGFloat(sender.value)
        self.heatmapView.alpha = currentValue
    }
    
    @IBAction func capturePhoto() {
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    
    
    @IBAction func presentPhotoPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @IBAction func reset() {
        resetUI()
    }
    
    // MARK: - Structs
    
    struct HeatmapImages {
        let heatmap: UIImage
        let outline: UIImage
    }
}

// MARK: - Error Handling
extension CameraViewController {
    func showAlert(_ alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func modelUpdateFail(bucketId: String, error: Error) {
        let error = error as NSError
        var errorMessage = ""
        
        // 0 = probably wrong api key
        // 404 = probably no model
        // -1009 = probably no internet
        
        switch error.code {
        case 0:
            errorMessage = "Please check your Object Storage API key in `Credentials.plist` and try again."
        case 404:
            errorMessage = "We couldn't find a bucket with ID: \"\(bucketId)\""
        case 500:
            errorMessage = "Internal server error. Please try again."
        case -1009:
            errorMessage = "Please check your internet connection."
        default:
            errorMessage = "Please try again."
        }
        
        // TODO: Do some more checks, does the model exist? is it still training? etc.
        // The service's response is pretty generic and just guesses.
        
        showAlert("Unable to download model", alertMessage: errorMessage)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        classifyImage(image)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let photoData = photo.fileDataRepresentation(),
            let image = UIImage(data: photoData) else {
                return
        }
        
        classifyImage(image)
    }
}

// MARK: - TableViewControllerSelectionDelegate
extension CameraViewController: TableViewControllerSelectionDelegate {
    func didSelectItem(_ name: String) {
        startAnalysis(classToAnalyze: name)
    }
}
