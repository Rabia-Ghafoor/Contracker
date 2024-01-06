//
//  EditWorkOrderViewController.swift
//  Contracker
//
//  Created by Rabia on 2020-11-26.
//

import UIKit
import Parse

class EditWorkOrderViewController: UIViewController {

    @IBOutlet weak var editTable: UITableView!
    @IBOutlet weak var comments: UITextView!
    var tasks:[String] = []
    var status:[Int] = []
    var workorderID: String = ""
    var workorderObject: PFObject? = nil
    var jsonArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(Save))
        editTable.delegate = self
        editTable.register(TaskTableViewCell.nib(), forCellReuseIdentifier: TaskTableViewCell.identifier)
        editTable.dataSource = self
        comments.text = "Please enter a comment"
        comments.textColor = UIColor.lightGray
        comments.delegate = self
        self.setupHideKeyboardOnTap()
        
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
                    self.workorderObject = object
                    if let comment = object["Comments"] as? String{
                        self.comments.text = comment
                        self.comments.textColor = UIColor.black
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
    
    @objc
    func Save(){
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        if(self.workorderObject != nil){
            if(self.comments.text != "Please enter a comment" && self.comments.text != ""){
                self.workorderObject!["Comments"] = self.comments.text
            }
            let count = tasks.count
            let cells = self.editTable.visibleCells as! Array<TaskTableViewCell>
            for cell in cells {
                jsonArray.append("{'task':'\(cell.TaskLabel.text as! String)','status':'\(cell.Status.text as! String)'}")
            }
            self.workorderObject!["Tasks"] = jsonArray
            self.workorderObject?.saveInBackground { (succeeded, error)  in
                if (succeeded) {
                    // The object has been saved.
                    print("Saved")
                    guard let pushQuery = PFInstallation.query() as? PFQuery<PFInstallation> else { return }
                    pushQuery.whereKey("user", equalTo: "manager")
                    let push = PFPush.init()
                    push.setQuery(pushQuery)
                    push.setMessage("\(self.workorderObject!["Name"]) Workorder was edited!")
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
                    let alert = UIAlertController(title: "Saved", message: "The changes were saved successfully.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.jsonArray = []
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "Error", message: "There was an error whiel saving changes. Please try again", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    // There was a problem, check error.description
                }
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

//below code is copied from https://stackoverflow.com/a/42380140

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

//coppied code ends here


extension EditWorkOrderViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please enter a comment"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //following code is copied from https://stackoverflow.com/a/48461993
    func setupHideKeyboardOnTap() {
            self.view.addGestureRecognizer(self.endEditingRecognizer())
            self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
        }

        /// Dismisses the keyboard from self.view
        private func endEditingRecognizer() -> UIGestureRecognizer {
            let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
            tap.cancelsTouchesInView = false
            return tap
        }

}

//copied code ends here

extension EditWorkOrderViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped me!")
        /*let cell = editTable.cellForRow(at: indexPath) as! TaskTableViewCell
        print(cell.Status.text)*/
    }
}

extension EditWorkOrderViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = editTable.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        cell.configure(with: true, with: tasks[indexPath.row], with: status[indexPath.row])
        return cell
    }
}
