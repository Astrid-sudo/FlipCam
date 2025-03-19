//
//  PhotoCapture.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import AVFoundation
import CoreImage

enum PhotoCaptureError: Error {
	case noPhotoData
}

final class PhotoCapture: OutputService {

	@Published private(set) var captureActivity: CaptureActivity = .idle

	private var flashMode: AVCaptureDevice.FlashMode = .off

	let output = AVCapturePhotoOutput()

	private var photoOutput: AVCapturePhotoOutput { output }

	// MARK: - Capture a photo.

	/// The app calls this method when the user taps the photo capture button.
	func capturePhoto() async throws -> Photo {
		// Wrap the delegate-based capture API in a continuation to use it in an async context.
		try await withCheckedThrowingContinuation { continuation in

			// Create a settings object to configure the photo capture.
			let photoSettings = createPhotoSettings()

			let delegate = PhotoCaptureDelegate(continuation: continuation)
			monitorProgress(of: delegate)

			// Capture a new photo with the specified settings.
			photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
		}
	}

	// MARK: - Create a photo settings object.

	private func createPhotoSettings() -> AVCapturePhotoSettings {
		var photoSettings = AVCapturePhotoSettings()
		if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
			photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
		}

		if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
			photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
		}

		photoSettings.maxPhotoDimensions = photoOutput.maxPhotoDimensions
		photoSettings.flashMode = flashMode
		return photoSettings
	}

	private func monitorProgress(of delegate: PhotoCaptureDelegate) {
		Task {
			for await activity in delegate.activityStream {
				captureActivity = activity
			}
		}
	}

	// MARK: - Update the photo output configuration

	func updateConfiguration(for device: AVCaptureDevice) {
		// Enable all supported features.
		photoOutput.maxPhotoDimensions = device.activeFormat.supportedMaxPhotoDimensions.last ?? .zero
		photoOutput.maxPhotoQualityPrioritization = .quality
		photoOutput.isResponsiveCaptureEnabled = photoOutput.isResponsiveCaptureSupported
		photoOutput.isFastCapturePrioritizationEnabled = photoOutput.isFastCapturePrioritizationSupported
		photoOutput.isAutoDeferredPhotoDeliveryEnabled = photoOutput.isAutoDeferredPhotoDeliverySupported
	}

	func setFlashMode(_ mode: AVCaptureDevice.FlashMode) {
		flashMode = mode
	}
}

typealias PhotoContinuation = CheckedContinuation<Photo, Error>

// MARK: - A photo capture delegate to process the captured photo.

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {

	private let photoContinuation: PhotoContinuation
	private var isProxyPhoto = false
	private var photoData: Data?

	let activityStream: AsyncStream<CaptureActivity>
	private let activityContinuation: AsyncStream<CaptureActivity>.Continuation

	init(continuation: PhotoContinuation) {
		self.photoContinuation = continuation

		let (activityStream, activityContinuation) = AsyncStream.makeStream(of: CaptureActivity.self)
		self.activityStream = activityStream
		self.activityContinuation = activityContinuation
	}

	func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
		activityContinuation.yield(.photoCapture())
	}

	func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
		activityContinuation.yield(.photoCapture(willCapture: true))
	}

	func photoOutput(_ output: AVCapturePhotoOutput, didFinishCapturingDeferredPhotoProxy deferredPhotoProxy: AVCaptureDeferredPhotoProxy?, error: Error?) {
		if let error = error {
			logger.debug("Error capturing deferred photo: \(error)")
			return
		}
		photoData = deferredPhotoProxy?.fileDataRepresentation()
		isProxyPhoto = true
	}

	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		if let error = error {
			logger.debug("Error capturing photo: \(String(describing: error))")
			return
		}
		photoData = photo.fileDataRepresentation()
	}

	func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {

		defer {
			activityContinuation.finish()
		}

		if let error {
			photoContinuation.resume(throwing: error)
			return
		}
		
		guard let photoData else {
			photoContinuation.resume(throwing: PhotoCaptureError.noPhotoData)
			return
		}

		let photo = Photo(data: photoData, isProxy: isProxyPhoto)
		photoContinuation.resume(returning: photo)
	}
}
