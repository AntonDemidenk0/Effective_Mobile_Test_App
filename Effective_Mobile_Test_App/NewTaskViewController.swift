//
//  NewTaskViewController.swift
//  Effective_Mobile_Test_App
//
//  Created by Anton Demidenko on 31.1.25..
//

import UIKit

final class NewTaskViewController: UIViewController, UITextViewDelegate {
    
    var onSave: ((String, String) -> Void)?
    var taskToEdit: Task?
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите заголовок"
        textField.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        textField.textColor = UIColor(named: "white")
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "white")?.withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let currentDate = Date()
        
        label.text = dateFormatter.string(from: currentDate)
        
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = UIColor(named: "white")?.withAlphaComponent(0.5)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "Введите описание задачи"
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "black")
        setupViews()
        setupConstraints()
        descriptionTextView.delegate = self
        configureNavigationBar()
        populateFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveTask()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupViews() {
        view.addSubview(titleTextField)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 56),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = UIColor(named: "yellow")
        if let backButton = navigationController?.navigationBar.backItem {
            backButton.title = "Назад"
        }
    }
    
    private func saveTask() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        
        let description = descriptionTextView.text == "Введите описание задачи" ? "" : descriptionTextView.text
        onSave?(title, description ?? "")
    }
    
    private func populateFields() {
        guard let task = taskToEdit else { return }
        
        titleTextField.text = task.title
        
        if let description = task.taskDescription, !description.isEmpty {
            descriptionTextView.text = description
            descriptionTextView.textColor = UIColor(named: "white")
        } else {
            descriptionTextView.text = "Введите описание задачи"
            descriptionTextView.textColor = UIColor(named: "white")?.withAlphaComponent(0.5)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Введите описание задачи" {
            textView.text = ""
            textView.textColor = UIColor(named: "white")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Введите описание задачи"
            textView.textColor = UIColor(named: "white")?.withAlphaComponent(0.5)
        }
    }
}
