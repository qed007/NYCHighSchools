import UIKit
import Combine
import MapKit

class SchoolTableController: UITableViewController
{
    var dataModel: DataModel!
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
	  super.viewDidLoad()
		// Do any additional setup after loading the view.
	  
		//  subscribe to the values published by the schools publisher in the DataModel
	  self.dataModel.schoolsPublisher
		.receive(on: DispatchQueue.main, options: nil)
		.sink(receiveCompletion: { completion in
			  //  when the subject sends the completion message reload the table view with the data
		    print("completion in SchoolTableController")
		    self.tableView.reloadData()
		}, receiveValue: { schools in
		    print("received value count: \(schools.count)")
		})
		.store(in: &self.subscriptions)
	  
    }
    
    
}
extension SchoolTableController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	  return self.dataModel.schoolsPublisher.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	  let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolCell", for: indexPath) as! SchoolCell
	  
	  let school = self.dataModel.schoolsPublisher.value[indexPath.row]
	  cell.nameLabel.text = school.schoolName
	  cell.cityLabel.text = school.city
	  cell.numberOfStudentsLabel.text = String(school.numberOfStudents) + " Students"
	  cell.gradesLabel.text = "grades " + school.finalGrades
	  
	  return cell
    }
    
}

extension SchoolTableController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	  if segue.identifier == "ShowSchoolDetail" {
		let indexPath = self.tableView.indexPathForSelectedRow!
		    //		let school = self.dataModel.schools[indexPath.row]
		let school = self.dataModel.schoolsPublisher.value[indexPath.row]
		let detailController = segue.destination as! SchoolDetailController
		detailController.school = school
	  }
    }
    
}


    //  the custom cell subclass to display each school in the table view
class SchoolCell : UITableViewCell
{
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var numberOfStudentsLabel: UILabel!
    @IBOutlet var gradesLabel: UILabel!
    
}




