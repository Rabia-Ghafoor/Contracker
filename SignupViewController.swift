//
//  SignupViewController.swift
//  Contracker
//
//  Created by Rabia on 2021-01-20.
//

import UIKit
import Parse

class SignupViewController: UIViewController {
    @IBOutlet weak var NameField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func SignUp(_ sender: Any) {
        let user = PFUser()
        user["Name"] = NameField.text
        user["Admin"] = false
        user.email = EmailField.text
        user.username = EmailField.text //Parse (the backend) reuires a username and it can be the same as email
        user.password = PasswordField.text
        user.signUpInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "We couln't create the user due to \(error.localizedDescription ).", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    //NSLog("OK Pressed")
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
              // Show the errorString somewhere and let the user try again.
            } else {
                let alert = UIAlertController(title: "Success", message: "User created Successfully.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    self.EmailField.text = ""
                    self.PasswordField.text = ""
                    self.NameField.text = ""
                    //NSLog("OK Pressed")
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
              // Hooray! Let them use the app now.
            }
          }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
