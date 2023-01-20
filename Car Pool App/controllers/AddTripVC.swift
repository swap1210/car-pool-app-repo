//
//  AddTripVC.swift
//  Car Pool App
//
//  Created by Areeb on 11/1/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddTripVC: UIViewController {
    var db: Firestore!
    var currentCount = 0
    var currentUser: User? = nil
    var rideDocListener: ListenerRegistration? = nil
    
    @IBOutlet weak var fromTF: UITextField!
    @IBOutlet weak var toAT: UIDatePicker!
    @IBOutlet weak var fromAt: UIDatePicker!
    @IBOutlet weak var toTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // [END setup]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addDocListener()
        getCurrentLoginDetails()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.rideDocListener?.remove()
    }
    
    func addDocListener(){
        self.rideDocListener = self.db.collection(Common.CPcollection).document(Common.document)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                
                if let _rides = data[Common.mainField] as? NSDictionary{
                    self.currentCount = _rides["count"] as! Int
                    //print("Current data: \(_rides.count)")
                }
            }
    }
    
    func getCurrentLoginDetails(){
        self.currentUser = Auth.auth().currentUser
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        let from = self.fromTF.text
        let to = self.toTF.text
        let fromAtVal = self.fromAt.date
        let toAtVal = self.toAT.date
        var passengersArr:[String] = []
        
        if let curPass = self.currentUser?.email{
            passengersArr.append(curPass)
        }
        
        if (from != nil && from != "" && to != nil && to != "" && fromAtVal < toAtVal){
            self.addRide(ride: Ride(from: from!, to: to!, timeFrom: Timestamp(date:fromAtVal), timeTo: Timestamp(date:toAtVal),driver: "", passengers: passengersArr))
        }else{
            var message:String = ""
            
            if (from == nil || from == ""){
                message = "From address is invalid. "
            }
            
            if (to == nil || to == ""){
                message = message + "To address is invalid. "
            }
            
            if (fromAtVal < toAtVal){
                message = message + "from date must be before to date. "
            }
            
            if (fromAtVal < Date()){
                message = message + "from date can't be a past date."
            }
            
            let alertController = UIAlertController(title: "Input Error", message: message, preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        
                        // Code in this block will trigger when OK button tapped.
                        print("Ok button tapped");
                        
                    }
                    
                    alertController.addAction(OKAction)
                    
                    self.present(alertController, animated: true, completion:nil)
        }
    }
     
    func addRide(ride: Ride){
        let ridesRef = db.collection(Common.CPcollection).document(Common.document)
        let countval = self.currentCount+1
        ridesRef.updateData([Common.mainField+".records."+String(countval):ride.toNSDictionary()]){err in
            if let err = err{
                print("Write Error \(err)")
            }else{
                //create chatroom
                self.db.collection(Common.CPcollection).document("chat-1-"+String(countval)).setData([ "sentChats": FieldValue.arrayUnion([]) ], merge: true){chatroomErr in
                    if let chatroomErr = chatroomErr{
                        print("Error while creating chatroom",chatroomErr)
                    }else{
                        //Increment count
                        ridesRef.updateData([Common.mainField+".count" : FieldValue.increment(Int64(1))]){err2 in
                            if let err2 = err2{
                                print("Error while incrementing count", err2)
                            }else{
                                //back to previous screen
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
                
                
            }
        }
    }
}
