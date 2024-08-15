//
//  AddAlarmViewController.swift
//  Clock
//
//  Created by imac-2627 on 2024/8/6.
//

import UIKit
import RealmSwift

protocol AddAlarmViewControllerDelegate: AnyObject {
    func didAddNewAlarm()
}

class AddAlarmViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var datePikcer: UIDatePicker!
    @IBOutlet weak var btnPushToRepeat: UIButton!
    @IBOutlet weak var txfRename: UITextField!
    @IBOutlet weak var btnSetAlarmName: UITextField!
    @IBOutlet weak var btnPushToSound: UIButton!
    @IBOutlet weak var swLaterRemind: UISwitch!
    
    // MARK: - Property
    
    var alarms: [AlarmData] = []
    let isAscending = false
    weak var delegate: AddAlarmViewControllerDelegate?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    // MARK: - UI Settings
    
    func setUI() {
        title = "加入鬧鐘"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancelTapped))
        
    }
    
    // MARK: - IBAction
    @objc func doneTapped() {
        saveAddAlarm()
    }
    
    @objc func cancelTapped() {
        cancelAddAlarm()
    }
    
    @IBAction func pushToRepeat(_ sender: Any) {
        let reapeatVC = RepeatViewController()
        self.navigationController?.pushViewController(reapeatVC, animated: true)
    }
    @IBAction func pushToSound(_ sender: Any) {
        let soundVC = SoundViewController()
        self.navigationController?.pushViewController(soundVC, animated: true)
    }
    
    // MARK: - Function
    func cancelAddAlarm() {
        self.dismiss(animated: true)
    }
    
    func saveAddAlarm() {
        //儲存動作
        let realm = try! Realm()
        let newAlarm = AlarmData(alarmTime: formatDate(datePikcer.date), creatTime: getSystemTime())
        try! realm.write {
            realm.add(newAlarm)
            if isAscending {
                alarms.insert(newAlarm, at: 0)
            }
        }
        
        delegate?.didAddNewAlarm()
        
        print("flies: ", realm.configuration.fileURL!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a HH:mm"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }
    
    func getSystemTime() -> String {
        let currentDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.ReferenceType.system
        dateFormatter.timeZone = TimeZone.ReferenceType.system
        return dateFormatter.string(from: currentDate)
    }
}

// MARK: - Extensions
