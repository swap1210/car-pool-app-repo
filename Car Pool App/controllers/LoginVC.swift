//
//  LoginVC.swift
//  Car Pool App
//
//  Created by Swapnil Patel on 10/20/22.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    var userListener:AuthStateDidChangeListenerHandle?
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var userNameTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            print("Trying to log out")
            try Auth.auth().signOut()
            print("logged out")
        }catch let err {
            print("Error logging out ",err)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = "Login"
        self.userListener = Auth.auth().addStateDidChangeListener { auth, user in
            if(user != nil){
//                print("login user!",user!)
                self.goToLogin()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            if let handle = self.userListener{
                Auth.auth().removeStateDidChangeListener(handle)
            }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBAction func performLogin(_ sender: Any) {
        if let username = userNameTF.text{
            if let psd = passwordTF.text{
                Auth.auth().signIn(withEmail: username, password: psd) { authResult, error in
                    if let e = error{
                        print("Auth results ",e)
                    }
                }
            }
        }
    }
    
    @IBAction func goToNewUser(_ sender: Any) {
        performSegue(withIdentifier: "createUser", sender: self)
    }
    
    func goToLogin(){
        performSegue(withIdentifier: "loginSuccess", sender: self)
    }
}
