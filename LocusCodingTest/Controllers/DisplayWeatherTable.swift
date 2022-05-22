import UIKit

class DisplayWeatherTable: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var updatedData = [WeatherData]()
    var titleString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}
// MARK: - Table View DataSource Methods
extension DisplayWeatherTable: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updatedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherForcastCell", for: indexPath) as! weatherForcastCell
        cell.lblTemperature.text = "Temp: \(String(format: "%.0f", updatedData[indexPath.row].main.temp))"
        cell.lblWeatherCondition.text = updatedData[indexPath.row].weather.first?.main
        return cell
    }
}

// MARK: - Table View Delegates Methods
extension DisplayWeatherTable: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let introVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayWeatherVC") as! DisplayWeatherVC
        guard let currentWeather = CurrentWeather(currentWeatherData: self.updatedData[indexPath.row]) else {
            return
        }
        introVC.titleString = self.titleString
        introVC.currentData = currentWeather
        self.navigationController?.pushViewController(introVC, animated: true)
    }
}
// MARK: - TableView Cell class

class weatherForcastCell: UITableViewCell {
    
    @IBOutlet weak var lblWeatherCondition: UILabel!
    @IBOutlet weak var lblTemperature: UILabel!
}


extension UIViewController {
    public func setNavigationBarImage(for image: UIImage? = nil, color: UIColor = .white, isTranslucent: Bool = false, headingColor: UIColor = .black) {
        
        if let image = image {
            self.navigationController?.navigationBar.shadowImage = image
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        } else{
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        }
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = color
            appearance.backgroundColor = color
            appearance.backgroundImage = image
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : headingColor,NSAttributedString.Key.font: UIFont(name: "Montserrat-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            self.navigationController?.navigationBar.tintColor = color
            self.navigationController?.navigationBar.barTintColor = color
            self.navigationController?.navigationBar.backgroundColor = color
            self.navigationController?.view.backgroundColor = .clear
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : color,NSAttributedString.Key.font: UIFont(name: "Montserrat-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)]
            self.navigationController?.navigationBar.isTranslucent = isTranslucent
        }
    }
    
    
    public func setBackButton(tintColor: UIColor = .white, isImage: Bool = false, _ image: UIImage =  #imageLiteral(resourceName: "ic_BackNavBtn") ) {
        let btn1 = UIButton(type: .custom)
        if isImage {
            if #available(iOS 13.0, *) {
                btn1.setImage(image.withTintColor(tintColor), for: .normal)
            } else {
                btn1.setImage(image, for: .normal)
            }
            btn1.imageView?.contentMode = .scaleAspectFit
            btn1.frame = CGRect(x: 0, y: 0, width: 25, height: 24)
        } else {
            btn1.setTitle("Back", for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        }
        btn1.contentHorizontalAlignment = .left
        btn1.setTitleColor(tintColor, for: .normal)
        btn1.addTarget(self, action: #selector(self.backBtnTapAction), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        let negativeSpacer:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -16
        self.navigationItem.leftBarButtonItems = [negativeSpacer, item1]
    }
    
    @objc func backBtnTapAction(){}
}
