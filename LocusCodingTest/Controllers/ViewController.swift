import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var btnLookup: UIButton!
    
    // MARK: - Variables
    
    var networkWeatherManager = NetworkWeatherManger()
    
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        networkWeatherManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
        btnLookup.layer.borderColor = UIColor.gray.cgColor
        btnLookup.layer.borderWidth = 2
        btnLookup.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Helper Methods
    func isValidCity(cityString: String) -> Bool {
        let cityRegEx = "^[a-zA-Z\u{0080}-\u{024F}\\s\\/\\-\\)\\(\\`\\.\\\"\\']*$"
        let cityTest = NSPredicate(format:"SELF MATCHES %@", cityRegEx)
        return cityTest.evaluate(with: cityString)
    }
    
    // MARK: - Button Action Methods
    @IBAction func btnLookup_Action(_ sender: UIButton) {
        if txtCity.text != "" {
            if Reachability.isConnected() {
                networkWeatherManager.fetchCurrentWeather(for: .cityname(city: txtCity.text?.urlEncoded ?? ""))
            } else {
                showSimpleAlert(title: "Warning", message: "No Network Connection.")
            }
        } else {
            showSimpleAlert(title: "Warning", message: "Please Enter City Name.")
        }
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,shouldChangeCharactersIn range: NSRange,replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range,with: string).trimmed
        
        return isValidCity(cityString: prospectiveText)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        txtCity.resignFirstResponder()
    }
}


// MARK: - Utility methods
extension ViewController {
    func showSimpleAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert,animated: true,completion: nil )
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        //networkWeatherManager.fetchCurrentWeather(for: .coordinate(latitude: latitude, longitude: longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - NetworkWeatherMangerDelegate

extension ViewController: NetworkWeatherMangerDelegate {
    func updateWeatherData(response: Data) {
        do {
            let responseDic = try JSONSerialization.jsonObject(with: response, options: .allowFragments) as? NSDictionary
            if let dataDict = responseDic?.object(forKey: "list") as? [[String: Any]] {
                let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
                let decoder = JSONDecoder()
                let parsedData = try decoder.decode([WeatherData].self, from: jsonData)
                DispatchQueue.main.async {
                    let introVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayWeatherTable") as! DisplayWeatherTable
                    introVC.titleString = self.txtCity.text ?? ""
                    introVC.updatedData = parsedData
                    self.navigationController?.pushViewController(introVC, animated: true)
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
}


extension String {
    
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)!
    }
    
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
}

