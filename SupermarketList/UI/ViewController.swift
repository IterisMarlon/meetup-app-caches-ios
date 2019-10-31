//
//  ViewController.swift
//  SupermarketList
//
//  Created by Marlon Morato on 24/10/19.
//  Copyright © 2019 Marlon Burnett. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private let REUSE_IDENTIFIER = "tableViewCell"
    
    private var viewModel: ViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel()
        self.title = "Lista de Supermercado"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        fetch()
    }
    
    private func fetch() {
        viewModel.fetch { (error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    @IBAction func addItem(_ sender: Any) {
        guard let value = itemTextField.text, value.count > 0 else {
            return
        }
        
        self.itemTextField.isEnabled = false
        viewModel.add(value: value) { (error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.itemTextField.text = nil
                }
                self.itemTextField.isEnabled = true
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: REUSE_IDENTIFIER) ?? UITableViewCell(style: .default, reuseIdentifier: REUSE_IDENTIFIER)
        
        cell.textLabel?.text = viewModel.item(at: indexPath.row).value
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Apagar") { (action, indexPath) in
            self.viewModel.remove(at: indexPath.row) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }

        return [delete]

    }
}
