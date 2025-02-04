//
//  ViewController.swift
//  Effective_Mobile_Test_App
//
//  Created by Anton Demidenko on 29.1.25..
//

import UIKit

final class ToDoListViewController: UIViewController {
    
    private var tasks: [Task] = []
    private var filteredTasks: [Task] = []
    private var isSearching: Bool {
        !searchBar.text!.isEmpty
    }
    
    private let toDoService = ToDoService()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.textColor = UIColor(named: "white")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.attributedPlaceholder = NSAttributedString(
                string: searchBar.placeholder ?? "",
                attributes: [
                    .foregroundColor: (UIColor(named: "white") ?? .white).withAlphaComponent(0.5)
                ]
            )
            
            let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            imageView.tintColor = (UIColor(named: "white") ?? .white).withAlphaComponent(0.5)
            textField.leftView = imageView
            textField.leftViewMode = .always
            
            textField.backgroundColor = UIColor(named: "gray") ?? .gray
            textField.textColor = UIColor(named: "white") ?? .white
        }
        
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor(named: "separatorColor")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var footerView: UIView = {
        let footer = UIView()
        footer.backgroundColor = UIColor(named: "gray")
        
        let taskCountLabel = UILabel()
        taskCountLabel.translatesAutoresizingMaskIntoConstraints = false
        taskCountLabel.textColor = UIColor(named: "white")
        taskCountLabel.font = UIFont.systemFont(ofSize: 11)
        taskCountLabel.tag = 101
        footer.addSubview(taskCountLabel)
        
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage (systemName: "square.and.pencil"), for: .normal)
        addButton.tintColor = UIColor(named: "yellow") ?? .systemYellow
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(createTaskButtonTapped), for: .touchUpInside)
        footer.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            taskCountLabel.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            taskCountLabel.topAnchor.constraint(equalTo: footer.topAnchor, constant: 20.5),
            
            addButton.topAnchor.constraint(equalTo: footer.topAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            addButton.widthAnchor.constraint(equalToConstant: 68),
            addButton.trailingAnchor.constraint(equalTo: footer.trailingAnchor),
        ])
        footer.translatesAutoresizingMaskIntoConstraints = false
        return footer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "black")
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupViews()
        loadData()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(footerView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 360),
            titleLabel.heightAnchor.constraint(equalToConstant: 56),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 83)
        ])
    }
    
    private func loadData() {
        TaskStore.shared.fetchAllTasks { savedTasks in
            if savedTasks.isEmpty {
                self.fetchTasksFromAPI()
            } else {
                self.tasks = savedTasks
                self.tableView.reloadData()
                self.updateTaskCountLabel()
            }
        }
    }
    
    private func fetchTasksFromAPI() {
        toDoService.fetchTasks { [weak self] fetchedTasks in
            guard let self = self else { return }
            
            self.tasks = fetchedTasks
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateTaskCountLabel()
            }
        }
    }
    
    private func updateTaskCountLabel() {
        if let taskCountLabel = footerView.viewWithTag(101) as? UILabel {
            taskCountLabel.text = "\(tasks.count) Задач"
        }
    }
    
    private func saveNewTask(title: String, description: String) {
        let creationDate = getCurrentDateString()
        
        TaskStore.shared.addTask(title: title, description: description, creationDate: creationDate, isReady: false) { success in
            if success {
                TaskStore.shared.fetchAllTasks { tasks in
                    DispatchQueue.main.async {
                        if let newTask = tasks.last {
                            self.tasks.insert(newTask, at: 0)
                        }
                        self.tableView.reloadData()
                        self.updateTaskCountLabel()
                    }
                }
            } else {
                print("Не удалось добавить задачу!")
            }
        }
    }
    
    
    private func updateTask(task: Task, newTitle: String, newDescription: String) {
        let creationDate = task.creationDate ?? getCurrentDateString()
        TaskStore.shared.updateTask(task: task, title: newTitle, description: newDescription, creationDate: creationDate, isReady: task.isReady) { success in
            if success {
                DispatchQueue.main.async {
                    if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                        self.tasks[index] = task
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
            } else {
                print("Не удалось обновить задачу!")
            }
        }
    }
    
    private func deleteTask(task: Task) {
        TaskStore.shared.deleteTask(task: task) { success in
            if success {
                if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                    self.tasks.remove(at: index)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.updateTaskCountLabel()
                    }
                }
            } else {
                print("Не удалось удалить задачу!")
            }
        }
    }
    
    private func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: Date())
    }
    
    @objc private func createTaskButtonTapped() {
        let newTaskVC = NewTaskViewController()
        
        newTaskVC.onSave = { [weak self] title, description in
            guard let self = self else { return }
            self.saveNewTask(title: title, description: description)
            self.tableView.reloadData()
        }
        
        navigationController?.pushViewController(newTaskVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ToDoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        selectedTask.isReady.toggle()
        TaskStore.shared.updateTask(task: selectedTask, title: selectedTask.title ?? "", description: selectedTask.taskDescription ?? "", creationDate: selectedTask.creationDate ?? "", isReady: selectedTask.isReady) { success in
            if success {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                print("Не удалось обновить задачу!")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = UIColor(named: "black")
        cell.selectionStyle = .none
        let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        cell.configure(with: task)
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            let task = self.isSearching ? self.filteredTasks[indexPath.row] : self.tasks[indexPath.row]
            
            let previewCard = UIView()
            previewCard.backgroundColor = UIColor(named: "gray")
            previewCard.layer.cornerRadius = 12
            previewCard.translatesAutoresizingMaskIntoConstraints = false
            
            let titleLabel = UILabel()
            titleLabel.text = task.title
            titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            titleLabel.textColor = UIColor(named: "white")
            titleLabel.numberOfLines = 2
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            previewCard.addSubview(titleLabel)
            
            let descriptionLabel = UILabel()
            descriptionLabel.text = task.taskDescription
            descriptionLabel.font = .systemFont(ofSize: 12)
            descriptionLabel.textColor = UIColor(named: "white")
            descriptionLabel.numberOfLines = 0
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            previewCard.addSubview(descriptionLabel)
            
            let dateLabel = UILabel()
            dateLabel.text = task.creationDate
            dateLabel.font = .systemFont(ofSize: 12)
            dateLabel.textColor = UIColor(named: "white")
            dateLabel.alpha = 0.5
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            previewCard.addSubview(dateLabel)
            
            let cardWidth = self.view.frame.width - 40
            
            NSLayoutConstraint.activate([
                previewCard.widthAnchor.constraint(equalToConstant: cardWidth),
                
                titleLabel.topAnchor.constraint(equalTo: previewCard.topAnchor, constant: 12),
                titleLabel.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -16),
                
                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
                descriptionLabel.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 16),
                descriptionLabel.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -16),
                
                dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
                dateLabel.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 16),
                dateLabel.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -16),
                dateLabel.bottomAnchor.constraint(equalTo: previewCard.bottomAnchor, constant: -12)
            ])
            
            previewCard.layoutIfNeeded()
            let targetSize = CGSize(width: cardWidth, height: UIView.layoutFittingCompressedSize.height)
            let fittingSize = previewCard.systemLayoutSizeFitting(targetSize,
                                                                  withHorizontalFittingPriority: .required,
                                                                  verticalFittingPriority: .fittingSizeLevel)
            
            let previewViewController = UIViewController()
            previewViewController.view = previewCard
            previewViewController.preferredContentSize = fittingSize
            
            return previewViewController
        }) { _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(named: "edit")) { [weak self] _ in
                self?.editTask(at: indexPath)
            }
            
            let shareAction = UIAction(title: "Поделиться", image: UIImage(named: "export")) { [weak self] _ in
                self?.shareTask(at: indexPath)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(named: "trash"), attributes: .destructive) { [weak self] _ in
                self?.deleteTask(at: indexPath)
            }
            
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
    
    
    private func editTask(at indexPath: IndexPath) {
        let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        
        let newTaskVC = NewTaskViewController()
        newTaskVC.taskToEdit = task
        
        newTaskVC.onSave = { [weak self] title, description in
            guard let self = self else { return }
            self.updateTask(task: task, newTitle: title, newDescription: description)
            self.tableView.reloadData()
        }
        
        navigationController?.pushViewController(newTaskVC, animated: true)
    }
    
    private func shareTask(at indexPath: IndexPath) {
        let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        let activityVC = UIActivityViewController(activityItems: [task.title ?? "Заголовок отсутствует"], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        let taskToDelete = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        
        TaskStore.shared.deleteTask(task: taskToDelete) { success in
            if success {
                if self.isSearching {
                    self.filteredTasks.remove(at: indexPath.row)
                } else {
                    self.tasks.remove(at: indexPath.row)
                }
                
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.updateTaskCountLabel()
                }
            }
        }
    }
}

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredTasks = tasks
            tableView.reloadData()
        } else {
            searchTasks(with: searchText)
        }
    }
    
    func searchTasks(with searchText: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let filtered = self.tasks.filter { task in
                guard let taskTitle = task.title else { return false }
                return taskTitle.localizedCaseInsensitiveContains(searchText)
            }
            
            DispatchQueue.main.async {
                self.filteredTasks = filtered
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

@available(iOS 17, *)
#Preview {
    ToDoListViewController()
}
