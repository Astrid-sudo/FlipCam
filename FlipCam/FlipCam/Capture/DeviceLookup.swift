//
//  DeviceLookup.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import AVFoundation

final class DeviceLookup {

	private let frontCameraDiscoverySession: AVCaptureDevice.DiscoverySession
	private let backCameraDiscoverySession: AVCaptureDevice.DiscoverySession
	private let externalCameraDiscoverSession: AVCaptureDevice.DiscoverySession

	init() {
		backCameraDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
																	  mediaType: .video,
																	  position: .back)
		frontCameraDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],
																	   mediaType: .video,
																	   position: .front)
		externalCameraDiscoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.external],
																		 mediaType: .video,
																		 position: .unspecified)

		if AVCaptureDevice.systemPreferredCamera == nil {
			AVCaptureDevice.userPreferredCamera = backCameraDiscoverySession.devices.first
		}
	}

	var defaultCamera: AVCaptureDevice {
		get throws {
			guard let videoDevice = AVCaptureDevice.systemPreferredCamera else {
				throw CameraError.videoDeviceUnavailable
			}
			return videoDevice
		}
	}

	var cameras: [AVCaptureDevice] {
		var cameras: [AVCaptureDevice] = []
		if let backCamera = backCameraDiscoverySession.devices.first {
			cameras.append(backCamera)
		}
		if let frontCamera = frontCameraDiscoverySession.devices.first {
			cameras.append(frontCamera)
		}
		// iPadOS supports connecting external cameras.
		if let externalCamera = externalCameraDiscoverSession.devices.first {
			cameras.append(externalCamera)
		}

		if cameras.isEmpty {
			assertionFailure("No camera devices are found on this system.")
		}
		return cameras
	}
}
