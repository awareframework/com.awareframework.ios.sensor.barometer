import XCTest
import RealmSwift
import com_awareframework_ios_sensor_barometer

class Tests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSync(){
        //        let sensor = BarometerSensor.init(BarometerSensor.Config().apply{ config in
        //            config.debug = true
        //            config.dbType = .REALM
        //        })
        //        sensor.start();
        //        sensor.enable();
        //        sensor.sync(force: true)
        
        //        let syncManager = DbSyncManager.Builder()
        //            .setBatteryOnly(false)
        //            .setWifiOnly(false)
        //            .setSyncInterval(1)
        //            .build()
        //
        //        syncManager.start()
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
            // config.dbType = .REALM
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
        let frequency: Int = 10
        let period: Double = 10.0
        let threshold: Double = 1.0
        
        // default values
        var sensor = BarometerSensor.init()
        XCTAssertEqual(5,   sensor.CONFIG.frequency)
        XCTAssertEqual(1.0, sensor.CONFIG.period)
        XCTAssertEqual(0.0, sensor.CONFIG.threshold)
        
        // apply
        sensor = BarometerSensor.init(BarometerSensor.Config().apply{config in
            config.frequency = frequency
            config.period = period
            config.threshold = threshold
        })
        XCTAssertEqual(frequency, sensor.CONFIG.frequency)
        XCTAssertEqual(period,    sensor.CONFIG.period)
        XCTAssertEqual(threshold, sensor.CONFIG.threshold)
        
        // init with dictionary
        sensor = BarometerSensor.init(BarometerSensor.Config.init(["frequency":frequency, "period":period, "threshold":threshold]))
        XCTAssertEqual(frequency, sensor.CONFIG.frequency)
        XCTAssertEqual(period,    sensor.CONFIG.period)
        XCTAssertEqual(threshold, sensor.CONFIG.threshold)
        
        sensor = BarometerSensor()
        sensor.CONFIG.set(config: ["frequency":frequency, "period":period, "threshold":threshold])
        XCTAssertEqual(frequency, sensor.CONFIG.frequency)
        XCTAssertEqual(period,    sensor.CONFIG.period)
        XCTAssertEqual(threshold, sensor.CONFIG.threshold)
    }
    
    func testBarometerData(){
        let data = BarometerData()
        let dict = data.toDictionary()
        XCTAssertEqual(dict["pressure"] as! Double, 0)
        XCTAssertEqual(dict["eventTimestamp"] as! Int64, 0)
    }
}
