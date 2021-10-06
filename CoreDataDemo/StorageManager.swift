//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Константин Кириллов on 06.10.2021.
//

import Foundation
import CoreData
import UIKit

class StorageManager {
    
    static let shared = StorageManager()
    
    private static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let context = persistentContainer.viewContext
   
    private init() {}
    
    
    func fetchDataFromCoreData() -> [Task]{
        let fetchRequest = Task.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
            return [Task]()
        }
    }
    
    func saveTask(_ taskName: String) -> Task? {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return nil }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return nil }
        task.title = taskName
        saveContext()
        return task
    }
    
    func deleteTask(_ task: Task) {
        context.delete(task)
    }
    
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
