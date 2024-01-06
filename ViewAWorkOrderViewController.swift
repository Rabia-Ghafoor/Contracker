//
//  ViewAWorkOrderViewController.swift
//  Contracker
//
//  Created by Rabia on 2020-11-26.
//

import UIKit
import Parse

class ViewAWorkOrderViewController: UIViewController {

    @IBOutlet weak var editTable: UITableView!
    @IBOutlet weak var comments: UITextView!
    var tasks:[String] = []
    var status:[Int] = []
    var workorderID: String = ""
    var jsonArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editTable.delegate = self
        editTable.register(TaskTableViewCell.nib(), forCellReuseIdentifier: TaskTableViewCell.identifier)
        editTable.dataSource = self
        comments.isEditable = false
        
        let query = PFQuery(className:"WorkOrders")
        let currentUser = PFUser.current()
        query.whereKey("objectId", equalTo: workorderID)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                if let object = objects[0] as? PFObject{
                    if let comment = object["Comments"] as? String{
                        self.comments.text = comment
                        self.comments.textColor = UIColor.black
                    }else{
                        self.comments.text = "No Comment Found!"
                        self.comments.textColor = UIColor.gray
                
                    }
                    if let tasksJSON = object["Tasks"] as? [String]{
                        for task in tasksJSON{
                            //print(task.replacingOccurrences(of: "'", with: "\""))
                            let taskObject = task.replacingOccurrences(of: "'", with: "\"").toJSON() as? [String:AnyObject]
                            self.tasks.append(taskObject?["task"] as! String)
                            var statusIndex:Int = -1
                            switch taskObject?["status"] as! String {
                            case "Due":
                                statusIndex = 0
                            case "In Progress":
                                statusIndex = 1
                            case "On Hold":
                                statusIndex = 2
                            case "Completed":
                                statusIndex = 3
                            default:
                                statusIndex = -1
                            }
                            print(statusIndex)
                            self.status.append(statusIndex)
                        }
                        print(self.tasks)
                        self.editTable.reloadData()
                    }
                }
            }
        }
        // Do any additional setup after loading the view.
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
    
extension ViewAWorkOrderViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped me!")
        /*let cell = editTable.cellForRow(at: indexPath) as! TaskTableViewCell
        print(cell.Status.text)*/
    }
}

extension ViewAWorkOrderViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = editTable.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        cell.configure(with: false, with: tasks[indexPath.row], with: status[indexPath.row])
        return cell
    }
}

