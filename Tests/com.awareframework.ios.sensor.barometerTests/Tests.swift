import XCTest
import com_awareframework_ios_sensor_barometer
import com_awareframework_ios_core

class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSyncModule(){
        #if targetEnvironment(simulator)

        print("This test requires a real device.")

        #else
        // success //
        let sensor = BarometerSensor.init(BarometerSensor.Config().apply{ config in
            config.debug = true
            config.dbHost = "node.awareframework.com:1001"
            config.dbPath = "sync_db"
        })
        let successExpectation = XCTestExpectation(description: "success sync")
        let observer = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareBarometerSyncCompletion,
                                                              object: sensor, queue: .main) { (notification) in
                                                                if let userInfo = notification.userInfo{
                                                                    if let status = userInfo["status"] as? Bool {
                                                                        if status == true {
                                                                            successExpectation.fulfill()
                                                                        }
                                                                    }
                                                                }
        }
        sensor.sync(force: true)
        wait(for: [successExpectation], timeout: 20)
        NotificationCenter.default.removeObserver(observer)

        ////////////////////////////////////

        // failure //
        let sensor2 = BarometerSensor.init(BarometerSensor.Config().apply{ config in
            config.debug = true
            config.dbHost = "node.awareframework.com.com" // wrong url
            config.dbPath = "sync_db"
        })
        let failureExpectation = XCTestExpectation(description: "failure sync")
        let failureObserver = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareBarometerSyncCompletion,
                                                                     object: sensor2, queue: .main) { (notification) in
                                                                        if let userInfo = notification.userInfo{
                                                                            if let status = userInfo["status"] as? Bool {
                                                                                if status == false {
                                                                                    failureExpectation.fulfill()
                                                                                }
                                                                            }
                                                                        }
        }
        sensor2.sync(force: true)
        wait(for: [failureExpectation], timeout: 20)
        NotificationCenter.default.removeObserver(failureObserver)

        #endif
    }

    func testObserver(){
        #if targetEnvironment(simulator)
        print("This test requires a real device.")

        #else

        class Observer:BarometerObserver{
            weak var barometerExpectation: XCTestExpectation?
            func onDataChanged(data: BarometerData) {
                print(#function)
                barometerExpectation?.fulfill()
            }
        }

        let barometerObserverExpect = expectation(description: "start observer")
        let observer = Observer()
        observer.barometerExpectation = barometerObserverExpect
        let sensor = BarometerSensor.init(BarometerSensor.Config().apply{ config in
            config.sensorObserver = observer
        })
        sensor.start()

        wait(for: [barometerObserverExpect], timeout: 3)
        sensor.stop()

        #endif

    }

    func testControllers(){

        let sensor = BarometerSensor.init(BarometerSensor.Config().apply{ config in
            config.debug = true
        })

        /// test set label action ///
        let expectSetLabel = expectation(description: "set label")
        let newLabel = "hello"
        let labelObserver = NotificationCenter.default.addObserver(forName: .actionAwareBarometerSetLabel, object: nil, queue: .main) { (notification) in
            let dict = notification.userInfo;
            if let d = dict as? Dictionary<String,String>{
                XCTAssertEqual(d[BarometerSensor.EXTRA_LABEL], newLabel)
            }else{
                XCTFail()
            }
            expectSetLabel.fulfill()
        }
        sensor.set(label:newLabel)
        wait(for: [expectSetLabel], timeout: 5)
        NotificationCenter.default.removeObserver(labelObserver)

        /// test sync action ////
        let expectSync = expectation(description: "sync")
        let syncObserver = NotificationCenter.default.addObserver(forName: Notification.Name.actionAwareBarometerSync , object: nil, queue: .main) { (notification) in
            expectSync.fulfill()
            print("sync")
        }
        sensor.sync()
        wait(for: [expectSync], timeout: 5)
        NotificationCenter.default.removeObserver(syncObserver)


        #if targetEnvironment(simulator)

        print("Controller tests (start and stop) require a real device.")

        #else

        //// test start action ////
        let expectStart = expectation(description: "start")
        let observer = NotificationCenter.default.addObserver(forName: .actionAwareBarometerStart,
                                                              object: nil,
                                                              queue: .main) { (notification) in
                                                                expectStart.fulfill()
                                                                print("start")
        }
        sensor.start()
        wait(for: [expectStart], timeout: 5)
        NotificationCenter.default.removeObserver(observer)


        /// test stop action ////
        let expectStop = expectation(description: "stop")
        let stopObserver = NotificationCenter.default.addObserver(forName: .actionAwareBarometerStop, object: nil, queue: .main) { (notification) in
            expectStop.fulfill()
            print("stop")
        }
        sensor.stop()
        wait(for: [expectStop], timeout: 5)
        NotificationCenter.default.removeObserver(stopObserver)

        #endif
    }

    func testConfig(){
        let samplingFrequencyHz: Int = 10
        let saveIntervalSeconds: Double = 10.0
        let threshold: Double = 1.0

        // default values
        var sensor = BarometerSensor.init()
        XCTAssertEqual(5,   sensor.CONFIG.samplingFrequencyHz)
        XCTAssertEqual(60.0, sensor.CONFIG.saveIntervalSeconds)
        XCTAssertEqual(0.0, sensor.CONFIG.threshold)

        // apply
        sensor = BarometerSensor.init(BarometerSensor.Config().apply{config in
            config.samplingFrequencyHz = samplingFrequencyHz
            config.saveIntervalSeconds = saveIntervalSeconds
            config.threshold = threshold
        })
        XCTAssertEqual(samplingFrequencyHz, sensor.CONFIG.samplingFrequencyHz)
        XCTAssertEqual(saveIntervalSeconds,    sensor.CONFIG.saveIntervalSeconds)
        XCTAssertEqual(threshold, sensor.CONFIG.threshold)

        // init with dictionary
        sensor = BarometerSensor.init(BarometerSensor.Config.init(["samplingFrequencyHz":samplingFrequencyHz, "saveIntervalSeconds":saveIntervalSeconds, "threshold":threshold]))
        XCTAssertEqual(samplingFrequencyHz, sensor.CONFIG.samplingFrequencyHz)
        XCTAssertEqual(saveIntervalSeconds,    sensor.CONFIG.saveIntervalSeconds)
        XCTAssertEqual(threshold, sensor.CONFIG.threshold)

        sensor = BarometerSensor()
        sensor.CONFIG.set(config: ["samplingFrequencyHz":samplingFrequencyHz, "saveIntervalSeconds":saveIntervalSeconds, "threshold":threshold])
        XCTAssertEqual(samplingFrequencyHz, sensor.CONFIG.samplingFrequencyHz)
        XCTAssertEqual(saveIntervalSeconds,    sensor.CONFIG.saveIntervalSeconds)
        XCTAssertEqual(threshold, sensor.CONFIG.threshold)
    }

    func testBarometerData(){
        let data = BarometerData()
        let dict = data.toDictionary()
        XCTAssertEqual(dict["pressure"] as! Double, 0)
        XCTAssertEqual(dict["eventTimestamp"] as! Int64, 0)
    }
}
