//
//  OverAllNC.swift
//  Car Pool App
//
//  Created by Swapnil Patel on 11/1/22.
//

import UIKit
import FirebaseAuth

class OverAllNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc
    func rightHandAction(){
                try? Auth.auth().signOut()
    }
    
}
