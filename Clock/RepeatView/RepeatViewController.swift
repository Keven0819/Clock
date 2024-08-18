//
//  RepeatViewController.swift
//  Clock
//
//  Created by imac-2627 on 2024/8/6.
//

import UIKit

protocol RepeatViewControllerDelegate: AnyObject {
    func didUpdateRepeatDays(_ days: [Bool])
}

class RepeatViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Property
    weak var delegate: RepeatViewControllerDelegate?
    let daysOfWeek = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
    var selectedDays: [Bool] = Array(repeating: false, count: 7)
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.reloadData()
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        title = "重複"
        tableView.register(UINib(nibName: "RepeatTableViewCell", bundle: nil), forCellReuseIdentifier: RepeatTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneTapped))
    }
    
    // MARK: - IBAction
    
    @objc func doneTapped() {
        delegate?.didUpdateRepeatDays(selectedDays)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Function
}

// MARK: - Extensions

extension RepeatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatTableViewCell", for: indexPath) as! RepeatTableViewCell
        cell.lbTest.text = daysOfWeek[indexPath.row]
        cell.accessoryType = selectedDays[indexPath.row] ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDays[indexPath.row].toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
