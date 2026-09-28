import HealthKit
import LoopKit

extension NewGlucoseSample {
    init(cgmManager: AccuChekCgmManager, value: UInt16, condition: GlucoseCondition?, trend: GlucoseTrend?, dateTime: Date) {
        self.init(
            date: dateTime,
            quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: Double(value)),
            condition: condition,
            trend: trend,
            trendRate: nil,
            isDisplayOnly: false,
            wasUserEntered: false,
            syncIdentifier: "\(dateTime.timeIntervalSince1970)\(value)",
            device: cgmManager.device
        )
    }
    
    init(cgmManager: AccuChekCgmManager, calibrationValue: UInt16, dateTime: Date) {
        self.init(
            date: dateTime,
            quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: Double(calibrationValue)),
            condition: nil,
            trend: nil,
            trendRate: nil,
            isDisplayOnly: false,
            wasUserEntered: true,
            syncIdentifier: "CALIBRATION_\(dateTime.timeIntervalSince1970)\(calibrationValue)",
            device: cgmManager.device
        )
    }
}
