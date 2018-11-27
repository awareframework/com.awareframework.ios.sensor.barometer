import XCTest
import com_awareframework_ios_sensor_barometer

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
