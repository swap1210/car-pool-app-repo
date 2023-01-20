//
//  PassengerDashboardTableVC.swift
//  Car Pool App
//
//  Created by Ly, Bao Thai on 10/21/22.
//

import UIKit
import FirebaseFirestore

class PassengerDashboardTableVC: UITableViewController {

    var db: Firestore!
    var rideArray: [Ride] = []
    var currentCount = 0
    var currentTripId: Int = 0
    private var rideListner: ListenerRegistration? = nil
    var myEmail: String?

    @IBOutlet var passengerView: UITableView!
    //var destinationArray: [String] = []//["Kroger", "UHCL", "Hawk's Landing", "Walmart"]
    //var requesterArray: [String] = []//["John", "Ben", "Maria", "Paul"]
//    @IBOutlet weak var destination: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        
        self.title = "Passenger Dashboard"
        
        populateTrips()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateTrips()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.rideListner?.remove()
    }
    func populateTrips() {
        
        
        self.rideListner = db.collection(Common.CPcollection).document(Common.document)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                self.rideArray = []
                
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                
                if let _rides = data[Common.mainField] as? NSDictionary{
//                    print(_rides)
                    self.currentCount = _rides["count"] as! Int
                    if let _ridesRecords = _rides["records"] as? NSDictionary{
                        for ride in _ridesRecords{
                            var rideS = Ride(dictionary:ride.value as! NSDictionary)
                            rideS.tripID = Int(ride.key as! String)
                            if rideS.timeFrom.dateValue() > Date(){
                                if rideS.passengers.count <= Common.allowedPassengers{
                                    self.rideArray.append(rideS)
                                    //self.destinationArray.append(rideS.to)
                                    //self.destination.text = rideS.from
                                }
                            }
                        }
                    }
                    self.passengerView.reloadData()
//                    print("Current data: \(_rides.count)")
                }
            }
        
//        let end = self.destinationArray.count - 1
//        for i in 0...end {
//            var trip = Trip()
//            trip.destination = destinationArray[i]
//            trip.requester = destinationArray[i]
//            tripArray.append(trip)
//        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverCell", for: indexPath) as! PassengerDashboardTableViewCell

        cell.destination.text = rideArray[indexPath.row].to //destinationArray[indexPath.row]
        cell.driver.text = rideArray[indexPath.row].driver 
        cell.passengers.text = rideArray[indexPath.row].passengers.joined(separator: ", ")
//        cell.itHasMe = rideArray[indexPath.row].passengers.contains(myEmail)
//        cell.destination.text = tripArray[indexPath.row].destination
//        cell.requester.text = tripArray[indexPath.row].requester

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func addTrip(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addTrip", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTripId = rideArray[indexPath.row].tripID!
        performSegue(withIdentifier: "passengerToDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passengerToDetails"{
            if let detailVC = segue.destination as? DetailTripVC{
                detailVC.isDriver = false
                detailVC.TripId = currentTripId
            }
        }
    }
}
