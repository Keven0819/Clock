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
    func didUpdateAlarm()
    func didDeleteAlarm(_ alarm: AlarmData)
}

class AddAlarmViewController: UIViewController, RepeatViewControllerDelegate, SoundViewControllerDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnPushToRepeat: UIButton!
    @IBOutlet weak var txfRename: UITextField!
    @IBOutlet weak var btnSetAlarmName: UITextField!
    @IBOutlet weak var btnPushToSound: UIButton!
    @IBOutlet weak var swLaterRemind: UISwitch!
    @IBOutlet weak var btnDelete: UIButton!
    
    // MARK: - Property
    
    var alarms: [AlarmData] = []
    let isAscending = false
    weak var delegate: AddAlarmViewControllerDelegate?
    var repeatDays: [Bool] = Array(repeating: false, count: 7)
    var selectedSound: String = "馬林巴琴"
    var alarmToEdit: AlarmData?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupTextFieldDelegate()
        //setupButtonLayout()
        if let alarm = alarmToEdit {
            populateFields(with: alarm)
        }
    }
    
    // MARK: - UI Settings
    
    func setUI() {
        title = alarmToEdit == nil ? "加入鬧鐘" : "編輯鬧鐘"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .plain, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelTapped))
        updateRepeatButtonTitle()
        updateSoundButtonTitle()
        
        btnDelete.isHidden = alarmToEdit == nil
        btnDelete.setTitle("刪除鬧鐘", for: .normal)
        btnDelete.setTitleColor(.red, for: .normal)
        btnDelete.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
    }
    
    func setupTextFieldDelegate() {
        txfRename.delegate = self
    }
    
    func setupButtonLayout() {
        // 設置 btnPushToRepeat 的 Auto Layout
        btnPushToRepeat.setContentHuggingPriority(.defaultLow, for: .horizontal)
        btnPushToRepeat.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // 設置 btnPushToSound 的 Auto Layout
        btnPushToSound.setContentHuggingPriority(.defaultLow, for: .horizontal)
        btnPushToSound.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func updateRepeatButtonTitle() {
        let daysOfWeek = ["週日", "週一", "週二", "週三", "週四", "週五", "週六"]
        /* 因為我本來宣告repeatDays裡面的值就是布林值，那在我選天數的時候布林值就會變成true或false
         filter這裡會這樣寫是因為我enumerated()之後的數組會變成[(0, true), (2, true)]這樣
         而map的功能秀是把我在這個func宣告的daysOfWeek裡的值根據true或false更換 */
        let selectedDays = repeatDays.enumerated().filter { $0.1 }.map { daysOfWeek[$0.0] }
        
        switch selectedDays.count {
        case 0:
            btnPushToRepeat.setTitle("永不 >", for: .normal)
        case 7:
            btnPushToRepeat.setTitle("每天 >", for: .normal)
        case 1:
            btnPushToRepeat.setTitle("\(selectedDays[0]) >", for: .normal)
        case 2:
            btnPushToRepeat.setTitle("\(selectedDays[0])和\(selectedDays[1]) >", for: .normal)
        default:
            let allButLast = selectedDays.dropLast().joined(separator: "、")
            let last = selectedDays.last!
            btnPushToRepeat.setTitle("\(allButLast)和\(last) >", for: .normal)
        }
        
        btnPushToRepeat.sizeToFit()
    }
    
    func updateSoundButtonTitle() {
       btnPushToSound.setTitle("\(selectedSound) >", for: .normal)
       btnPushToSound.sizeToFit()
   }
    
    // MARK: - IBAction
    @objc func doneTapped() {
        if let alarmToEdit = alarmToEdit {
            updateAlarm(alarmToEdit)
        } else {
            saveNewAlarm()
        }
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func deleteTapped() {
        guard let alarmToDelete = alarmToEdit else { return }
        
        let alertController = UIAlertController(title: "刪除鬧鐘", message: "您確定要刪除此鬧鐘嗎？", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(alarmToDelete)
            }
            
            self.delegate?.didDeleteAlarm(alarmToDelete)
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func pushToRepeat(_ sender: Any) {
        let repeatVC = RepeatViewController()
        repeatVC.delegate = self
        repeatVC.selectedDays = repeatDays
        self.navigationController?.pushViewController(repeatVC, animated: true)
    }
    @IBAction func pushToSound(_ sender: Any) {
        let soundVC = SoundViewController()
        soundVC.delegate = self
        self.navigationController?.pushViewController(soundVC, animated: true)
    }
    
    // MARK: - Function
    func saveNewAlarm() {
        let realm = try! Realm()
        let newAlarm = AlarmData(
            alarmTime: formatDate(datePicker.date),
            creatTime: getSystemTime(),
            name: txfRename.text ?? "",
            repeatDays: repeatDays
        )
        
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
    
    func updateAlarm(_ alarm: AlarmData) {
        let realm = try! Realm()
        try! realm.write {
            alarm.alarmTime = formatDate(datePicker.date)
            alarm.name = txfRename.text ?? ""
            alarm.repeatDays.removeAll()
            alarm.repeatDays.append(objectsIn: repeatDays)
        }
        delegate?.didUpdateAlarm()
        self.dismiss(animated: true, completion: nil)
    }
    
    //日期格式化
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ah:mm"
        formatter.amSymbol = "上午"
        formatter.pmSymbol = "上午"
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
    
    func didUpdateRepeatDays(_ days: [Bool]) {
        repeatDays = days
        updateRepeatButtonTitle()
    }
    
    func didSelectSound(_ soundName: String) {
        selectedSound = soundName
        updateSoundButtonTitle()
    }
    
    //找出現有的鬧鐘
    func populateFields(with alarm: AlarmData) {
        datePicker.date = formatStringToDate(alarm.alarmTime) ?? Date()
        txfRename.text = alarm.name
        repeatDays = Array(alarm.repeatDays)
        updateRepeatButtonTitle()
    }
    
    func formatStringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "ah:mm"
        formatter.amSymbol = "上午"
        formatter.pmSymbol = "下午"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.date(from: dateString)
    }
}

// MARK: - Extensions
extension AddAlarmViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txfRename {
            btnSetAlarmName.text = textField.text
        }
    }
}
