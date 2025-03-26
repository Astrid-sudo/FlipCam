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
	case cameraUnauthorized
	case previewLayerNotFound
	case noActiveInput
	case mediaLibraryUnauthorized
	case loadGuidePhotoFailed

	var errorDescription: String? {
		switch self {
		case .videoDeviceUnavailable:
			return ErrorMessages.noVideoDevice
		case .addInputFailed:
			return ErrorMessages.cameraInputFailed
		case .addOutputFailed:
			return ErrorMessages.outputFailed
		case .setupFailed:
			return ErrorMessages.sessionSetupFailed
		case .deviceChangeFailed:
			return ErrorMessages.deviceChangeFailed
		case .cameraUnauthorized:
			return ErrorMessages.cameraAccessDenied
		case .previewLayerNotFound:
			return ErrorMessages.previewLayerNotFound
		case .noActiveInput:
			return ErrorMessages.noActiveCameraInput
		case .mediaLibraryUnauthorized:
			return ErrorMessages.photosAccessDenied
		case .loadGuidePhotoFailed:
			return ErrorMessages.guidePhotoLoadFailed
		}
	}

	var isFatalError: Bool {
		switch self {
		case .setupFailed, .cameraUnauthorized, .previewLayerNotFound:
			return true
		default:
			return false
		}
	}
}
