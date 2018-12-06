//
//  ViewController.swift
//  com.awareframework.ios.sensor.barometer
//
//  Created by tetujin on 11/20/2018.
//  Copyright (c) 2018 tetujin. All rights reserved.
//

import UIKit
import com_awareframework_ios_sensor_barometer

class ViewController: UIViewController {

    var sensor:BarometerSensor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        sensor = BarometerSensor.init(BarometerSensor.Config().apply{config in
//            config.debug = true
//            config.sensorObserver = Observer()
//        })
//        sensor?.start()
    }

    class Observer:BarometerObserver {
        func onDataChanged(data: BarometerData) {
            print(data)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

