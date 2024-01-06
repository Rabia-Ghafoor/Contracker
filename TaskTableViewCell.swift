//
//  TaskTableViewCell.swift
//  Contracker
//
//  Created by Rabia on 2020-11-26.
//

import UIKit
import iOSDropDown

class TaskTableViewCell: UITableViewCell {

    static let identifier = "TaskTableViewCell"
    
    static func nib() -> UINib{
         return UINib(nibName: "TaskTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var Status: DropDown!
    @IBOutlet weak var TaskLabel: UILabel!
    func configure(with editable:Bool, with task: String,with currentStatus: Int){
        Status.optionArray = ["Due", "In Progress", "On Hold", "Completed"]
        Status.isEnabled = editable
        Status.selectedIndex = currentStatus
        TaskLabel.text = task
        if(currentStatus != -1){
            Status.text = Status.optionArray[currentStatus]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Status.isSearchEnable = false
        Status.selectedRowColor = .gray 
        // Initialization code
    }
    
}
