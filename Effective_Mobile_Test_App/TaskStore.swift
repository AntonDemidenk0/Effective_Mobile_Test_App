//
//  TaskStore.swift
//  Effective_Mobile_Test_App
//
//  Created by Anton Demidenko on 1.2.25..
//

import CoreData
import UIKit

class TaskStore {
    static let shared = TaskStore()
    
    private let context: NSManagedObjectContext
    
    // MARK: - Initializer
    
    init(context: NSManagedObjectContext? = nil) {
        if let context = context {
            self.context = context
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("Unable to retrieve AppDelegate")
            }
            self.context = appDelegate.persistentContainer.viewContext
        }
    }
    
    
    func saveContext(completion: @escaping (Bool) -> Void) {
        if context.hasChanges {
            context.perform {
                do {
                    try self.context.save()
                    completion(true)
                } catch {
                    print("Failed to save context: \(error)")
                    completion(false)
                }
            }
        } else {
            completion(true)
        }
    }
    
    func addTask(title: String, description: String, creationDate: String, isReady: Bool, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let existingTasks = self.fetchTasksByTitle(title)
            if existingTasks.isEmpty {
                self.context.perform {
                    let task = Task(context: self.context)
                    task.title = title
                    task.taskDescription = description
                    task.creationDate = creationDate
                    task.isReady = isReady
                    self.saveContext { success in
                        completion(success)
                    }
                }
            } else {
                print("Задача с таким названием уже существует!")
                completion(false)
            }
        }
    }
    
    func fetchAllTasks(completion: @escaping ([Task]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            do {
                let tasks = try self.context.fetch(fetchRequest)
                DispatchQueue.main.async {
                    completion(tasks)
                }
            } catch {
                print("Failed to fetch tasks: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func fetchTasksByTitle(_ title: String) -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        var tasks: [Task] = []
        context.performAndWait {
            do {
                tasks = try context.fetch(fetchRequest)
            } catch {
                print("Ошибка при поиске задачи по названию: \(error)")
            }
        }
        return tasks
    }
    
    func updateTask(task: Task, title: String, description: String, creationDate: String, isReady: Bool, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.context.perform {
                task.title = title
                task.taskDescription = description
                task.creationDate = creationDate
                task.isReady = isReady
                self.saveContext { success in
                    completion(success)
                }
            }
        }
    }
    
    func deleteTask(task: Task, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.context.perform {
                self.context.delete(task)
                self.saveContext { success in
                    completion(success)
                }
            }
        }
    }
    
    func reset() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Ошибка при сбросе задач: \(error)")
        }
    }
}

