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
    public static let actionAwareBarometerSetLabel = Notification.Name(BarometerSensor.ACTION_AWARE_BAROMETER_SET_LABEL)
}

public protocol BarometerObserver{
    func onDataChanged(data: BarometerData)
}

public class BarometerSensor: AwareSensor {
    
    public static let TAG = "AWARE::Barometer"
    
    public static let ACTION_AWARE_BAROMETER = "ACTION_AWARE_BAROMETER"
    
    public static let ACTION_AWARE_BAROMETER_START = "com.awareframework.android.sensor.barometer.SENSOR_START"
    public static let ACTION_AWARE_BAROMETER_STOP = "com.awareframework.android.sensor.barometer.SENSOR_STOP"
    
    public static let ACTION_AWARE_BAROMETER_SET_LABEL = "com.awareframework.android.sensor.barometer.ACTION_AWARE_BAROMETER_SET_LABEL"
    public static let EXTRA_LABEL = "label"
    
    public static let ACTION_AWARE_BAROMETER_SYNC = "com.awareframework.android.sensor.barometer.SENSOR_SYNC"
    
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
        
        public convenience init(_ config:Dictionary<String,Any>){
            self.init()
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
    var lastAltimeterData:CMAltitudeData? = nil
    var currentAltimeterData:CMAltitudeData? = nil
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
                    self.currentAltimeterData = altData
                }
            }
        }
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0/Double(self.CONFIG.frequency) , repeats: true, block: { (timer) in
                if let altData = self.currentAltimeterData {
                    let now = Date().timeIntervalSince1970
                    
                    var isSkip = false
                    
                    /** threshold filter */
                    if self.CONFIG.threshold != 0 {
                        if let lastAltData = self.lastAltimeterData {
                            let gap = abs(altData.pressure.doubleValue - lastAltData.pressure.doubleValue)
                            if gap < self.CONFIG.threshold {
                                if self.CONFIG.debug { print(BarometerSensor.TAG, "skip", "threshold", gap) }
                                isSkip = true
                            }
                        }
                    }
                    
                    if !isSkip {
                        let data = BarometerData()
                        data.pressure = altData.pressure.doubleValue          // TODO: check the data format
                        data.eventTimestamp = Int64(altData.timestamp * 1000) // TODO: check the data format
                        if let observer = self.CONFIG.sensorObserver{
                            observer.onDataChanged(data: data)
                        }
                        self.notificationCenter.post(name: .actionAwareBarometer, object: nil)
                        self.dataArray.append(data)
                        
                        self.lastAltimeterData = altData
                        self.lastEventTime = now
                    }
                    
                    /** MEMO: Save dataArray if the "current time" is bigger than "last time" + "save period" */
                    if (self.lastSaveTime + (self.CONFIG.period * 60.0) ) < now {
                        /// save data
                        if let engin = self.dbEngine {
                            if self.dataArray.count > 0 {
                                engin.save(self.dataArray, BarometerData.TABLE_NAME)
                                if self.CONFIG.debug { print(BarometerSensor.TAG, "save data") }
                            }else{
                                if self.CONFIG.debug { print(BarometerSensor.TAG, "no data") }
                            }
                        }
                        self.lastSaveTime = now
                    }
                    self.notificationCenter.post(name: .actionAwareBarometerStart, object: nil)
                }
            })
        }
    }
    
    public override func stop() {
        altimeter.stopRelativeAltitudeUpdates()
        if let t = self.timer{
            t.invalidate()
            self.timer = nil
        }
        self.notificationCenter.post(name: .actionAwareBarometerStop, object: nil)
    }
    
    public override func sync(force: Bool = false) {
        if let engine = self.dbEngine{
            engine.startSync(BarometerData.TABLE_NAME, DbSyncConfig.init().apply{config in
                config.debug = CONFIG.debug
            })
        }
        self.notificationCenter.post(name: .actionAwareBarometerSync, object: nil)
    }
    
}
