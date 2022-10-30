//
//  CDTaekwonTask+CoreDataProperties.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/29/22.
//
//

import Foundation
import CoreData


extension CDTaekwonTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTaekwonTask> {
        return NSFetchRequest<CDTaekwonTask>(entityName: "CDTaekwonTask")
    }

    @NSManaged public var taskTitle: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var taskDueDate: Date?
    @NSManaged public var taskCompleted: Bool

}

extension CDTaekwonTask : Identifiable {

}
