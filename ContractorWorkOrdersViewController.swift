//
//  ContractorWorkOrdersViewController.swift
//  Contracker
//
//  Created by  Rabia on 2020-11-26.
//

import UIKit
import Parse

class ContractorWorkOrdersViewController: UIViewController {

    @IBOutlet weak var ordersTable: UITableView!
    var orders: [String] = []
    var ordersID: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(Logout))
        ordersTable.delegate = self
        ordersTable.dataSource = self
        // Do any additional setup after loading the view.
        let query = PFQuery(className:"WorkOrders")
        let currentUser = PFUser.current()
        query.whereKey("AssignedTo", equalTo: currentUser?.username)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                for object in objects {
                    print(object.objectId as Any)
                    self.orders.append(object["Name"] as! String)
                    self.ordersID.append(object.objectId as! String)
                }
                self.ordersTable.reloadData()
            }
        }
        
        var currentInstallation = PFInstallation.current()
        currentInstallation?.setObject(currentUser!.username, forKey: "user")
        currentInstallation?.saveInBackground()
    }
    @objc
    func Logout(){
        var currentInstallation = PFInstallation.current()
        currentInstallation?.remove(forKey: "user")
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditWorkSegue"{
            if let indexPath = self.ordersTable.indexPathForSelectedRow {
                let destinationVC = segue.destination as! EditWorkOrderViewController
                destinationVC.workorderID = ordersID[indexPath.row]
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

extension ContractorWorkOrdersViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped me!")
        self.performSegue(withIdentifier: "EditWorkSegue", sender: self)
    }
}

extension ContractorWorkOrdersViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ordersTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = orders[indexPath.row] //indexPath.row
        return cell
    }
}
