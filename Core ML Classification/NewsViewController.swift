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
                            DispatchQueue.main.async {
                                let titleLabel = UILabel()
                                titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
                                titleLabel.text = value["title"].string
                                self.newsStack.addArrangedSubview(titleLabel)
                            }
                            
                            let keyword = [CameraViewController.Globals.Brand]
                            let str = value["description"].string!
                            let naturalLanguageUnderstanding = NaturalLanguageUnderstanding(version: "2019-07-12", apiKey: "zoJzrFwHBvke1PvG4jSs8pKD1BHOQ-Rzq0PBFSeb5epv")
                            naturalLanguageUnderstanding.serviceURL = "https://gateway.watsonplatform.net/natural-language-understanding/api"
                            
                            var temp = 0.0
                            
                            let sentiment = SentimentOptions(targets: keyword)
                            let features = Features(sentiment: sentiment)
                            let cool = naturalLanguageUnderstanding.analyze(features: features, text: str) {
                                response, error in
                                
                                guard let analysis = response?.result else {
                                    print(error?.localizedDescription ?? "unknown error")
                                    return
                                }
                                
                                if let score = analysis.sentiment?.document?.score{
                                    agg = agg + score
                                    print(agg)
                                    print(score)
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
    }
}
