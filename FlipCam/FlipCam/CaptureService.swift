//
//  CaptureService.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import Foundation
import AVFoundation

actor CaptureService {

	@Published private(set) var captureActivity: CaptureActivity = .idle
	@Published private(set) var isInterrupted = false
	@Published var isShowingFullscreenControls = false

	nonisolated let previewSource: PreviewSource

	private let captureSession = AVCaptureSession()

	private let photoCapture = PhotoCapture()

	private var activeCameraInput: AVCaptureDeviceInput?

	private let deviceLookup = DeviceLookup()

	private let systemPreferredCamera = SystemPreferredCameraObserver()

	private var rotationCoordinator: AVCaptureDevice.RotationCoordinator!
	private var rotationObservers = [AnyObject]()

	private var isSetUp = false

	init() {
		previewSource = DefaultPreviewSource(session: captureSession)
	}

	// MARK: - Authorization
	var isAuthorized: Bool {
		get async {
			let status = AVCaptureDevice.authorizationStatus(for: .video)
			var isAuthorized = status == .authorized
			if status == .notDetermined {
				isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
			}
			return isAuthorized
		}
	}

	// MARK: - Capture session life cycle
	func start() async throws {
		guard await isAuthorized, !captureSession.isRunning else { return }
		try setUpSession()
		captureSession.startRunning()
	}

	// MARK: - Capture setup
	private func setUpSession() throws {
		guard !isSetUp else { return }

		observeOutputServices()
		observeNotifications()

		do {
			let defaultCamera = try deviceLookup.defaultCamera
			activeCameraInput = try addInput(for: defaultCamera)
			captureSession.sessionPreset = .photo
			try addOutput(photoCapture.output)

			monitorSystemPreferredCamera()
			createRotationCoordinator(for: defaultCamera)
			observeSubjectAreaChanges(of: defaultCamera)

			isSetUp = true
		} catch {
			throw CameraError.setupFailed
		}
	}

	private func addInput(for device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
		let input = try AVCaptureDeviceInput(device: device)
		if captureSession.canAddInput(input) {
			captureSession.addInput(input)
		} else {
			throw CameraError.addInputFailed
		}
		return input
	}

	private func addOutput(_ output: AVCaptureOutput) throws {
		if captureSession.canAddOutput(output) {
			captureSession.addOutput(output)
		} else {
			throw CameraError.addOutputFailed
		}
	}

	private var currentDevice: AVCaptureDevice {
		guard let device = activeCameraInput?.device else {
			fatalError("No device found for current video input.")
		}
		return device
	}

	// MARK: - Device selection

	func selectNextCameraDevice() {
		let cameraDevices = deviceLookup.cameras

		let selectedIndex = cameraDevices.firstIndex(of: currentDevice) ?? 0
		var nextIndex = selectedIndex + 1
		if nextIndex == cameraDevices.endIndex {
			nextIndex = 0
		}

		let nextDevice = cameraDevices[nextIndex]
		changeCaptureDevice(to: nextDevice)

		AVCaptureDevice.userPreferredCamera = nextDevice
	}

	private func changeCaptureDevice(to device: AVCaptureDevice) {
		guard let currentInput = activeCameraInput else { fatalError() }

		captureSession.beginConfiguration()
		defer { captureSession.commitConfiguration() }

		captureSession.removeInput(currentInput)
		do {
			activeCameraInput = try addInput(for: device)
			createRotationCoordinator(for: device)
			observeSubjectAreaChanges(of: device)
		} catch {
			captureSession.addInput(currentInput)
		}
	}

	private func monitorSystemPreferredCamera() {
		Task {
			for await camera in systemPreferredCamera.changes {
				if let camera, currentDevice != camera {
					logger.debug("Switching camera selection to the system-preferred camera.")
					changeCaptureDevice(to: camera)
				}
			}
		}
	}

	// MARK: - Rotation handling

	private func createRotationCoordinator(for device: AVCaptureDevice) {
		rotationCoordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: videoPreviewLayer)

		updatePreviewRotation(rotationCoordinator.videoRotationAngleForHorizonLevelPreview)
		updateCaptureRotation(rotationCoordinator.videoRotationAngleForHorizonLevelCapture)

		rotationObservers.removeAll()

		rotationObservers.append(
			rotationCoordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: .new) { [weak self] _, change in
				guard let self, let angle = change.newValue else { return }
				Task { await self.updatePreviewRotation(angle) }
			}
		)

		rotationObservers.append(
			rotationCoordinator.observe(\.videoRotationAngleForHorizonLevelCapture, options: .new) { [weak self] _, change in
				guard let self, let angle = change.newValue else { return }
				Task { await self.updateCaptureRotation(angle) }
			}
		)
	}

	private func updatePreviewRotation(_ angle: CGFloat) {
		let previewLayer = videoPreviewLayer
		Task { @MainActor in
			previewLayer.connection?.videoRotationAngle = angle
		}
	}

	private func updateCaptureRotation(_ angle: CGFloat) {
		photoCapture.setCameraRotationAngle(angle)
	}

	private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
		guard let previewLayer = captureSession.connections.compactMap({ $0.videoPreviewLayer }).first else {
			fatalError("The app is misconfigured. The capture session should have a connection to a preview layer.")
		}
		return previewLayer
	}

	// MARK: - Automatic focus and exposure

	func focusAndExpose(at point: CGPoint) {
		let devicePoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point)
		do {
			try focusAndExpose(at: devicePoint, isUserInitiated: true)
		} catch {
			logger.debug("Unable to perform focus and exposure operation. \(error)")
		}
	}

	private var subjectAreaChangeTask: Task<Void, Never>?
	private func observeSubjectAreaChanges(of device: AVCaptureDevice) {
		subjectAreaChangeTask?.cancel()
		subjectAreaChangeTask = Task {
			for await _ in NotificationCenter.default.notifications(named: AVCaptureDevice.subjectAreaDidChangeNotification, object: device).compactMap({ _ in true }) {
				try? focusAndExpose(at: CGPoint(x: 0.5, y: 0.5), isUserInitiated: false)
			}
		}
	}

	private func focusAndExpose(at devicePoint: CGPoint, isUserInitiated: Bool) throws {
		let device = currentDevice

		try device.lockForConfiguration()

		let focusMode = isUserInitiated ? AVCaptureDevice.FocusMode.autoFocus : .continuousAutoFocus
		if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
			device.focusPointOfInterest = devicePoint
			device.focusMode = focusMode
		}

		let exposureMode = isUserInitiated ? AVCaptureDevice.ExposureMode.autoExpose : .continuousAutoExposure
		if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
			device.exposurePointOfInterest = devicePoint
			device.exposureMode = exposureMode
		}
		device.isSubjectAreaChangeMonitoringEnabled = isUserInitiated

		device.unlockForConfiguration()
	}

	// MARK: - Zoom

	func setZoom(factor: CGFloat) async {
		let device = currentDevice
		do {
			try device.lockForConfiguration()
			device.videoZoomFactor = max(1.0, min(factor, device.maxAvailableVideoZoomFactor))
			device.unlockForConfiguration()
		} catch {
			logger.error("Error setting zoom: \(error.localizedDescription)")
		}
	}

	func rampZoom(to factor: CGFloat) async {
		let device = currentDevice
		do {
			try device.lockForConfiguration()
			device.ramp(toVideoZoomFactor: max(1.0, min(factor, device.maxAvailableVideoZoomFactor)),
						withRate: 1.0)
			device.unlockForConfiguration()
		} catch {
			logger.error("Error ramping zoom: \(error.localizedDescription)")
		}
	}

	// MARK: - Photo capture
	func capturePhoto() async throws -> Photo {
		try await photoCapture.capturePhoto()
	}

	// MARK: - Internal state management
	private func observeOutputServices() {
		photoCapture.$captureActivity.assign(to: &$captureActivity)
	}

	private func observeNotifications() {
		Task {
			for await reason in NotificationCenter.default.notifications(named: AVCaptureSession.wasInterruptedNotification)
				.compactMap({ $0.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject? })
				.compactMap({ AVCaptureSession.InterruptionReason(rawValue: $0.integerValue) }) {
				isInterrupted = [.audioDeviceInUseByAnotherClient, .videoDeviceInUseByAnotherClient].contains(reason)
			}
		}

		Task {
			for await _ in NotificationCenter.default.notifications(named: AVCaptureSession.interruptionEndedNotification) {
				isInterrupted = false
			}
		}

		Task {
			for await error in NotificationCenter.default.notifications(named: AVCaptureSession.runtimeErrorNotification)
				.compactMap({ $0.userInfo?[AVCaptureSessionErrorKey] as? AVError }) {
				if error.code == .mediaServicesWereReset {
					if !captureSession.isRunning {
						captureSession.startRunning()
					}
				}
			}
		}
	}

	func setFlashMode(_ mode: FlashMode) async {
		var flashMode: AVCaptureDevice.FlashMode {
			switch mode {
			case .on:
					.on
			case .off:
					.off
			case .auto:
					.auto
			}
		}
		photoCapture.setFlashMode(flashMode)
	}
}
