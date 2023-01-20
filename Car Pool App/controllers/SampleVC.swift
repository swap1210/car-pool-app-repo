//
//  SampleVC.swift
//  Car Pool App
//
//  Created by Swapnil Patel on 11/1/22.
//

import UIKit
import FirebaseFirestore

class SampleVC: UIViewController {
    var db: Firestore!
    var currentCount = 0
    let subGroup = "driverData"
    
    @IBOutlet weak var tripID: UITextField!
    @IBOutlet weak var testField: UILabel!
    @IBOutlet weak var liveData: UILabel!
    @IBOutlet weak var addRecord: UIButton!
    @IBOutlet weak var sampleInputTF: UITextField!
    private var rideListner: ListenerRegistration? = nil
    private var rideListner2: ListenerRegistration? = nil
    private var isDriver = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        
        db = Firestore.firestore()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //adding records lstener
        self.rideListner = db.collection("overall-data").document("rides")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                
                if let _rides = data[self.subGroup] as? NSDictionary{
                    self.currentCount = _rides["count"] as! Int
                    if let _ridesRecords = _rides["records"] as? NSDictionary{
                        for ride in _ridesRecords{
                            let rideS = Ride(dictionary:ride.value as! NSDictionary)
                            self.liveData.text = rideS.from
                        }
                    }
                    print("Current data: \(_rides.count)")
                }
            }
        
        self.rideListner2 = db.collection("overall-data").document("rides").addSnapshotListener { documentSnapshot, err in
            //print("Got",documentSnapshot?.get("TestField"))
            self.testField.text = documentSnapshot?.get("TestField.we") as? String
            if let e = err {
                print("Err ",e)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.rideListner?.remove()
        self.rideListner2?.remove()
    }
    
    @IBAction func createRide(_ sender: UIButton) {
        let tempRide = Ride(from:"From Loc",to:"To Loc",timeFrom:Timestamp(date: Date()),timeTo:Timestamp(date: Date()), driver: "")
        if (addRide(ride: tempRide)){
            print("Write Success")
        }else{
            print("Write Error")
        }
    }
    
    func addRide(ride: Ride)-> Bool{
        let ridesRef = db.collection("overall-data").document("rides")
        var finalResult = false
        ridesRef.updateData([subGroup+".records."+String(self.currentCount+1):ride.toNSDictionary()]){err in
            if let err = err{
                print("Write Error \(err)")
                finalResult =  false
            }else{
                //Increment count
                ridesRef.updateData([self.subGroup+".count" : FieldValue.increment(Int64(1))])
                finalResult = true
            }
        }
        return finalResult
    }
    
    
    @IBAction func removeRecord(_ sender: UIButton) {
        if (sampleInputTF.text! != ""){
            removeRide(index: sampleInputTF.text!)
        }else{
            print("Remove not needed")
        }
    }
    
    func removeRide(index: String){
//        let oldCount = currentCount
        let ridesRef = db.collection("overall-data").document("rides")
        ridesRef.updateData([
            subGroup+".records."+index: FieldValue.delete(),
        ]) { [self] err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                //Decrement count
                ridesRef.updateData([self.subGroup+".count" : FieldValue.increment(Int64(-1))])
                print("Document successfully updated ")
            }
        }
    }
    
    @IBAction func testChatDetail(_ sender: UIButton) {
        self.isDriver = false
        performSegue(withIdentifier: "goToTripDetails", sender: self)
    }
    
    
    @IBAction func openDriver(_ sender: UIButton) {
            self.isDriver = true
            performSegue(withIdentifier: "goToTripDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DetailTripVC{
            dest.TripId = Int(self.tripID.text!)
            dest.isDriver = self.isDriver
        }
    }
}
