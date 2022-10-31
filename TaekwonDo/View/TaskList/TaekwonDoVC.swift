//
//  TaekwonDoVC.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/26/22.
//

import UIKit

class TaekwonDoVC: UIViewController {
    
    @IBOutlet weak var navBarView: NavBarView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var emptyTaskListView: UIView!
    @IBOutlet weak var lblEmptyTitle: UILabel!
    
    var viewModel: TaekwonTaskViewModel = TaekwonTaskViewModel()
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarView.layer.addShadow()
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.register(UINib(nibName: "TaskCell", bundle: .main), forCellReuseIdentifier: "TaskCell")
        taskTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        navBarView.btnSort.addTarget(self, action: #selector(sortBtnPressed(_:)), for: .touchUpInside)
        navBarView.btnAddItem.addTarget(self, action: #selector(addTaskBtnPressed(_:)), for: .touchUpInside)
        sortList()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if traitCollection.userInterfaceStyle == .light{
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
    //MARK: - Actions
    @objc func addTaskBtnPressed(_ sender: Any){
        let tintColor: UIColor = (traitCollection.userInterfaceStyle == .light) ? .black : .white
        self.navBarView.imgAddItem.tintColor = tintColor
        self.navBarView.lblAddItem.textColor = tintColor
        showTaskDetailsView(.new)
    }
    
    //MARK: - Sort Functions
    @objc func sortBtnPressed(_ sender: UIButton){
        let tintColor: UIColor = (traitCollection.userInterfaceStyle == .light) ? .black : .white
        self.navBarView.imgSort.tintColor = tintColor
        self.navBarView.lblSort.textColor = tintColor
        
        if let navVC = self.navigationController{
            let sourceView = sender.convert(sender.bounds, to: navVC.view)
            let dropdown = DropDownView(sourceView: sourceView, customCellName: "", direction: .ArrowDown, maxWidth: 150, maxHeight: 45 * CGFloat(TaekwonTaskViewModel.SortOption.allCases.count), bgColor: tintColor, cornerRadias: 12, autoDismiss: true, addShadow: true)
            dropdown.delegate = self
            dropdown.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            dropdown.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navVC.present(dropdown, animated: false, completion: nil)
        }
    }
    
    func sortList(){
        viewModel.sortList()
        lblHeader.text = viewModel.currentSortOption.rawValue
        taskTableView.reloadData()
        showOrHideEmptyTaskView()
    }
    
    //MARK: - Navigation Functions
    func showTaskDetailsView(_ taskType: TaskType, _ task: TaekwonTask? = nil){
        let detailsView = DetailsView()
        detailsView.currentTask = task
        detailsView.currentTaskType = taskType
        detailsView.delegate = self
        detailsView.frame = self.view.bounds
        self.view.addSubview(detailsView)
        detailsView.showViewWithAnimation()
    }
    
    func showOrHideEmptyTaskView(){
        lblEmptyTitle.text = viewModel.currentSortOption.emptyTaskListTitle()
        if viewModel.filteredTasks.isEmpty{
            taskTableView.isHidden = true
            emptyTaskListView.isHidden = false
        } else {
            taskTableView.isHidden = false
            emptyTaskListView.isHidden = true
        }
    }
}

// MARK: - TableView Delegate and Data Methods
extension TaekwonDoVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.configureCell(viewModel.filteredTasks[indexPath.row], indexPath, delegate: self)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = viewModel.filteredTasks[indexPath.row]
        task.cellExpanded = !task.cellExpanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

//MARK: - Task Table View Cell Delegate
extension TaekwonDoVC: TaskCellDelegate{
    func didTapOnEdit(task: TaekwonTask) {
        showTaskDetailsView(.edit, task)
    }
    
    func didTapOnCopy(task: TaekwonTask) {
        showTaskDetailsView(.copy, task)
    }
    
    func didTapOnDelete(task: TaekwonTask, indexPath: IndexPath) {
        let alertVC = UIAlertController(title: "Delete Task", message: "Are you sure you would like to\n permanently remove this task?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let strong = self else {return}
            CoreDataController.shared.deleteTaskOnBackgroundThread(task)
            let removedTask = strong.viewModel.filteredTasks.remove(at: indexPath.row)
            strong.viewModel.allTasks.removeAll(where: {$0.createdDate == removedTask.createdDate})
            strong.sortList()
            strong.taskTableView.reloadData()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        self.navigationController?.present(alertVC, animated: true)
    }
    
    func didTapOnCompleteBtn(task: TaekwonTask) {
        CoreDataController.shared.editTaskOnBackgroundThread(task)
        sortList()
    }
}

//MARK: - Task Details View Delegate
extension TaekwonDoVC: DetailsViewDelegate{
    func saveNewTask(task: TaekwonTask) {
        CoreDataController.shared.saveNewTaskOnBackgroundThread(task)
        viewModel.allTasks.append(task)
        sortList()
        taskTableView.reloadData()
        updateAddTaskBtn()
    }
    
    func editNewTask(task: TaekwonTask) {
        CoreDataController.shared.editTaskOnBackgroundThread(task)
        sortList()
        taskTableView.reloadData()
    }
    
    func detailsViewDismissed() {
        self.view.isUserInteractionEnabled = true
        updateAddTaskBtn()
    }
    
    private func updateAddTaskBtn(){
        navBarView.imgAddItem.tintColor = UIColor(named: "primaryText")
        navBarView.lblAddItem.textColor = UIColor(named: "primaryText")
    }
}

//MARK: - Drop Down Delegate
extension TaekwonDoVC : DrowDownDelegate{
    
    func tableViewPopup(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let sortItem = TaekwonTaskViewModel.SortOption.allCases[indexPath.row]
        let bgColor: UIColor = (traitCollection.userInterfaceStyle == .light) ? .black : .white
        let tintColor: UIColor = (traitCollection.userInterfaceStyle == .light) ? .white : .black
        let selectedColor: UIColor = (traitCollection.userInterfaceStyle == .light) ? UIColor(named: "tdGold") ?? .yellow : UIColor(named: "tdBlue") ?? .blue
        if sortItem == viewModel.currentSortOption{
            cell.textLabel?.textColor = selectedColor
        } else {
            cell.textLabel?.textColor = tintColor
        }
        cell.contentView.backgroundColor = bgColor
        cell.textLabel?.text = sortItem.rawValue.capitalized
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cell.textLabel?.textAlignment = .left
        return cell
    }
    
    func tableViewPopup(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TaekwonTaskViewModel.SortOption.allCases.count
    }
    
    func tableViewPopup(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.currentSortOption = TaekwonTaskViewModel.SortOption.allCases[indexPath.row]
        sortList()
    }
    
    func tableViewPopup(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func popupDismissed() {
        let tintColor: UIColor = (traitCollection.userInterfaceStyle == .light) ? .white : .black
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.navBarView.imgSort.tintColor = tintColor
            self?.navBarView.lblSort.textColor = tintColor
        }
    }
}
