//
//  TaskAPI.swift
//  Effective_Mobile_Test_App
//
//  Created by Anton Demidenko on 30.1.25..
//

import Foundation

final class ToDoService {
    private let apiURL = "https://dummyjson.com/todos"
    
    func fetchTasks(completion: @escaping ([Task]) -> Void) {
        TaskStore.shared.fetchAllTasks { tasks in
            if !tasks.isEmpty {
                DispatchQueue.main.async {
                    completion(tasks)
                }
                return
            }
            
            guard let url = URL(string: self.apiURL) else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        DispatchQueue.main.async {
                            completion([])
                        }
                        return
                    }
                    
                    do {
                        let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        let today = dateFormatter.string(from: Date())
                        
                        let group = DispatchGroup()
                        decodedResponse.todos.forEach { todo in
                            group.enter()
                            TaskStore.shared.addTask(
                                title: todo.todo,
                                description: "",
                                creationDate: today,
                                isReady: todo.completed
                            ) { success in
                                group.leave()
                            }
                        }
                        
                        group.notify(queue: .main) {
                            TaskStore.shared.fetchAllTasks { tasks in
                                DispatchQueue.main.async {
                                    completion(tasks)
                                }
                            }
                        }
                    } catch {
                        print("Ошибка декодирования: \(error)")
                        DispatchQueue.main.async {
                            completion([])
                        }
                    }
                }.resume()
            }
        }
    }
}

struct TodoResponse: Decodable {
    let todos: [Todo]
}

struct Todo: Decodable {
    let todo: String
    let completed: Bool
}
