//
//  HoneyViewController.swift
//  Core ML Vision
//
//  Created by Alexander Chudinov on 2019-09-07.
//

import UIKit
import SwiftyJSON

class HoneyViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var productRows: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        for product in CameraViewController.Globals.HoneyProducts{
            let productRow = UIStackView()
            productRow.axis = .horizontal
            let productStack = UIStackView()
            
            let productLabel = UILabel()
            productLabel.numberOfLines = 5
            productLabel.text = product["productTitle"]
            let productPrice = UILabel()
            productPrice.text = product["productPrice"]
            
            productStack.addArrangedSubview(productLabel)
            productStack.addArrangedSubview(productPrice)
            
            if let host2 = product["productImage"]{
                if let url2 = URL(string: host2){
                    var request2 = URLRequest(url: url2, timeoutInterval: 720)
                    request2.httpMethod = "GET"
                    let task2 = URLSession.shared.dataTask(with: request2) { (data, response, error) in
                        if let error = error {
                            print(error)
                        } else if let p = data {
                            DispatchQueue.main.async {
                                let imageData = p
                                let productImage = UIImage(data: imageData)
                                let productImageView = UIImageView(image: productImage)
                                productImageView.widthAnchor.constraint(equalToConstant: CGFloat(200)).isActive = true
                                productImageView.contentMode = UIView.ContentMode.scaleAspectFit
                                productRow.addArrangedSubview(productImageView)
                                productRow.addArrangedSubview(productStack)
                                self.productRows.addArrangedSubview(productRow)
                                self.scrollView.layoutIfNeeded()
                                self.productRows.layoutIfNeeded()
                            }
                        } else {
                            print("No data received in response.")
                        }
                    }
                    task2.resume()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}
