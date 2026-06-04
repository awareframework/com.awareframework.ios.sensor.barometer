import Foundation
import com_awareframework_ios_core
import GRDB

public struct BarometerData: BaseDbModelSQLite {
    public var id: Int64?
    public var timestamp: Int64 = 0
    public var deviceId: String = AwareUtils.getCommonDeviceId()
    public var label: String = ""
    public var timezone: Int = AwareUtils.getTimeZone()
    public var os: String = "iOS"
    public var jsonVersion: Int = 1
    public static let databaseTableName = "barometerData"

    public var pressure: Double = 0
    public var eventTimestamp: Int64 = 0

    public init() {}
    public init(_ dict: Dictionary<String, Any>) {
        timestamp      = dict["timestamp"] as? Int64 ?? 0
        label          = dict["label"] as? String ?? ""
        deviceId       = dict["deviceId"] as? String ?? AwareUtils.getCommonDeviceId()
        timezone       = dict["timezone"] as? Int ?? AwareUtils.getTimeZone()
        os             = dict["os"] as? String ?? "iOS"
        jsonVersion    = dict["jsonVersion"] as? Int ?? 1
        pressure       = dict["pressure"] as? Double ?? 0
        eventTimestamp = dict["eventTimestamp"] as? Int64 ?? 0
    }
    public static func createTable(queue: DatabaseQueue) throws {
        try queue.write { db in
            try db.create(table: databaseTableName, ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("deviceId", .text).notNull()
                t.column("timestamp", .integer).notNull()
                t.column("label", .text).notNull()
                t.column("pressure", .double).notNull()
                t.column("timezone", .integer).notNull()
                t.column("os", .text).notNull()
                t.column("jsonVersion", .integer).notNull()
                t.column("eventTimestamp", .integer).notNull()
            }
            try migrateBaseColumnsIfNeeded(db)
        }
    }

    private static func migrateBaseColumnsIfNeeded(_ db: Database) throws {
        let columns = Set(try db.columns(in: databaseTableName).map(\.name))
        if columns.contains("timezone") == false {
            try db.alter(table: databaseTableName) { t in
                t.add(column: "timezone", .integer).notNull().defaults(to: AwareUtils.getTimeZone())
            }
        }
        if columns.contains("os") == false {
            try db.alter(table: databaseTableName) { t in
                t.add(column: "os", .text).notNull().defaults(to: "iOS")
            }
        }
        if columns.contains("jsonVersion") == false {
            try db.alter(table: databaseTableName) { t in
                t.add(column: "jsonVersion", .integer).notNull().defaults(to: 1)
            }
        }
    }

    public func toDictionary() -> Dictionary<String, Any> {
        ["id": id ?? -1, "timestamp": timestamp, "deviceId": deviceId, "label": label,
         "timezone": timezone, "os": os, "jsonVersion": jsonVersion,
         "pressure": pressure, "eventTimestamp": eventTimestamp]
    }
}
