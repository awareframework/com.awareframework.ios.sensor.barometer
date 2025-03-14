# AWARE: Barometer

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

This sensor module allows us to manage air-pressure data provided by iOS [CMAltimeter](https://developer.apple.com/documentation/coremotion/cmaltimeter).

## Requirements
iOS 13 or later

## Installation

You can integrate this framework into your project via Swift Package Manager (SwiftPM) or CocoaPods.

### SwiftPM
1. Open Package Manager Windows
    * Open `Xcode` -> Select `Menu Bar` -> `File` -> `App Package Dependencies...` 

2. Find the package using the manager
    * Select `Search Package URL` and type `git@github.com:awareframework/com.awareframework.ios.sensor.barometer.git`

3. Import the package into your target.


### CocoaPods

com.awareframework.ios.sensor.barometer is available through [CocoaPods](https://cocoapods.org). 

1. To install it, simply add the following line to your Podfile:

```ruby
pod 'com.awareframework.ios.sensor.barometer'
```

2. Import com.awareframework.ios.sensor.barometer library into your source code.
```swift
import com_awareframework_ios_sensor_barometer
```

## Public functions

### BarometerSensor

+ `init(config:BarometerSensor.Config)` : Initializes the baromter sensor with the optional configuration.
+ `start()`: Starts the barometer sensor with the optional configuration.
+ `stop()`: Stops the service.

### BarometerSensor.Config

Class to hold the configuration of the sensor.

#### Fields
+ `sensorObserver: BarometerObserver`: Callback for live data updates.
+ `frequency: Int`: Data samples to collect per second (Hz). (default = 5)
+ `period: Double`: Period to save data in minutes. (default = 1)
+ `threshold: Double`: If set, do not record consecutive points if change in value is less than the set value.
+ `enabled: Boolean` Sensor is enabled or not. (default = `false`)
+ `debug: Boolean` enable/disable logging to `Logcat`. (default = `false`)
+ `label: String` Label for the data. (default = "")
+ `deviceId: String` Id of the device that will be associated with the events and the sensor. (default = "")
+ `dbEncryptionKey` Encryption key for the database. (default = `null`)
+ `dbType: Engine` Which db engine to use for saving data. (default = `Engine.DatabaseType.NONE`)
+ `dbPath: String` Path of the database. (default = "aware_barometer")
+ `dbHost: String` Host for syncing the database. (default = `null`)

## Data Representations

### Barometer Sensor

Contains the raw sensor data.

| Field     | Type   | Description                                                      |
| --------- | ------ | ---------------------------------------------------------------- |
| pressure  | Double | The recorded pressure, in kilopascals (kPs).                     |
| label     | String | Customizable label. Useful for data calibration or traceability  |
| deviceId  | String | AWARE device UUID                                                |
| label     | String | Customizable label. Useful for data calibration or traceability  |
| timestamp | Int64   | Unixtime milliseconds since 1970                                 |
| timezone  | Int    | Timezone of the device                                           |
| os        | String | Operating system of the device (ex. android)                     |

## Example usage
```swift
var barometerSensor = BarometerSensor.init(BarometerSensor.Config().apply{config in
    config.sensorObserver = Observer()
    config.debug = true
    config.dbType = .REALM
})
barometerSensor?.start()
barometerSensor?.stop()
```

```swift
class Observer:BarometerObserver{
    func onDataChanged(data: BarometerData) {
        // Your code here..
    }
}
```

## Author
Yuuki Nishiyama (The University of Tokyo), nishiyama@csis.u-tokyo.ac.jp

## Related Links
[ Apple | CMAltimeter ](https://developer.apple.com/documentation/coremotion/cmaltimeter)
[ Apple | CMAltitudeData ](https://developer.apple.com/documentation/coremotion/cmaltitudedata)
[ Apple | Core Motion ](https://developer.apple.com/documentation/coremotion)

## License

Copyright (c) 2018 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
