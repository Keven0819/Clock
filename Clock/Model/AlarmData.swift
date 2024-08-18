//
//  AlarmData.swift
//  Clock
//
//  Created by imac-2627 on 2024/8/15.
//

import Foundation
import RealmSwift

class AlarmData: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var alarmTime: String = ""
    @Persisted var creatTime: String = "" //創建鬧鐘的時間
    @Persisted var name: String = ""
    @Persisted var repeatDays: List<Bool> = List<Bool>()
    @Persisted var isEnabled: Bool = true
    
    convenience init(alarmTime: String, creatTime: String, name: String = "",
                     repeatDays: [Bool] = Array(repeating: false, count: 7)) {
        self.init()
        self.alarmTime = alarmTime
        self.creatTime = creatTime
        self.name = name
        self.repeatDays.append(objectsIn: repeatDays)
    }
}
