//
//  NewsViewController.swift
//  Core ML Vision
//
//  Created by Alexander Chudinov on 2019-09-07.
//

import UIKit
import SwiftyJSON
import NaturalLanguageUnderstanding

class NewsViewController: UIViewController {
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var newsStack: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        brandLabel.text = CameraViewController.Globals.Brand
        productLabel.text = CameraViewController.Globals.Product
        let host = "https://newsapi.org/v2/everything?q="+CameraViewController.Globals.Brand+"&apiKey=e443b5309d904830bbe102d3a5af11ff&language=en&sortBy=popularity&pageSize=30&qInTitle="+CameraViewController.Globals.Product
        if let url = URL(string: host){
            var request = URLRequest(url: url, timeoutInterval: 720)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                } else if let p = data {
                    do{
                        let json = try JSON(data: p)
                        for (key,value) in json["articles"]{
                            DispatchQueue.main.async {
                                let titleLabel = UILabel()
                                titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
                                titleLabel.text = value["title"].string
                                self.newsStack.addArrangedSubview(titleLabel)
                            }
                        }
                    } catch {
                        
                    }
                } else {
                    print("No data received in response.")
                }
            }
            task.resume()
        }
        
        let rawhost2 = "https://d.joinhoney.com/v3?query=query%20searchProduct(%24query%3A%20String!%2C%20%24meta%3A%20SearchMetaInput)%20%7B%0A%20%20searchProduct(query%3A%20%24query%2C%20meta%3A%20%24meta)%0A%7D%0A&operationName=searchProduct&variables=%7B%22query%22%3A%22"+CameraViewController.Globals.Product.replacingOccurrences(of: " ", with: "%20")+"%20%22%2C%22meta%22%3A%7B%22walletEnabledFilter%22%3Afalse%7D%7D"
        
        let host2 = rawhost2
        print(host2)
        if let url2 = URL(string: host2){
            var request2 = URLRequest(url: url2, timeoutInterval: 720)
            request2.httpMethod = "GET"
            let task2 = URLSession.shared.dataTask(with: request2) { (data, response, error) in
                if let error = error {
                    print(error)
                } else if let p = data {
                    do{
                        let json = try JSON(data: p)
                        print(json["data"]["searchProduct"]["products"][0]["imageUrlPrimaryTransformed"])
                    } catch {
                        
                    }
                } else {
                    print("No data received in response.")
                }
            }
            task2.resume()
        }
    
    }
    
    func analyzeText( arr: [ String], keyword: String){
        let naturalLanguageUnderstanding = NaturalLanguageUnderstanding(version: "2019-07-12", apiKey: "zoJzrFwHBvke1PvG4jSs8pKD1BHOQ-Rzq0PBFSeb5epv")
        naturalLanguageUnderstanding.serviceURL = "https://gateway.watsonplatform.net/natural-language-understanding/api"
        for x in arr{
            
            let sentiment = SentimentOptions(targets: keyword)
            let features = Features(sentiment: sentiment)
            naturalLanguageUnderstanding.analyze(features: features, text: arr[x]) {
                response, error in
                
                guard let analysis = response?.result else {
                    print(error?.localizedDescription ?? "unknown error")
                    return
                }
                
                print(analysis)
            }
        }
    }


}


