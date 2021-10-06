//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit

protocol TaskViewControllerDelegate {
    func reloadData()
}

class TaskListViewController: UITableViewController {
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        taskList = StorageManager.shared.fetchDataFromCoreData()
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let taskForDeleting = taskList.remove(at: indexPath.row)
            
            let cellIndex = IndexPath(row: indexPath.row, section: 0)
            tableView.deleteRows(at: [cellIndex], with: .automatic)
            
            StorageManager.shared.deleteTask(taskForDeleting)
            StorageManager.shared.saveContext()
           
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(with: "Edit task", and: "Enter new title please", true)
    }
    
    
}

// MARK: - Work with UIElements
extension TaskListViewController {
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
}

//MARK: - Work with tasks
extension TaskListViewController {
    private func showAlert(with title: String, and message: String, _ editMode: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            if editMode {
                self.editTask(taskName)
            } else {
                self.addTask(taskName)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
            if editMode {
                guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
                let currentTask = self.taskList[indexPath.row]
                
                textField.text = currentTask.title
            }
        }
        present(alert, animated: true)
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func editTask(_ taskName: String) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let currentTask = taskList[indexPath.row]
        
        currentTask.title = taskName
        StorageManager.shared.saveContext()
        
        let cellIndex = IndexPath(row: indexPath.row, section: 0)
        tableView.reloadRows(at: [cellIndex], with: .automatic)
    }
    
    private func addTask(_ taskName: String) {
        if let newTask = StorageManager.shared.saveTask(taskName) {
            taskList.append(newTask)
            
            let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [cellIndex], with: .automatic)
        } else {
            print("Failed to save new task!")
        }
    }
}


// MARK: - TaskViewControllerDelegate
extension TaskListViewController: TaskViewControllerDelegate {
    func reloadData() {
        taskList = StorageManager.shared.fetchDataFromCoreData()
        tableView.reloadData()
    }
}


