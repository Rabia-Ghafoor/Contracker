//
//  AssignViewController.swift
//  Contracker
//
//  Created by Rabia on 2020-11-26.
//

import UIKit
import Parse

class AssignViewController: UIViewController {

    @IBOutlet weak var assignField: UITextField!
    @IBOutlet weak var tasksTable: UITableView!
    var tasks: [String] = []
    var jsonArray: [String] = []
    var workerUsername = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTable.delegate = self
        tasksTable.dataSource = self
        self.title = "Assign to \(workerUsername)"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent{
            if (tasks.isEmpty || tasks.count == 0){
                print("No tasks to add")
            }else{
                for task in tasks {
                    jsonArray.append("{'task':'\(task)','status':'Due'}")
                }
                let workorder = PFObject(className:"WorkOrders")
                workorder["Name"] = "\(workerUsername):- " + tasks[0]
                workorder["Tasks"] = jsonArray
                workorder["Done"] = false
                workorder["AssignedTo"] = workerUsername
                workorder.saveInBackground { (succeeded, error)  in
                    if (succeeded) {
                        // The object has been saved.
                        print("Saved")
                        //send notification to workerUsername
                        guard let pushQuery = PFInstallation.query() as? PFQuery<PFInstallation> else { return }
                        pushQuery.whereKey("user", equalTo: self.workerUsername)
                        let push = PFPush.init()
                        push.setQuery(pushQuery)
                        push.setMessage("A new workorder was assigned to you!")
                        push.sendInBackground { (succeeded, error)  in
                            if (succeeded) {
                                // The object has been saved.
                                print("Push Notification Sent")
                            } else {
                                print(error?.localizedDescription)
                                print("Error while sending push notification")
                                // There was a problem, check error.description
                            }
                        }
                        
                    } else {
                        print("Error while saving")
                        // There was a problem, check error.description
                    }
                }
            }
            
            
            
            /*var jsonString = ""
             jsonString = "["
             for task in tasks {
                 jsonString.append("{'task':'\(task)','status':'due'},")
             }
             jsonString = String(jsonString.dropLast())
             jsonString.append("]")*/
            
            
            //workorder["AssignedTo"] = "worker1"
            /*workorder.saveInBackground { (succeeded, error)  in
                if (succeeded) {
                    // The object has been saved.
                } else {
                    // There was a problem, check error.description
                }
            }*/
        }
    }
    
    @IBAction func addClicked(_ sender: Any) {
        if (assignField.text != nil && assignField.text != ""){
            tasks.append(assignField.text ?? "error")
            assignField.text = ""
            tasksTable.reloadData()
        }else {
            print("Error")
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

extension AssignViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped me!")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

extension AssignViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tasksTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row] //indexPath.row
        return cell
    }
}

