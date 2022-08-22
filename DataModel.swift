import Foundation
import MapKit
import Combine

class DataModel
{
	  //  create a subject to hold the schools parsed from JSON
    var schoolsPublisher = CurrentValueSubject<[School],Error>([])
    
    var subscriptions = Set<AnyCancellable>()
    let url: URL = URL(string: "https://data.cityofnewyork.us/resource/s3k6-pzi2.json")!
    
    func handleData(data: Data) {
	  do {
		    //  convert the data to JSON
		let json = try JSONSerialization.jsonObject(with: data, options: [])
		    //  check whether the json is in the expected format
		guard let schoolsArray = json as? [[String:AnyObject]] else {
		    print("json not in expected format. json structure may have changed")
		    return
		}
		
		    //  loop over each item in the array and convert the json to a local School object
		for schoolJSON in schoolsArray {
			  //  use coalescing operator to set school name to "No School Name" if none was found
		    let schoolName = schoolJSON["school_name"] as? String ?? "No School Name"
		    let city = schoolJSON["city"] as? String ??  "-"
		    let website = schoolJSON["website"] as? String ?? "-"
		    let dbn = schoolJSON["dbn"] as? String ?? "-"
		    
		    let numberOfStudents = Int(schoolJSON["total_students"] as! String)!
		    
		    
		    
		    let coordinate: CLLocationCoordinate2D
		    if let latitudeString = schoolJSON["latitude"],
			 let longitudeString = schoolJSON["longitude"] {
			  let latitude = CLLocationDegrees(latitudeString as! String)!
			  let longitude = CLLocationDegrees(longitudeString as! String)!
			  coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		    } else {
			  coordinate = CLLocationCoordinate2D()
		    }
		    
		    let phoneNumber: String
		    if let phoneNumberString = schoolJSON["phone_number"] as? String {
			  phoneNumber = phoneNumberString
		    } else {
			  phoneNumber = "_"
		    }
		    
		    
		    let sportsArray: [String]
		    if let sportsString = schoolJSON["school_sports"] as? String {
			  sportsArray = sportsString.components(separatedBy: ",")
		    } else {
			  sportsArray = ["-"]
		    }
		    
		    let streetAddress = schoolJSON["primary_address_line_1"] as! String
		    
		    let overviewParagraph = schoolJSON["overview_paragraph"] as! String
		    
		    let finalGrades = schoolJSON["finalgrades"] as! String
		    
			  //  create a new school with values from above
		    let school = School(schoolName: schoolName,
						city: city,
						website: website,
						numberOfStudents: numberOfStudents,
						dbn: dbn,
						coordinate: coordinate,
						sports: sportsArray,
						phoneNumber: phoneNumber,
						streetAddress: streetAddress,
						overviewParagraph: overviewParagraph,
						finalGrades: finalGrades)
			  //  add this new school to the schools publisher
		    self.schoolsPublisher.send(self.schoolsPublisher.value + [school])
		}
		
		
	  } catch let error {
		print("error decoding json: \(error)")
	  }
    }
    
    func getData() {
	  URLSession.shared.dataTaskPublisher(for: self.url)
		.retry(2)
		.sink { completion in
		    print("completion in DataModel URL Session")
		    DispatchQueue.main.async {
			  let schools = self.schoolsPublisher.value
			  let sortedSchools = schools.sorted { $0.schoolName < $1.schoolName }
			  self.schoolsPublisher.send(sortedSchools)
			  self.schoolsPublisher.send(completion: .finished)
		    }
		} receiveValue: { (data: Data, response: URLResponse) in
		    print("receive value of data in URL Session")
		    self.handleData(data: data)
		}
		.store(in: &self.subscriptions)
	  
	  
    }
    
    init() {
	  self.getData()
    }
    
    
}

    //  Custom school object that conforms to MKAnnotation in able to allow the schools to be added to a MKMapView
class School : NSObject, MKAnnotation
{
    let finalGrades: String
    let overViewParagraph: String
    let streetAddress: String
    let phoneNumber: String
    let sports: [String]
    let schoolName: String
    let city: String
    let website: String
    let dbn: String
    let numberOfStudents: Int
	  //  MKAnnotation Properties
    var title: String? {
	  return self.schoolName
    }
    var subtitle: String? {
	  return self.city
    }
    let coordinate: CLLocationCoordinate2D
    
    init(schoolName: String,
	   city: String,
	   website: String,
	   numberOfStudents: Int,
	   dbn: String,
	   coordinate: CLLocationCoordinate2D,
	   sports: [String],
	   phoneNumber: String,
	   streetAddress: String,
	   overviewParagraph: String,
	   finalGrades: String) {
	  self.schoolName = schoolName
	  self.city = city
	  self.website = website
	  self.numberOfStudents = numberOfStudents
	  self.dbn = dbn
	  self.coordinate = coordinate
	  self.sports = sports
	  self.phoneNumber = phoneNumber
	  self.streetAddress = streetAddress
	  self.overViewParagraph = overviewParagraph
	  self.finalGrades = finalGrades
    }
    
}





