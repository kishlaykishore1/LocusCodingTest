import UIKit

class DisplayWeatherVC: UIViewController {

    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    @IBOutlet weak var lblWeatherName: UILabel!
    @IBOutlet weak var lblWeatherDescription: UILabel!
   
    var currentData: CurrentWeather?
    var titleString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeaterData()
        setBackButton(isImage: true)
        setNavigationBarImage(for: UIImage(), color: .clear, isTranslucent: true, headingColor: .white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.title = titleString
    }
    
    // MARK: - Helper Methods
    
    override func backBtnTapAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadWeaterData() {
        DispatchQueue.main.async {
            self.temperatureLabel.text = self.currentData?.temperatureString
            self.weatherIconImageView.image = UIImage(systemName: self.currentData?.systemIconNameString ?? "")
            self.feelsLikeTemperatureLabel.text = self.currentData?.feelsLikeTemperatureString
            self.lblWeatherName.text = self.currentData?.weatherName
            self.lblWeatherDescription.text = self.currentData?.weatherDescription
        }
    }

}
