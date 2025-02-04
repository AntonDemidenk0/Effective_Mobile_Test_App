//
//  TaskStoreTests.swift
//  TaskStoreTests
//
//  Created by Anton Demidenko on 4.2.25..
//

import XCTest
import CoreData
@testable import Effective_Mobile_Test_App

final class TaskStoreTests: XCTestCase {
    
    var taskStore: TaskStore!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        let container = NSPersistentContainer(name: "Effective_Mobile_Test_App")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        context = container.viewContext
        taskStore = TaskStore(context: context)
    }
    
    override func tearDown() {
        context = nil
        taskStore = nil
        super.tearDown()
    }
    
    func testAddTask() {
        let title = "Test Task"
        let description = "Test Description"
        let creationDate = "01/01/2025"
        let isReady = false
        
        let expectation = self.expectation(description: "Task added")
        taskStore.addTask(title: title, description: description, creationDate: creationDate, isReady: isReady) { success in
            XCTAssertTrue(success)
            
            self.taskStore.fetchAllTasks { tasks in
                XCTAssertEqual(tasks.count, 1)
                XCTAssertEqual(tasks.first?.title, title)
                XCTAssertEqual(tasks.first?.taskDescription, description)
                XCTAssertEqual(tasks.first?.creationDate, creationDate)
                XCTAssertEqual(tasks.first?.isReady, isReady)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testFetchAllTasks() {
        let task = Task(context: context)
        task.title = "Sample Task"
        task.taskDescription = "Sample Description"
        task.creationDate = "01/01/2025"
        task.isReady = false
        
        try? context.save()
        
        let expectation = self.expectation(description: "Tasks fetched")
        taskStore.fetchAllTasks { tasks in
            XCTAssertEqual(tasks.count, 1)
            XCTAssertEqual(tasks.first?.title, "Sample Task")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testUpdateTask() {
        let task = Task(context: context)
        task.title = "Initial Task"
        task.taskDescription = "Initial Description"
        task.creationDate = "01/01/2025"
        task.isReady = false
        
        try? context.save()
        
        let newTitle = "Updated Task"
        let newDescription = "Updated Description"
        
        let expectation = self.expectation(description: "Task updated")
        taskStore.updateTask(task: task, title: newTitle, description: newDescription, creationDate: task.creationDate ?? "", isReady: true) { success in
            XCTAssertTrue(success)
            
            self.taskStore.fetchAllTasks { tasks in
                XCTAssertEqual(tasks.count, 1)
                XCTAssertEqual(tasks.first?.title, newTitle)
                XCTAssertEqual(tasks.first?.taskDescription, newDescription)
                XCTAssertTrue(tasks.first?.isReady ?? false)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testDeleteTask() {
        let task = Task(context: context)
        task.title = "Task to Delete"
        task.taskDescription = "Description"
        task.creationDate = "01/01/2025"
        task.isReady = false
        
        try? context.save()
        
        let expectation = self.expectation(description: "Task deleted")
        taskStore.deleteTask(task: task) { success in
            XCTAssertTrue(success)
            
            self.taskStore.fetchAllTasks { tasks in
                XCTAssertTrue(tasks.isEmpty)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0)
    }
}
