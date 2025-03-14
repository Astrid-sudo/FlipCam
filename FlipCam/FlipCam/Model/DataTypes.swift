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
}

enum CameraError: Error {
	case videoDeviceUnavailable
	case audioDeviceUnavailable
	case addInputFailed
	case addOutputFailed
	case setupFailed
	case deviceChangeFailed
}
