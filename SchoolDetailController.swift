import UIKit
import MapKit
import Combine

class SchoolDetailController : UITableViewController
{
    var subscriptions = Set<AnyCancellable>()
    let url: URL = URL(string: "https://data.cityofnewyork.us/resource/f9bf-2cp4.json")!
    
    var school: School!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var phoneButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mathLabel: UILabel!
    @IBOutlet var readingLabel: UILabel!
    @IBOutlet var writingLabel: UILabel!
    @IBOutlet var sportsLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var gradesLabel: UILabel!
    
    override func viewDidLoad() {
	  super.viewDidLoad()
	  
	  
	  self.tableView.estimatedRowHeight = 80
	  self.tableView.rowHeight = UITableView.automaticDimension
	  
	  self.nameLabel.text = self.school.schoolName
	  self.cityLabel.text = self.school.city
	  self.websiteButton.setTitle(self.school.website, for: .normal)
	  self.phoneButton.setTitle(self.school.phoneNumber, for: .normal)
	  self.addressLabel.text = self.school.streetAddress
	  self.overviewLabel.text = self.school.overViewParagraph
	  self.gradesLabel.text = "grades " + self.school.finalGrades
	  
	  var sportsText: String = ""
	  for sport in self.school.sports {
		sportsText += "\(sport)\n"
	  }
	  self.sportsLabel.text = sportsText
	  
	  
	  self.getSATScores()
	  
	  self.mapView.addAnnotation(self.school)
	  self.mapView.region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: self.school.coordinate.latitude, longitude: self.school.coordinate.longitude),
		span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    
    func getSATScores() {
	  
	  URLSession.shared.dataTaskPublisher(for: self.url)
		.sink { completion in
		    print("completion")
		    DispatchQueue.main.async {
			  
		    }
		} receiveValue: { (data: Data, response: URLResponse) in
		    self.handleData(data: data)
		}
		.store(in: &self.subscriptions)
	  
    }
    
    func handleData(data: Data) {
	  do {
		    //  convert the data to a JSON Object
		let json = try JSONSerialization.jsonObject(with: data, options: [])
		    //  make sure the json structure is an array of [String:AnyObject]
		guard let schoolsArray = json as? [[String:AnyObject]] else {
		    return
		}
		
		    //  this crashes occassionally
		let theSchool = schoolsArray.filter { json in
			  //		    (json["school_name"] as! String) == self.school.schoolName.uppercased()
		    (json["dbn"] as! String) == self.school.dbn
		}.first
		    //  make sure a school was found through filtering
		if let filteredSchool = theSchool {
			  //  pull out the sat values from the dictionary
		    let satMath = filteredSchool["sat_math_avg_score"] as! String
		    let satWriting = filteredSchool["sat_writing_avg_score"] as! String
		    let satReading = filteredSchool["sat_critical_reading_avg_score"] as! String
		    DispatchQueue.main.async {
			  self.mathLabel.text = satMath
			  self.writingLabel.text = satWriting
			  self.readingLabel.text = satReading
		    }
		} else {
			  //  set the text labels to indicate the presence of no sat scores
		    DispatchQueue.main.async {
			  self.mathLabel.text = "-"
			  self.writingLabel.text = "-"
			  self.readingLabel.text = "-"
		    }
		}
		
	  } catch let error {
		print("error handling data: \(error)")
	  }
    }
    
}

extension SchoolDetailController {
    
    @IBAction func phoneButtonTapped() {
	  if let phoneCallURL = URL(string: "tel://\(self.school.phoneNumber)") {
		let application:UIApplication = UIApplication.shared
		if (application.canOpenURL(phoneCallURL)) {
		    application.open(phoneCallURL, options: [:], completionHandler: nil)
		}
	  }
    }
    
    @IBAction func emailButtonTapped() {
	  if let url = URL(string: self.school.website) {
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	  }
    }
    
}

extension SchoolDetailController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
	  if indexPath.section == 3 && indexPath.row == 0 {
		return 300
	  } else {
		return UITableView.automaticDimension
	  }
    }
    
}


