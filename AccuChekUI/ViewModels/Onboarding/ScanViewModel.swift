import Combine
import LoopKit
import SwiftUI

class ScanViewModel: ObservableObject {
    @Published var foundDeviceLast: ScanResult? = nil
    @Published var unsupportedDevice: ScanResult? = nil
    @Published var showConfirmationAlert = false
    @Published var showUnsupportedDeviceAlert = false
    @Published var isShowingPlacement = false

    private let logger: AccuChekLogger
    private let cgmManager: AccuChekCgmManager
    private let nextStep: (ScanResult) -> Void
    init(cgmManager: AccuChekCgmManager, nextStep: @escaping (ScanResult) -> Void) {
        logger = AccuChekLogger(category: "ScanViewModel", cgmManager: cgmManager)
        self.cgmManager = cgmManager
        self.nextStep = nextStep

        startScanning()
    }

    deinit {
        cgmManager.bluetooth.stopScan()
    }

    func confirm() {
        guard let device = foundDeviceLast else {
            return
        }

        nextStep(device)
    }

    func startScanning() {
        let previousDeviceName = cgmManager.state.previousDeviceName
        cgmManager.bluetooth.startScan { result in
            if result.deviceName == previousDeviceName {
                self.logger.warning("Found previous CGM while scanning: \(result.deviceName)")
                return
            }

            if result.hasAcsSupport {
                // Found unsupported device...
                self.cgmManager.bluetooth.stopScan()
                DispatchQueue.main.async {
                    self.unsupportedDevice = result
                    self.showUnsupportedDeviceAlert = true
                }
                return
            }

            // Found device (propably)
            self.cgmManager.bluetooth.stopScan()
            DispatchQueue.main.async {
                self.foundDeviceLast = result
                self.showConfirmationAlert = true
            }
        }
    }
}
