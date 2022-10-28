//
//  TaekwonDoVC.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/26/22.
//

import UIKit

//TODO: replace with core data
class TaekwonTask {
    var createdDate: Date?
    var title: String = ""
    var description: String = ""
    var dueDate: Date?
    var cellExpanded = false
    var taskCompleted = false
}

class TaekwonDoVC: UIViewController {

    @IBOutlet weak var navBarView: NavBarView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var taskTableView: UITableView!
    private var allTasks: [TaekwonTask] = []
    
    enum SortOption: String{
        case RecentlyAdded = "Most Recent"
        case DueToday = "Due today"
        case Completed = "Completed"
        case Incomplete = "Incomplete"
        case PastDue = "Past Due"
    }
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarView.layer.addShadow()
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.register(UINib(nibName: "TaskCell", bundle: .main), forCellReuseIdentifier: "TaskCell")
        taskTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)

        
        for i in 0...100{
            let mockData = TaekwonTask()
            mockData.title = "This is a test title that is really really really long"
            mockData.description = "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWA"
            mockData.title = "\(i) \(mockData.title)"
            allTasks.append(mockData)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if traitCollection.userInterfaceStyle == .light{
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
//    //MARK: - Sort Functions
//    @objc func didTapOnSort(_ sender: UIButton){
//        if let topVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? UINavigationController{
//            UIView.animate(withDuration: 0.1) {
//                self.navBar.imgSort.tintColor = .YellowLime()
//                self.navBar.lblSort.textColor = .YellowLime()
//            }
//            let sourceView = sender.convert(sender.bounds, to: topVC.view)
//            let dropdown = DropDownView(sourceView: sourceView, customCellName: "", direction: .ArrowDown, maxWidth: 150, maxHeight: 39 * CGFloat(sortList.count), xOffset: nil, yOffset: nil, arrowOffset: nil, bgColor: .DarkBlue(), cornerRadias: 12, autoDismiss: true, addShadow: true, borderWidth: nil, borderColor: nil, addCellSeparator: nil)
//            dropdown.delegate = self
//            dropdown.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//            dropdown.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//            topVC.present(dropdown, animated: false, completion: nil)
//        }
//    }
//
//    func setSortOption(){
//        switch currentSortOption {
//        case .Ascending:
//            networkList = networkList.sorted { $0.name?.lowercased().trimmed ?? "" < $1.name?.lowercased().trimmed ?? "" }
//        case .Decending:
//            networkList = networkList.sorted { $0.name?.lowercased().trimmed ?? "" > $1.name?.lowercased().trimmed ?? "" }
//        case .City:
//            networkList = networkList.sorted { $0.location?.city?.lowercased().trimmed ?? "" < $1.location?.city?.lowercased().trimmed ?? ""}
//        case .NearestCity:
//            let coodsTo = CLLocation(latitude: currentUserLocation?.coordinate.latitude ?? 0.0, longitude: currentUserLocation?.coordinate.longitude ?? 0.0)
//            for network in networkList{
//                let coordsFrom = CLLocation(latitude: network.location?.latitude ?? 0.0, longitude: network.location?.longitude ?? 0.0)
//                network.distanceFromDeviceLocation = coodsTo.distance(from: coordsFrom) // result is in meters
//            }
//            networkList = networkList.sorted { $0.distanceFromDeviceLocation ?? 0.0 < $1.distanceFromDeviceLocation ?? 0.0 }
//        }
//        DispatchQueue.main.async {
//            self.cityBikeTableView.reloadData()
//            if self.cityBikeTableView.numberOfRows(inSection: 0) != 0 {
//                self.cityBikeTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//            }
//        }
//    }

}

// MARK: - TableView Delegate and Data Methods
extension TaekwonDoVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
//        cell.backgroundColor = UIColor.clear
        cell.configureCell(allTasks[indexPath.row], delegate: self)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let task = allTasks[indexPath.row]
        if task.cellExpanded{
            return 200
        }
        return 65
    }

//    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
//        cell.didSelectCell()
//        tableView.deselectRow(at: indexPath, animated: true)
        let task = allTasks[indexPath.row]
        task.cellExpanded = !task.cellExpanded
//        tableView.reloadData()
        tableView.reloadRows(at: [indexPath], with: .automatic)
//        tableView.deselectRow(at: indexPath, animated: false)
//        processSelectedValue(selectedIndexPath: indexPath)
    }
//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
////        tableView.deselectRow(at: indexPath, animated: true)
//        return indexPath
//    }

}

extension TaekwonDoVC: TaskCellDelegate{
    func didTapOnEdit(task: TaekwonTask) {
        print("Edit")
    }
    
    func didTapOnCopy(task: TaekwonTask) {
        print("Copy")
    }
    
    func didTapOnDelete(task: TaekwonTask) {
        print("Delete")
    }
    
    
}


////MARK: - Drop Down Delegate
//extension MainVC : DrowDownDelegate{
//
//    func tableViewPopup(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        let sortItem = sortList[indexPath.row]
//        if sortItem == currentSortOption{
//            cell.textLabel?.textColor = .YellowLime()
//        } else {
//            cell.textLabel?.textColor = .white
//        }
//        cell.contentView.backgroundColor = .DarkBlue()
//        cell.textLabel?.text = sortItem.rawValue.capitalized
//        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
//        cell.textLabel?.textAlignment = .left
//        return cell
//    }
//
//    func tableViewPopup(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sortList.count
//    }
//
//    func tableViewPopup(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        currentSortOption = sortList[indexPath.row]
//        setSortOption()
//    }
//
//    func tableViewPopup(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 39
//    }
//
//    func popupDismissed() {
//        UIView.animate(withDuration: 0.1) {
//            self.navBar.imgSort.tintColor = .white
//            self.navBar.lblSort.textColor = .white
//        }
//    }
//}
