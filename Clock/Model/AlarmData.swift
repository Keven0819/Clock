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
    
    convenience init(alarmTime: String, creatTime: String) {
        self.init()
        self.alarmTime = alarmTime
        self.creatTime = creatTime
    }
}
