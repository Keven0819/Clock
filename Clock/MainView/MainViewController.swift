//
//  MainViewController.swift
//  Clock
//
//  Created by imac-2627 on 2024/8/6.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Property
    
    var pageTitle: [String] = ["鬧鐘"] //這是我要在MainTalbeViewCell印出來的內容
    var alarms: [AlarmData] = []
    var idEditing: Bool = false
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAlarms()
        tableView.reloadData()
    }
    
    // MARK: - UI Settings
    
    func setUI() {
        setTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "編輯", style: .plain, target: self, action: #selector(editTapped))
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "鬧鐘"
    }
    
    func setTableView() {
        tableView.register(UINib(nibName: "SecondTableViewCell", bundle: nil), forCellReuseIdentifier: SecondTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInsetAdjustmentBehavior = .automatic
    }
    
    // MARK: - IBAction
    
    @objc func addTapped() {
        let addAlarmVC = AddAlarmViewController(nibName: "AddAlarmViewController", bundle: nil)
        addAlarmVC.delegate = self
        let navController = UINavigationController(rootViewController: addAlarmVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func editTapped() {
        isEditing.toggle()
        tableView.setEditing(isEditing, animated: true)
        navigationItem.leftBarButtonItem?.title = isEditing ? "完成" : "編輯"
        tableView.reloadData()
    }
    
    @objc func alarmSwitchChange(_ sender: UISwitch) {
        let index = sender.tag
        let realm = try! Realm()
        if let alarm = realm.objects(AlarmData.self).sorted(byKeyPath: "creatTime", ascending: false)[safe: index], !alarm.isInvalidated {
            try! realm.write {
                alarm.isEnabled = sender.isOn
            }
        } else {
            print("Alarm has been deleted or invalidated.")
        }
    }
    
    // MARK: - Function
    func loadAlarms() {
        let realm = try! Realm()
        let results = realm.objects(AlarmData.self).sorted(byKeyPath: "creatTime", ascending: false)
        alarms = Array(results)
    }
    
    
    func deleteAlarm(_ alarm: AlarmData, at indexPath: IndexPath) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.delete(alarm)
        }
        alarms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

// MARK: - Extensions

extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.allowsSelection = true
        let cell = tableView.dequeueReusableCell(withIdentifier: SecondTableViewCell.identifier, for: indexPath) as! SecondTableViewCell
        let alarm = alarms[indexPath.row]
        cell.lbList.text = alarm.alarmTime
        cell.lbName.text = alarm.name.isEmpty ? "鬧鐘" : alarm.name
        cell.swAlarm.isOn = alarm.isEnabled
        cell.swAlarm.tag = indexPath.row //存取我開關鬧鐘是在哪一列
        cell.swAlarm.addTarget(self, action: #selector(alarmSwitchChange(_:)), for: .valueChanged)
        cell.swAlarm.isHidden = isEditing
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alarm = alarms[indexPath.row]
        let editAlarmVC = AddAlarmViewController(nibName: "AddAlarmViewController", bundle: nil)
        editAlarmVC.alarmToEdit = alarm
        editAlarmVC.delegate = self
        let navController = UINavigationController(rootViewController: editAlarmVC)
        self.present(navController, animated: true, completion: nil)
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alarm = alarms[indexPath.row]
            deleteAlarm(alarm, at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { //trailingSwipeActionsConfigurationForRowAt 這個是左滑的動作
        if indexPath.section == 0 {
            let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (_, _, completionHandler) in
                guard let self = self else { return }
                let alarm = self.alarms[indexPath.row]
                self.deleteAlarm(alarm, at: indexPath)
                completionHandler(true)
            }
            
            deleteAction.backgroundColor = .red
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = true // 滑動就可執行
            return configuration
        }
        return nil
    }
}

extension MainViewController: AddAlarmViewControllerDelegate {
    func didAddNewAlarm() {
        loadAlarms()
        tableView.reloadData()
    }
    
    func didUpdateAlarm() {
        loadAlarms()
        tableView.reloadData()
    }
    
    func didDeleteAlarm(_ alarm: AlarmData) {
        if let index = alarms.firstIndex(where: { $0 == alarm }) {
           alarms.remove(at: index)
           tableView.reloadData()
       } else {
           print("Failed to find the deleted alarm.")
       }
    }
}

//這邊做了一個自訂下標的動作，意義是讓我在存取的時候，如果超過集合的索引範圍不會崩潰，而是返回nil
extension Collection {
    subscript(safe index: Index) -> Element? {
        //檢查是不是在有效範圍，在的話返回元素，不是的話返回nil
        return indices.contains(index) ? self[index] : nil
    }
}
