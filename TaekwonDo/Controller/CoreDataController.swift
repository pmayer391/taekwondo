//
//  CoreDataController.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/29/22.
//

import Foundation
import CoreData

class CoreDataController {
    
    //MARK: - Container Variables
    static let shared = CoreDataController()
    
    typealias TaskHandler = (_ tasks: [TaekwonTask]) -> ()
    private let cdTaskEntity = "CDTaekwonTask"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaekwonDo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            debugPrint("DB Path:", storeDescription.url?.absoluteString ?? "")
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return CoreDataController.shared.persistentContainer.newBackgroundContext()
    }()
    
    
    //MARK: - Taekwon Task Functions
    func fetchTasksOnBackground(completion: @escaping TaskHandler){
        backgroundContext.perform{ [weak self] in
            guard let strong = self else {return}
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: strong.cdTaskEntity)
            do {
                let manageObj = try strong.backgroundContext.fetch(fetchRequest)
                if let cdTasks = manageObj as? [CDTaekwonTask]{
                    completion(strong.getTasksForMainThread(cdTasks))
                } else{
                    debugPrint("Unable to use fetch tasks on background thread")
                    completion([])
                }
            } catch let error as NSError{
                debugPrint("Could Not Fetch Core Data: \(error), \(error.userInfo)")
                completion([])
            }
        }
    }
    
    private func getTasksForMainThread(_ cdTasks: [CDTaekwonTask]) -> [TaekwonTask]{
        var tasks: [TaekwonTask] = []
        for task in cdTasks{
            guard let cdTask = CoreDataController.shared.persistentContainer.viewContext.object(with: task.objectID) as? CDTaekwonTask else { break }
            let task = TaekwonTask()
            task.createdDate = cdTask.taskCreationDate
            task.title = cdTask.taskTitle ?? ""
            task.description = cdTask.taskDescription ?? ""
            task.dueDate = cdTask.taskDueDate
            task.taskCompleted = cdTask.taskCompleted
            tasks.append(task)
        }
        return tasks
    }
    
    func editTaskOnBackgroundThread(_ task: TaekwonTask){
        self.backgroundContext.perform { [weak self] in
            guard let strong = self, let creationDate = task.createdDate else {return}
            let fetchTask: NSFetchRequest<CDTaekwonTask> = CDTaekwonTask.fetchRequest()
            fetchTask.predicate = NSPredicate(format: "taskCreationDate = %@", creationDate as NSDate)
            do {
                guard let cdTask: CDTaekwonTask = try strong.backgroundContext.fetch(fetchTask).first else { return }
                cdTask.taskTitle = task.title
                cdTask.taskDescription = task.description
                cdTask.taskDueDate = task.dueDate
                cdTask.taskCompleted = task.taskCompleted
                strong.saveBGContext()
            } catch let error as NSError{
                debugPrint("Could Not Fetch Core Data to Edit Task: \(error), \(error.userInfo)")
            }
        }
    }
    
    func deleteTaskOnBackgroundThread(_ task: TaekwonTask){
        self.backgroundContext.perform { [weak self] in
            guard let strong = self, let creationDate = task.createdDate else {return}
            let fetchTask: NSFetchRequest<CDTaekwonTask> = CDTaekwonTask.fetchRequest()
            fetchTask.predicate = NSPredicate(format: "taskCreationDate = %@", creationDate as NSDate)
            do {
                guard let cdTask: CDTaekwonTask = try strong.backgroundContext.fetch(fetchTask).first else { return }
                strong.backgroundContext.delete(cdTask)
                strong.saveBGContext()
            } catch let error as NSError{
                debugPrint("Could Not Fetch Core Data to Delete Task: \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveNewTaskOnBackgroundThread(_ task: TaekwonTask){
        self.backgroundContext.perform{ [weak self] in
            guard let strong = self else {return}
            strong.backgroundContext.reset()
            let newTask = CDTaekwonTask(context: strong.backgroundContext)
            newTask.taskCreationDate = task.createdDate
            newTask.taskTitle = task.title
            newTask.taskDescription = task.description
            newTask.taskDueDate = task.dueDate
            newTask.taskCompleted = task.taskCompleted
            strong.saveBGContext()
        }
    }
    
    private func saveBGContext(){
        if self.backgroundContext.hasChanges{
            do {
                try self.backgroundContext.save()
            } catch let error as NSError{
                debugPrint("Could Not Save Core Data: \(error), \(error.userInfo)")
            }
        }
    }
    
}







