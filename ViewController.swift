//
//  ViewController.swift
//  Conchecks
//
//  Created by Rabia on 2020-11-23.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLoggedUser()
    }
    
    func checkLoggedUser(){
        let user = PFUser.current()
        if (user != nil){
            if (user!["Admin"] as! Bool){
                self.performSegue(withIdentifier: "managerSegue", sender: self)
            }else{
                self.performSegue(withIdentifier: "workerSegue", sender: self)
            }
            
        }
    }

    @IBAction func loginClicked(_ sender: Any) {
        print("login clicked")
        PFUser.logInWithUsername(inBackground:emailField.text ?? "empty", password:passwordField.text ?? "empty") {
          (user: PFUser?, error: Error?) -> Void in
          if user != nil {
            // Do stuff after successful login.
            print("Logged in")
            self.emailField.text = ""
            self.passwordField.text = ""
            if (user!["Admin"] as! Bool){
                self.performSegue(withIdentifier: "managerSegue", sender: self  )
            }else{
                self.performSegue(withIdentifier: "workerSegue", sender: self)
            }
          } else {
            let alert = UIAlertController(title: "Error", message: "We couln't log you in due to \(error?.localizedDescription as! String).", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                UIAlertAction in
                //NSLog("OK Pressed")
                self.emailField.text = ""
                self.passwordField.text = ""
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            // The login failed. Check error to see why.
          }
        }
    }
    
}

