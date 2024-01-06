//
//  WorkOrdersViewController.swift
//  Contracker
//
//  Created by Rabia on 2020-11-26.
//

import UIKit
import Parse

class WorkOrdersViewController: UIViewController {

    @IBOutlet weak var ordersTable: UITableView!
    var orders: [String] = []
    var ordersID: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        ordersTable.delegate = self
        ordersTable.dataSource = self
        // Do any additional setup after loading the view.
        let query = PFQuery(className:"WorkOrders")
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewWorkOrderSegue" {
            if let indexPath = self.ordersTable.indexPathForSelectedRow {
                let destinationVC = segue.destination as! ViewAWorkOrderViewController
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

extension WorkOrdersViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped me!")
        self.performSegue(withIdentifier: "ViewWorkOrderSegue", sender: self)
    }
}

extension WorkOrdersViewController: UITableViewDataSource{
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
