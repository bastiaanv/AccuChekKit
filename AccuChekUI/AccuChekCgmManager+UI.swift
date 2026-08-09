import LoopKit
import LoopKitUI

extension AccuChekCgmManager: CGMManagerUI {
    public static func setupViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference: DisplayGlucosePreference,
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures _: Bool,
        prefersToSkipUserInteraction _: Bool = false
    ) -> SetupUIResult<CGMManagerViewController, CGMManagerUI> {
        let vc = AccuChekUIController(
            colorPalette: colorPalette,
            displayGlucosePreference: displayGlucosePreference
        )
        return .userInteractionRequired(vc)
    }

    public func settingsViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference: DisplayGlucosePreference,
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures _: Bool
    ) -> CGMManagerViewController {
        AccuChekUIController(
            cgmManager: self,
            colorPalette: colorPalette,
            displayGlucosePreference: displayGlucosePreference
        )
    }

    public static var onboardingImage: UIImage? {
        UIImage(named: "sensor", in: Bundle(for: AccuChekUIController.self), compatibleWith: nil)
    }

    public var smallImage: UIImage? {
        UIImage(named: "sensor", in: Bundle(for: AccuChekUIController.self), compatibleWith: nil)
    }

    public var cgmStatusHighlight: (any LoopKit.DeviceStatusHighlight)? {
        var status = state.cgmStatus
        if status.contains(.calibrationNotAllowed) {
            status = status.filter { $0 != .calibrationRequired && $0 != .calibrationRecommended }
        }

        let cgmNotifications = status.compactMap(\.notification)
        if let notification = cgmNotifications.first {
            let calibrationTitle = String(localized: "Sensor calibration", comment: "title sensor fault")

            return AccuChekDeviceStatusHighlight(
                localizedMessage: notification.backgroundContent.title,
                imageName: "exclamationmark.triangle",
                state: notification.backgroundContent.title == calibrationTitle ? .warning : .critical
            )
        }

        return nil
    }

    public var cgmLifecycleProgress: (any LoopKit.DeviceLifecycleProgress)? {
        guard let expiresAt = state.expiresAt, let activatedAt = state.cgmStartTime else {
            return nil
        }

        if expiresAt.addingTimeInterval(.days(-1)) <= Date.now {
            // Show warning in last 24h
            return AccuChekKitLifecycleProgress(
                percentComplete: getCgmProgress(activatedAt: activatedAt),
                progressState: .warning
            )
        }

        if expiresAt.addingTimeInterval(.days(-3)) <= Date.now {
            // Show progress in last 72h
            return AccuChekKitLifecycleProgress(
                percentComplete: getCgmProgress(activatedAt: activatedAt),
                progressState: .normalCGM
            )
        }

        return nil
    }

    public var cgmStatusBadge: (any LoopKitUI.DeviceStatusBadge)? {
        // Show exclamation mark for every notification (might be sensor failure or calibation required)
        if !state.cgmStatus.compactMap(\.notification).isEmpty {
            return AccuChekDeviceStatusBadge()
        }

        return nil
    }

    private func getCgmProgress(activatedAt: Date) -> Double {
        let age = activatedAt.timeIntervalSinceNow * -1
        return age / .days(14)
    }
}

struct AccuChekDeviceStatusBadge: DeviceStatusBadge {
    var image: UIImage? = UIImage(systemName: "exclamationmark.triangle")
    var state: LoopKitUI.DeviceStatusBadgeState = .critical
}

struct AccuChekKitLifecycleProgress: DeviceLifecycleProgress {
    var percentComplete: Double
    var progressState: LoopKit.DeviceLifecycleProgressState
}

struct AccuChekDeviceStatusHighlight: LoopKit.DeviceStatusHighlight {
    var localizedMessage: String
    var imageName: String
    var state: LoopKit.DeviceStatusHighlightState
}
