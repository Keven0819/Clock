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
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAlarms()
        tableView.reloadData()
    }
    
    // MARK: - UI Settings
    
    func setUI() {
        setTableView()
    }
    
    func setTableView() {
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: MainTableViewCell.identifier)
        tableView.register(UINib(nibName: "SecondTableViewCell", bundle: nil), forCellReuseIdentifier: SecondTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "編輯", style: .done, target: self, action: #selector(editTapped))
    }
    
    // MARK: - IBAction
    
    @objc func doneTapped() {
        addAlarm()
    }
    
    @objc func editTapped() {
        editAlarm()
    }
    
    
    
    // MARK: - Function
    func loadAlarms() {
        let realm = try! Realm()
        let results = realm.objects(AlarmData.self).sorted(byKeyPath: "creatTime", ascending: false)
        alarms = Array(results)
    }
    
    
    func deleteAlarm(_ alarm: AlarmData, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "刪除", message: "確定刪除嗎", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "確定", style:  .default) { [weak self] _ in
            guard let self = self else { return }
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(alarm)
            }
            
            //更新數據
            self.alarms.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func editAlarm() {
    }
    
    func addAlarm() {
        let addAlarmVC = AddAlarmViewController(nibName: "AddAlarmViewController", bundle: nil)
        addAlarmVC.delegate = self
        let navController = UINavigationController(rootViewController: addAlarmVC)
        self.present(navController, animated: true, completion: nil)
    }
}

// MARK: - Extensions

extension MainViewController: UITableViewDelegate, UITableViewDataSource, AddAlarmViewControllerDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return pageTitle.count
        case 1:
            return alarms.count
        default:
            return pageTitle.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
            cell.lbTitle.text = pageTitle[0]
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SecondTableViewCell.identifier, for: indexPath) as! SecondTableViewCell
            let alarm = alarms[indexPath.row]
            let formatter = DateFormatter()
            formatter.dateFormat = "a HH:mm"
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "zh_TW")
            cell.lbList.text = alarm.alarmTime
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
            cell.lbTitle.text = pageTitle[0]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { //trailingSwipeActionsConfigurationForRowAt 這個是左滑的動作
        if indexPath.section == 1 {
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
    
    func didAddNewAlarm() {
        loadAlarms()
        tableView.reloadData()
    }
}
