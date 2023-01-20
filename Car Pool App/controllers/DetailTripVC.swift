//
//  DetailTripVC.swift
//  Car Pool App
//
//  Created by Swapnil Patel on 11/14/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class DetailTripVC: UIViewController {
    var isDriver:Bool!
    var TripId:Int!
    
    private var rideListner: ListenerRegistration? = nil
    private var currentRide: Ride?
    private var db: Firestore!
    
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var passengerHeader: UILabel!
    @IBOutlet weak var passengerStack: UIStackView!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var openChatBtn: UIButton!
    
    enum BtnTxt: String{
        case plusPassenger = "Add me to trip"
        case minusPassenger = "Remove me from trip"
        case plusDriver = "I'll drive"
        case minusDriver = "I won't drive"
    }
    
    var currentUser: String = ""
    var docRef: DocumentReference?
    override func viewDidLoad() {
        super.viewDidLoad()
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        self.db = Firestore.firestore()
        self.docRef = self.db.collection(Common.CPcollection).document(Common.document)
        // [END setup]
        self.currentUser = Auth.auth().currentUser?.email ?? ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.startRideListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.rideListner?.remove()
    }
    
    func startRideListener(){
        self.rideListner = self.docRef?.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            guard let _rides = (((data[Common.mainField] as! NSDictionary)["records"]  as! NSDictionary)[String(self.TripId)] as? NSDictionary) else{
                print("No ride")
                return
            }
            self.currentRide = Ride(dictionary: _rides)
            self.currentRide?.tripID = self.TripId
            self.loadLabels(ride: Ride(dictionary: _rides))
        }
    }
    
    func loadLabels(ride:Ride){
        self.fromAddressLabel.text = ride.from
        self.toAddressLabel.text = ride.to
        self.fromDateLabel.text = ride.timeFrom.dateValue().formatted()
        self.toDateLabel.text = ride.timeTo.dateValue().formatted()
        
        if ride.driver != ""{
            self.driverLabel.text = ride.driver
        }else{
            self.driverLabel.text = "Not assigned"
        }
        var buttonString = ""
        if (self.isDriver){
            if (ride.driver == self.currentUser){
                buttonString = DetailTripVC.BtnTxt.minusDriver.rawValue
                self.openChatBtn.isHidden = false
            }else{
                buttonString = DetailTripVC.BtnTxt.plusDriver.rawValue
            }
        }else{
            if (ride.passengers.contains(self.currentUser)){
                buttonString = DetailTripVC.BtnTxt.minusPassenger.rawValue
                self.openChatBtn.isHidden = false
            }else{
                buttonString = DetailTripVC.BtnTxt.plusPassenger.rawValue
            }
        }
        
        self.changeButton.setTitle(buttonString, for: .normal)
        var ctr = 1
        self.passengerHeader.text = "Passengers (\(ride.passengers.count)/\(Common.allowedPassengers)):"
        self.passengerStack.subviews.forEach({ $0.removeFromSuperview() })
        ride.passengers.forEach { passengerName in
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
            label.text = " "+String(ctr)+". "+passengerName
            label.font = UIFont.systemFont(ofSize: 15)
            ctr+=1
            self.passengerStack.addArrangedSubview(label)
        }
    }
    
    @IBAction func addOrRemove(_ sender: UIButton) {
        if (self.isDriver){
            if (self.currentRide?.driver == self.currentUser){
                self.docRef?.updateData([Common.mainField+".records."+String(self.TripId)+".driver":""]){err in
                    if let err = err{
                        print("Update failure",err)
                    }else{
                        print("Update sucess to remove")
                        self.changeButton.setTitle(BtnTxt.plusDriver.rawValue,for:.normal)
                        self.openChatBtn.isHidden = false
                    }
                }
            }else{
                self.docRef?.updateData([Common.mainField+".records."+String(self.TripId)+".driver":self.currentUser]){err in
                    if let err = err{
                        print("Update failure",err)
                    }else{
                        print("Update sucess to add")
                        self.changeButton.setTitle(BtnTxt.minusDriver.rawValue,for:.normal)
                        self.createChatDoc()
                        self.openChatBtn.isHidden = false
                    }
                }
            }
        }else{
            if (self.changeButton.titleLabel?.text == "Add me to trip"){
                self.docRef?.updateData([Common.mainField+".records."+String(self.TripId)+".passengers":FieldValue.arrayUnion([self.currentUser])]){err in
                    if let err = err{
                        print("Update failure",err)
                    }else{
                        print("Update sucess")
                        self.changeButton.setTitle(BtnTxt.minusPassenger.rawValue,for:.normal)
                        self.createChatDoc()
                        self.openChatBtn.isHidden = false
                    }
                }
            }else{
                self.docRef?.updateData([Common.mainField+".records."+String(self.TripId)+".passengers":FieldValue.arrayRemove([self.currentUser])]){err in
                    if let err = err{
                        print("Update failure",err)
                    }else{
                        print("Update sucess")
                        self.changeButton.setTitle(BtnTxt.plusPassenger.rawValue,for:.normal)
                        self.openChatBtn.isHidden = true
                    }
                }
            }
            
//            db.collection("cities").document("BJ").setData([ "capital": true ], merge: true)
        }
    }
    
    func createChatDoc(){
        db.collection(Common.CPcollection).document("chat-1-"+String(self.TripId)).setData([ "sentChats": FieldValue.arrayUnion([]) ], merge: true)
    }
    
    
    @IBAction func openChat(_ sender: Any) {
        performSegue(withIdentifier: "goToChatroom", sender:self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ct = segue.destination as? ChatTableVC{
            ct.ride = self.currentRide
            ct.sender = self.currentUser
            ct.isDriver = self.isDriver
        }
    }
}
