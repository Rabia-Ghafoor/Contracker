//
//  ManagersViewController.swift
//  Contracker
//
//  Created by Rabia on 2020-11-26.
//

import UIKit
import Parse

class ManagersViewController: UIViewController {

    @IBOutlet weak var AssignTable: UITableView!
    var contractors:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(Logout))
        AssignTable.delegate = self
        AssignTable.dataSource = self
        // Do any additional setup after loading the view.
        let query = PFUser.query()
        query?.whereKey("Admin", equalTo: false)
        query?.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                for object in objects {
                    //print(object.objectId as Any)
                    self.contractors.append(object["username"] as! String)
                }
                self.AssignTable.reloadData()
            }
        }
        
        var currentInstallation = PFInstallation.current()
        let currentUser = PFUser.current()
        currentInstallation?.setObject(currentUser!.username, forKey: "user")
        currentInstallation?.saveInBackground()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AssignSegue" {
            if let indexPath = self.AssignTable.indexPathForSelectedRow {
                let controller = segue.destination as! AssignViewController
                controller.workerUsername = contractors[indexPath.row]
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

    @objc
    func Logout(){
        var currentInstallation = PFInstallation.current()
        currentInstallation?.remove(forKey: "user")
        //currentInstallation?.setObject(NSNull(), forKey: "user")
        currentInstallation?.saveInBackground { (succeeded, error)  in
            if (succeeded) {
                // The object has been saved.
                print("Saved")
                PFUser.logOut()
            } else {
                print(error?.localizedDescription)
                print("Error while saving")
                // There was a problem, check error.description
            }
        }
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    
    @IBAction func WorkOrders(_ sender: Any) {
        self.performSegue(withIdentifier: "WorkOrdersSegue", sender: self)
    }
    
}

extension ManagersViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped me!")
        self.performSegue(withIdentifier: "AssignSegue", sender: self)
    }
    
}

extension ManagersViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contractors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AssignTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = contractors[indexPath.row] //indexPath.row
        return cell
    }
}
