//
//  ChatTableVC.swift
//  Car Pool App
//
//  Created by Swapnil Patel on 11/19/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatTableVC: UITableViewController {
    private var db: Firestore!
    var sender: String!
    var ride: Ride!
    var isDriver: Bool!
    
    private var chats: [ChatBubble] = []
    var docRef: DocumentReference?
    private var chatListner: ListenerRegistration? = nil
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressesLabel: UILabel!
    @IBOutlet var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        self.db = Firestore.firestore()
        print("Doc confirmed: ","chat-1-"+String(self.ride.tripID ?? 0))
        self.docRef = self.db.collection(Common.CPcollection).document("chat-1-"+String(self.ride.tripID ?? 0))
        self.loadLabels()
//        tableView.estimatedRowHeight = 150
//        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func loadLabels(){
        self.sender = Auth.auth().currentUser?.email ?? ""
        self.addressesLabel.text = self.ride.from+" - "+self.ride.to
        self.timeLabel.text = self.ride.timeFrom.dateValue().formatted()+" - "+self.ride.timeTo.dateValue().formatted()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.chatListner = self.docRef?.addSnapshotListener({ ss, err in
            guard let document = ss else {
                print("Error fetching document: \(err!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
//            print(data)
            
            //loop to prepare chatbubble array
            self.chats = []
            if let rec = data["sentChats"] as? NSArray{
                for recDic in rec as! [NSDictionary]{
//                    print("Looping ")
                    self.chats.append(ChatBubble(dictionary: recDic))
                }
            }
            
            self.chatTableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.chatListner?.remove()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatbubble", for: indexPath) as! ChatBubbleTableViewCell
        cell.setBubbleAndRide(selfBubble: self.sender == chats[indexPath.row].from, isDriver: self.ride.driver == chats[indexPath.row].from, bubble: chats[indexPath.row])
//        print("Preparing cell")
        return cell
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

    @IBAction func sendMessage(_ sender: UIButton) {
        if let msgTxt = self.sendTextField.text{
//            print("try sending "+msgTxt)
            if msgTxt != ""{
                let tempBubble = ChatBubble(message: msgTxt, at: Timestamp(), from: self.sender).toDictionary()
                self.docRef?.updateData(["sentChats" : FieldValue.arrayUnion([tempBubble])]){err in
                    
                    if let err = err{
                        print("Chat Error ",err)
                        return
                    }
                    
                    self.sendTextField.text = ""
                }
            }
        }
    }
}
