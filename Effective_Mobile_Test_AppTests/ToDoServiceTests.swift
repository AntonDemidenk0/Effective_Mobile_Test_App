//
//  ToDoServiceTests.swift
//  Effective_Mobile_Test_App
//
//  Created by Anton Demidenko on 4.2.25..
//

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import Effective_Mobile_Test_App

final class ToDoServiceTests: XCTestCase {
    
    var toDoService: ToDoService!
    
    override func setUp() {
        super.setUp()
        toDoService = ToDoService()
        TaskStore.shared.reset()
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testFetchTasksFromAPI_Success() {
        let mockData = """
        {
            "todos": [
                {"todo": "Task 1", "completed": false},
                {"todo": "Task 2", "completed": true}
            ]
        }
        """.data(using: .utf8)!
        
        stub(condition: isHost("dummyjson.com")) { _ in
            return HTTPStubsResponse(data: mockData, statusCode: 200, headers: nil)
        }
        
        let expectation = self.expectation(description: "Tasks fetched")
        toDoService.fetchTasks { tasks in
            let sortedTasks = tasks.sorted { $0.title! < $1.title! }
            
            XCTAssertEqual(sortedTasks.count, 2, "Количество задач должно быть 2")
            XCTAssertEqual(sortedTasks.first?.title, "Task 1", "Название первой задачи должно быть 'Task 1'")
            XCTAssertEqual(sortedTasks.last?.title, "Task 2", "Название последней задачи должно быть 'Task 2'")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFetchTasksFromAPI_Failure() {
        stub(condition: isHost("dummyjson.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "NetworkError", code: -1, userInfo: nil))
        }
        
        let expectation = self.expectation(description: "Tasks fetch failed")
        toDoService.fetchTasks { tasks in
            XCTAssertEqual(tasks.count, 0, "При ошибке в запросе задачи не должны быть получены")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchTasksFromAPI_Success_LocallyAvailableTasks() {
        let expectationAddTask = self.expectation(description: "Task added to Core Data")
        TaskStore.shared.addTask(title: "Local Task", description: "Test description", creationDate: "04/02/2025", isReady: false) {_ in
            expectationAddTask.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        let expectationFetchTasks = self.expectation(description: "Tasks fetched from local storage")
        toDoService.fetchTasks { tasks in
            XCTAssertEqual(tasks.count, 1, "Ожидаем одну задачу в локальном хранилище")
            XCTAssertEqual(tasks.first?.title, "Local Task", "Название задачи должно быть 'Local Task'")
            expectationFetchTasks.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
}
