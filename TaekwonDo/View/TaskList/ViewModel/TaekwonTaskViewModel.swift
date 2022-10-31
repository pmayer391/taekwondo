//
//  TaekwonTaskViewModel.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/30/22.
//

import Foundation

class TaekwonTaskViewModel{
    
    var allTasks: [TaekwonTask] = []
    var filteredTasks: [TaekwonTask] = []
    var currentSortOption: SortOption = .RecentlyAdded
    
    enum SortOption: String, CaseIterable{
        case RecentlyAdded = "Most Recent"
        case DueToday = "Due Today"
        case Completed = "Completed"
        case Incomplete = "Incomplete"
        case PastDue = "Past Due"
        
        func emptyTaskListTitle() -> String{
            switch self{
            case .RecentlyAdded:
                return "Empty Task List"
            case .DueToday:
                return "There Are No More Tasks For Today"
            case .Completed:
                return "No Tasks Have Been Finished"
            case .Incomplete:
                return "All Tasks Are Complete"
            case .PastDue:
                return "There Are No Past Due Tasks"
            }
        }
    }
    
    func sortList(){
        filteredTasks = allTasks
        switch currentSortOption{
        case .RecentlyAdded:
            filteredTasks = allTasks.sorted{$0.createdDate ?? Date() > $1.createdDate ?? Date()}
        case .DueToday:
            filteredTasks = allTasks.filter({
                if let dueDate = $0.dueDate{
                    return Calendar.current.isDateInToday(dueDate)
                } else {
                    return false
                }
            })
        case .Completed:
            filteredTasks = filteredTasks.filter({$0.taskCompleted})
        case .Incomplete:
            filteredTasks = filteredTasks.filter({!$0.taskCompleted})
        case .PastDue:
            filteredTasks = allTasks.filter({
                let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                if let dueDate = $0.dueDate, dueDate > nextDay, !$0.taskCompleted{
                    return true
                } else {
                    return false
                }
            })
        }
    }
    
}
