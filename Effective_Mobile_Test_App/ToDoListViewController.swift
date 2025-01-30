//
//  ViewController.swift
//  Effective_Mobile_Test_App
//
//  Created by Anton Demidenko on 29.1.25..
//

import UIKit

final class ToDoListViewController: UIViewController {
    
    private var tasks: [toDoTask] = []
    
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
            
            addButton.centerYAnchor.constraint(equalTo: taskCountLabel.centerYAnchor),
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
        setupViews()
        fetchTasks()
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
    
    private func fetchTasks() {
        toDoService.fetchTasks { [weak self] fetchedTasks in
            self?.tasks = fetchedTasks
            self?.tableView.reloadData()
            self?.updateTaskCountLabel()
        }
    }
    
    private func updateTaskCountLabel() {
        if let taskCountLabel = footerView.viewWithTag(101) as? UILabel {
            taskCountLabel.text = "\(tasks.count) Задач"
        }
    }

    @objc private func createTaskButtonTapped() {
       // let createTaskVC = NewTaskViewController()
       // present(createTaskVC, animated: true)
    }
}

extension ToDoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let task = tasks[indexPath.row]
        cell.configure(with: task)
        return cell
    }
}


@available(iOS 17, *)
#Preview {
    ToDoListViewController()
}
