import Combine
import LoopKit
import SwiftUI

class PairingViewModel: ObservableObject {
    @Published var modelUnsupported = false
    
    private let logger: AccuChekLogger
    private let cgmManager: AccuChekCgmManager
    let nextStep: () -> Void
    init(_ cgmManager: AccuChekCgmManager, scanResult: ScanResult?, nextStep: @escaping () -> Void) {
        logger = AccuChekLogger(category: "PairingViewModel", cgmManager: cgmManager)
        self.cgmManager = cgmManager
        self.nextStep = nextStep

        if let scanResult {
            connect(result: scanResult)
        }
    }

    func connect(result: ScanResult) {
        cgmManager.state.deviceName = result.deviceName
        cgmManager.notifyStateDidChange()

        cgmManager.bluetooth.connect(to: result.peripheral) { error in
            if let error {
                self.logger.error("Failed to connect to CGM: \(error)")
                return
            }

            self.cgmManager.state.onboarded = true
            self.cgmManager.state.deviceName = result.deviceName
            self.cgmManager.notifyStateDidChange()

            self.cgmManager.notifyUpdatedCgm(type: .sensorStart)
            
            if let model = self.cgmManager.state.sensorInfo?.model, model != "303" {
                DispatchQueue.main.async {
                    self.modelUnsupported = true
                }
                return
            }

            self.nextStep()
        }
    }
}
