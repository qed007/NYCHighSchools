import UIKit
import MapKit
import Combine

class MapController : UIViewController, MKMapViewDelegate
{
    var dataModel: DataModel!
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
	  super.viewDidLoad()
		// Do any additional setup after loading the view.
	  
	  self.mapView.addAnnotations(self.dataModel.schoolsPublisher.value)
	  
	  self.mapView.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.7812, longitude: -73.9665),
								 span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
	  let school = view.annotation as! School
	  self.performSegue(withIdentifier: "ShowSchoolDetail", sender: school)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	  if segue.identifier == "ShowSchoolDetail" {
		let schoolDetailController = segue.destination as! SchoolDetailController
		schoolDetailController.school = sender as! School
	  }
    }
}
