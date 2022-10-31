//
//  TaskCell.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/26/22.
//

import UIKit

protocol TaskCellDelegate{
    func didTapOnEdit(task: TaekwonTask)
    func didTapOnCopy(task: TaekwonTask)
    func didTapOnDelete(task: TaekwonTask, indexPath: IndexPath)
    func didTapOnCompleteBtn(task: TaekwonTask)
}

class TaskCell: UITableViewCell {

    @IBOutlet var icon: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var expandedView: UIView!
    @IBOutlet var btnCompleted: UIButton!
    
    var taskCellDelegate: TaskCellDelegate?
    var currentTask: TaekwonTask!
    var currentIndexPath: IndexPath!
    
    func configureCell(_ task: TaekwonTask,_ indexPath: IndexPath, delegate: TaskCellDelegate?){
        currentTask = task
        taskCellDelegate = delegate
        lblTitle.text = task.title
        lblSubtitle.text = task.description
        updateCellStatus(task: task)
        currentIndexPath = indexPath
    }
    
    func updateCellStatus(task: TaekwonTask){
        if task.cellExpanded {
            expandedView.isHidden = false
            lblSubtitle.isHidden = false
        } else{
            expandedView.isHidden = true
            lblSubtitle.isHidden = true
        }
        
        if currentTask.taskCompleted {
            icon.tintColor = UIColor(named: "tdGold")
            lblTitle.textColor = UIColor(named: "tdRed")
            lblSubtitle.textColor = UIColor(named: "tdRed")
            btnCompleted.setImage(UIImage(systemName: "trophy.fill"), for: .normal)
            btnCompleted.tintColor = UIColor(named: "tdGold")
        } else {
            icon.tintColor = .black
            lblTitle.textColor = .black
            lblSubtitle.textColor = .black
            btnCompleted.setImage(UIImage(systemName: "trophy"), for: .normal)
            btnCompleted.tintColor = .black
        }
    }
    
    @IBAction func completeBtnPressed(_ sender: Any) {
        currentTask.taskCompleted = !currentTask.taskCompleted
        if let delegate = self.taskCellDelegate{
            delegate.didTapOnCompleteBtn(task: currentTask)
        }
        updateCellStatus(task: currentTask)
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        if let delegate = self.taskCellDelegate{
            delegate.didTapOnEdit(task: currentTask)
        }
    }
    
    @IBAction func copyBtnPressed(_ sender: Any) {
        if let delegate = self.taskCellDelegate{
            delegate.didTapOnCopy(task: currentTask)
        }
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        if let delegate = self.taskCellDelegate{
            delegate.didTapOnDelete(task: currentTask, indexPath: currentIndexPath)
        }
    }
}
