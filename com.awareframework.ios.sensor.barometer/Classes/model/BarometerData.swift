//
//  BarometerData.swift
//  com.aware.ios.sensor.barometer
//
//  Created by Yuuki Nishiyama on 2018/10/25.
//

import UIKit
import com_awareframework_ios_sensor_core

public class BarometerData: AwareObject {
    public static var TABLE_NAME = "barometerData"
    @objc dynamic public var pressure:Double = 0
    @objc dynamic public var eventTimestamp:Int64 = 0
    @objc dynamic public var accuracy:Int = 0
    
    public override func toDictionary() -> Dictionary<String, Any> {
        var dict = super.toDictionary()
        dict["pressure"] = pressure
        dict["eventTimestamp"] = eventTimestamp
        dict["accuracy"] = accuracy
        return dict
    }
}
