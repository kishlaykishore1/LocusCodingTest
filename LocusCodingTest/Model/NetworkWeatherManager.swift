import Foundation
import CoreLocation
import UIKit

protocol NetworkWeatherMangerDelegate: AnyObject {
    func updateWeatherData(response: Data)
}

class NetworkWeatherManger {
    
    weak var delegate: NetworkWeatherMangerDelegate?
    
    public let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        aiv.hidesWhenStopped = true
        aiv.color = .black
        return aiv
    }()
    
    enum RequestType {
        case cityname(city: String)
        case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    }
    
    // Generic method
    func fetchCurrentWeather(for requestType: RequestType) {
        var urlString = ""
        switch requestType {
        case .cityname(let city): urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        case .coordinate(let latitude, let longitude):
            urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        }
        performRequest(withURL: urlString)
    }
    
    fileprivate func performRequest(withURL urlString: String) {
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        activityIndicatorView.center = AppDel.window?.center ?? CGPoint(x: 0, y: 50)
        activityIndicatorView.startAnimating()
        AppDel.window?.addSubview(activityIndicatorView)
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                guard error == nil else {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.removeFromSuperview()
                    return
                }
                let status = httpResponse.statusCode
                if status == 200 {
                    if let data = data {
                        self.delegate?.updateWeatherData(response: data)
                            DispatchQueue.main.async {
                                self.activityIndicatorView.stopAnimating()
                                self.activityIndicatorView.removeFromSuperview()
                            }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.activityIndicatorView.removeFromSuperview()
                        let alert = UIAlertController(title: "Error", message: "You Have Entered an incorrect city name.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        AppDel.window?.rootViewController?.present(alert,animated: true,completion: nil )
                    }
                }
            }
        }
        task.resume()
    }
    
    fileprivate func parseJSON(with data: Data) -> CurrentWeather? {
        let decoder = JSONDecoder()
        do {
            let currentWeatherData = try decoder.decode(WeatherData.self, from: data)
            guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else {
                return nil
            }
            return currentWeather
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
 }
