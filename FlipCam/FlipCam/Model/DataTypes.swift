//
//  DataTypes.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import AVFoundation

enum CameraStatus {
	// The initial status upon creation.
	case unknown
	// A status that indicates a person disallows access to the camera or microphone.
	case unauthorized
	// A status that indicates the camera failed to start.
	case failed
	// A status that indicates the camera is successfully running.
	case running
	// A status that indicates higher-priority media processing is interrupting the camera.
	case interrupted
}

enum CaptureActivity {
	case idle
	case photoCapture(willCapture: Bool = false)
	var willCapture: Bool {
		if case .photoCapture(let willCapture) = self {
			return willCapture
		}
		return false
	}
}

struct Photo: Sendable {
	let data: Data
	let isProxy: Bool
}

protocol OutputService {
	associatedtype Output: AVCaptureOutput
	var output: Output { get }
	var captureActivity: CaptureActivity { get }
	func updateConfiguration(for device: AVCaptureDevice)
	func setCameraRotationAngle(_ angle: CGFloat)
}

extension OutputService {
	func setCameraRotationAngle(_ angle: CGFloat) {
		output.connection(with: .video)?.videoRotationAngle = angle
	}
}

enum CameraError: LocalizedError {
	case videoDeviceUnavailable
	case addInputFailed
	case addOutputFailed
	case setupFailed
	case deviceChangeFailed
	case unauthorized
	case previewLayerNotFound
	case noActiveInput
	case mediaLibraryUnauthorized

	var errorDescription: String? {
		switch self {
		case .videoDeviceUnavailable:
			return "No video device found for current input"
		case .addInputFailed:
			return "Failed to add camera input to capture session"
		case .addOutputFailed:
			return "Failed to add output to capture session"
		case .setupFailed:
			return "Failed to set up camera capture session"
		case .deviceChangeFailed:
			return "Failed to change camera device"
		case .unauthorized:
			return "Camera access is not authorized, please go to Settings > Apps > FlipCam to turn on Camera access permission."
		case .previewLayerNotFound:
			return "Camera preview layer not found"
		case .noActiveInput:
			return "No active camera input found"
		case .mediaLibraryUnauthorized:
			return "Photos access is not authorized, please go to Settings > Apps > FlipCam to turn on Photos access permission."
		}
	}

	var isFatalError: Bool {
		switch self {
		case .setupFailed, .unauthorized, .previewLayerNotFound:
			return true
		default:
			return false
		}
	}
}
