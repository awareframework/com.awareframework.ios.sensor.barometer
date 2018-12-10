//
//  BarometerSensor.swift
//  com.aware.ios.sensor.barometer
//
//  Created by Yuuki Nishiyama on 2018/10/25.
//

import UIKit
import CoreMotion
import com_awareframework_ios_sensor_core

extension Notification.Name{
    public static let actionAwareBarometer      = Notification.Name(BarometerSensor.ACTION_AWARE_BAROMETER)
    public static let actionAwareBarometerStart = Notification.Name(BarometerSensor.ACTION_AWARE_BAROMETER_START)
    public static let actionAwareBarometerStop  = Notification.Name(BarometerSensor.ACTION_AWARE_BAROMETER_STOP)
    public static let actionAwareBarometerSync  = Notification.Name(BarometerSensor.ACTION_AWARE_BAROMETER_SYNC)
    public static let actionAwareBarometerSyncCompletion  = Notification.Name(BarometerSensor.ACTION_AWARE_BAROMETER_SYNC_COMPLETION)
    public static let actionAwareBarometerSetLabel = Notification.Name(BarometerSensor.ACTION_AWARE_BAROMETER_SET_LABEL)
}

public protocol BarometerObserver{
    func onDataChanged(data: BarometerData)
}

public class BarometerSensor: AwareSensor {
    
    public static let TAG = "AWARE::Barometer"
    
    public static let ACTION_AWARE_BAROMETER = "com.awareframework.ios.sensor.barometer"
    
    public static let ACTION_AWARE_BAROMETER_START = "com.awareframework.ios.sensor.barometer.SENSOR_START"
    public static let ACTION_AWARE_BAROMETER_STOP = "com.awareframework.ios.sensor.barometer.SENSOR_STOP"
    
    public static let ACTION_AWARE_BAROMETER_SET_LABEL = "com.awareframework.ios.sensor.barometer.ACTION_AWARE_BAROMETER_SET_LABEL"
    public static let EXTRA_LABEL = "label"
    
    public static let ACTION_AWARE_BAROMETER_SYNC = "com.awareframework.ios.sensor.barometer.SENSOR_SYNC"
    public static let ACTION_AWARE_BAROMETER_SYNC_COMPLETION = "com.awareframework.ios.sensor.barometer.SENSOR_SYNC_COMPLETION"
    
    public var CONFIG = Config()
    
    var timer:Timer? = nil
    
    public class Config:SensorConfig{
        /**
         * For real-time observation of the sensor data collection.
         */
        public var sensorObserver: BarometerObserver? = nil
        
        /**
         * Barometer interval in hertz per second: e.g.
         * 0 - fastest
         * 1 - sample per second
         * 5 - sample per second
         * 20 - sample per second
         * The maximum interval is 1 on iOS.
         */
        public var frequency: Int = 5
        
        /**
         * Period to save data in minutes. (optional)
         */
        public var period: Double = 1
        
        /**
         * Barometer threshold (double).  Do not record consecutive points if
         * change in value is less than the set value.
         */
        public var threshold: Double = 0.0
        
        public override init(){
            super.init()
            dbPath = "aware_barometer"
        }
        
        public override func set(config: Dictionary<String, Any>) {
            super.set(config: config)
            if let frequency = config["frequency"] as? Int {
                self.frequency = frequency
            }
            
            if let period = config["period"] as? Double {
                self.period = period
            }
            
            if let threshold = config["threshold"] as? Double {
                self.threshold = threshold
            }
        }
        
        public func apply(closure:(_ config: BarometerSensor.Config ) -> Void ) -> Self{
            closure(self)
            return self
        }
    }
    
    public override convenience init(){
        self.init(BarometerSensor.Config())
    }
    
    public init(_ config: BarometerSensor.Config){
        super.init()
        CONFIG = config
        initializeDbEngine(config: config)
    }
    
    ////////////////////////////////////
    var altimeter = CMAltimeter()
    var lastSaveTime:Double  = 0
    var lastEventTime:Double = 0
    var lastPressure:NSNumber? = nil
    var currentPressure:NSNumber? = nil
    var dataArray = Array<BarometerData>()
    
    public override func start() {
        // https://developer.apple.com/documentation/coremotion/cmaltimeter
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (altimeterData, error) in
                /**
                 * interval: Int: Data samples to collect per second. (default = 5)
                 * period: Float: Period to save data in minutes. (default = 1)
                 * threshold: Double: If set, do not record consecutive points if change in value is less than the set value.
                 */
                if let altData = altimeterData {
                    self.currentPressure = altData.pressure
                }
            }
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0/Double(self.CONFIG.frequency) , repeats: true, block: { (timer) in
                    if let data = self.currentPressure {
                        self.save(pressure: data.doubleValue)
                    }
                })
            }
            self.notificationCenter.post(name: .actionAwareBarometerStart, object: self)
        }
    }
    
    public override func stop() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.stopRelativeAltitudeUpdates()
            if let t = self.timer{
                t.invalidate()
                self.timer = nil
            }
            self.notificationCenter.post(name: .actionAwareBarometerStop, object: self)
        }
    }
    
    public override func sync(force: Bool = false) {
        if let engine = self.dbEngine{
            engine.startSync(BarometerData.TABLE_NAME, BarometerData.self, DbSyncConfig.init().apply{config in
                config.debug = CONFIG.debug
                config.debug = self.CONFIG.debug
                config.dispatchQueue = DispatchQueue(label: "com.awareframework.ios.sensor.barometer.sync.queue")
                config.completionHandler = { (status, error) in
                    var userInfo: Dictionary<String,Any> = ["status":status]
                    if let e = error {
                        userInfo["error"] = e
                    }
                    self.notificationCenter.post(name: .actionAwareBarometerSyncCompletion,
                                                 object: self,
                                                 userInfo:userInfo)
                }
            })
            self.notificationCenter.post(name: .actionAwareBarometerSync, object: self)
        }
    }
    
    public override func set(label:String){
        self.CONFIG.label = label
        self.notificationCenter.post(name: .actionAwareBarometerSetLabel,
                                     object:nil,
                                     userInfo:[BarometerSensor.EXTRA_LABEL:label] )
    }
    
    // The pressure in kPa.
    public func save(pressure:Double){
        let now = Date().timeIntervalSince1970
        
        var isSkip = false
        
        /** threshold filter */
        if self.CONFIG.threshold != 0 {
            if let lastAltData = self.lastPressure {
                let gap = abs(pressure - lastAltData.doubleValue)
                if gap < self.CONFIG.threshold {
                    if self.CONFIG.debug { print(BarometerSensor.TAG, "skip", "threshold", gap) }
                    isSkip = true
                }
            }
        }
        
        if !isSkip {
            let data = BarometerData()
            data.pressure = pressure          // TODO: check the data format
            data.eventTimestamp = Int64(data.timestamp * 1000) // TODO: check the data format
            if let observer = self.CONFIG.sensorObserver{
                observer.onDataChanged(data: data)
            }
            self.dataArray.append(data)
            
            self.lastPressure = pressure as NSNumber
            self.lastEventTime = now
        }
        
        /** MEMO: Save dataArray if the "current time" is bigger than "last time" + "save period" */
        if (self.lastSaveTime + (self.CONFIG.period * 60.0) ) < now {
            /// save data
            if let engin = self.dbEngine {
                if self.dataArray.count > 0 {
                
                    let queue = DispatchQueue(label: "com.awareframework.ios.sensor.barometer.save.queue")
                    queue.async {
                        engin.save(self.dataArray){ error in
                            if self.CONFIG.debug { print(BarometerSensor.TAG, "save data") }
                            DispatchQueue.main.async {
                                self.notificationCenter.post(name: .actionAwareBarometer, object: self)
                                self.lastSaveTime = now
                            }
                        }
                    }
                }else{
                    if self.CONFIG.debug { print(BarometerSensor.TAG, "no data") }
                    self.lastSaveTime = now
                }
            }else{
                self.lastSaveTime = now
            }
        }
    }
}
