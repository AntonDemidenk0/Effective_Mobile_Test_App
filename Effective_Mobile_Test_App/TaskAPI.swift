//
//  TaskAPI.swift
//  Effective_Mobile_Test_App
//
//  Created by Anton Demidenko on 30.1.25..
//

import Foundation

final class ToDoService {
    private let apiURL = "https://dummyjson.com/todos"
    
    func fetchTasks(completion: @escaping ([toDoTask]) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let today = dateFormatter.string(from: Date())
                
                let tasks = decodedResponse.todos.map { todo in
                    toDoTask(
                        title: todo.todo,
                        description: "no description",
                        creationDate: today,
                        isReady: todo.completed
                    )
                }
                
                DispatchQueue.main.async {
                    completion(tasks)
                }
                
            } catch {
                print("Ошибка декодирования: \(error)")
                completion([])
            }
        }.resume()
    }
}

struct TodoResponse: Decodable {
    let todos: [Todo]
}

struct Todo: Decodable {
    let todo: String
    let completed: Bool
}
