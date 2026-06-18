# AWARE: Barometer

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

This sensor module allows us to manage air-pressure data provided by iOS [CMAltimeter](https://developer.apple.com/documentation/coremotion/cmaltimeter).

## Requirements
iOS 13 or later

## Installation

You can integrate this framework into your project via Swift Package Manager (SwiftPM).

### SwiftPM
1. Open Package Manager Windows
    * Open `Xcode` -> Select `Menu Bar` -> `File` -> `App Package Dependencies...`

2. Find the package using the manager
    * Select `Search Package URL` and type `git@github.com:awareframework/com.awareframework.ios.sensor.barometer.git`

3. Import the package into your target.


## Public Functions

### BarometerSensor

+ `init(config:BarometerSensor.Config)`: Initializes the baromter sensor with the optional configuration.
+ `start()`: Starts the barometer sensor with the optional configuration.
+ `stop()`: Stops the service.

### BarometerSensor.Config

Class to hold the configuration of the sensor.

#### Fields

+ `sensorObserver: BarometerObserver`: Callback for live data updates.
+ `samplingFrequencyHz: Int`: Data samples to collect per second (Hz). (default = `5`)
+ `saveIntervalSeconds: Double`: Interval in seconds at which buffered data is saved to the database. (default = `60`)
+ `threshold: Double`: If set, do not record consecutive points if change in value is less than the set value.
+ `enabled: Bool`: Sensor is enabled or not. (default = `false`)
+ `debug: Bool`: Enable/disable logging. (default = `false`)
+ `label: String`: Label for the data. (default = `""`)
+ `deviceId: String`: Id of the device that will be associated with the events and the sensor. (default = `""`)
+ `dbEncryptionKey: String?`: Encryption key for the database. (default = `nil`)
+ `dbType: DatabaseType`: Which db engine to use for saving data. (default = `.none`)
+ `dbPath: String`: Path of the database. (default = `"aware_barometer"`)
+ `dbHost: String?`: Host for syncing the database. (default = `nil`)

## Data Representations

### Barometer Sensor

Contains the raw sensor data.

| Field          | Type   | Description                                                      |
| -------------- | ------ | ---------------------------------------------------------------- |
| pressure       | Double | The recorded pressure, in kilopascals (kPs).                     |
| eventTimestamp | Int64  | Unixtime milliseconds of the actual sensor event                 |
| label          | String | Customizable label. Useful for data calibration or traceability  |
| deviceId       | String | AWARE device UUID                                                |
| timestamp      | Int64  | Unixtime milliseconds since 1970                                 |
| timezone       | Int    | Timezone of the device                                           |
| os             | String | Operating system of the device (ex. ios)                         |
| jsonVersion    | Int    | JSON schema version                                              |

## Example Usage
```swift
var barometerSensor = BarometerSensor.init(BarometerSensor.Config().apply { config in
    config.sensorObserver = Observer()
    config.debug = true
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

Copyright (c) 2025 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
