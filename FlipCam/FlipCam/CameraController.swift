import SwiftUI

@Observable
final class CameraController: Camera {
    private let captureService = CaptureService()
    private let mediaLibrary = MediaLibrary()
    
    // MARK: - Public Properties
    var cameraStatus: AsyncStream<CameraStatus> {
        AsyncStream { continuation in
            let task = Task {
                for await status in captureService.cameraStatus {
                    continuation.yield(status)
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    var captureActivity: AsyncStream<CaptureActivity> {
        AsyncStream { continuation in
            let task = Task {
                for await activity in captureService.captureActivity {
                    continuation.yield(activity)
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    var isSwitchingCameraDevices: AsyncStream<Bool> {
        AsyncStream { continuation in
            let task = Task {
                for await isSwitching in captureService.isSwitchingCameraDevices {
                    continuation.yield(isSwitching)
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    var shouldFlashScreen: AsyncStream<Bool> {
        AsyncStream { continuation in
            let task = Task {
                for await shouldFlash in captureService.shouldFlashScreen {
                    continuation.yield(shouldFlash)
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    var thumbnail: AsyncStream<CGImage?> {
        AsyncStream { continuation in
            let task = Task {
                for await thumbnail in mediaLibrary.thumbnails {
                    continuation.yield(thumbnail)
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    var zoomFactor: AsyncStream<CGFloat> {
        AsyncStream { continuation in
            let task = Task {
                for await factor in captureService.zoomFactor {
                    continuation.yield(factor)
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    var maxZoomFactor: AsyncStream<CGFloat> {
        AsyncStream { continuation in
            let task = Task {
                for await factor in captureService.maxZoomFactor {
                    continuation.yield(factor)
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    var flashMode: AsyncStream<FlashMode> {
        AsyncStream { continuation in
            let task = Task {
                for await mode in captureService.flashMode {
                    continuation.yield(mode)
                }
                continuation.finish()
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    var previewSource: PreviewSource { captureService.previewSource }

    init() {
        observeThumbnails()
    }
    
    func start() async throws {
        guard await captureService.isAuthorized else {
            throw CameraError.cameraUnauthorized
        }
        do {
            try await captureService.start()
            cameraStatus = .running
        } catch {
            logger.error("Failed to start capture service. \(error)")
            throw error
        }
    }
    
    func switchCameraDevices() async throws {
        try await captureService.selectNextCameraDevice()
    }
    
    func capturePhoto() async throws {
        let photo = try await captureService.capturePhoto()
        try await mediaLibrary.save(photo: photo)
    }
    
    func focusAndExpose(at point: CGPoint) async throws {
        try await captureService.focusAndExpose(at: point)
    }
    
    func setZoom(factor: CGFloat) async throws {
        try await captureService.setZoom(factor: factor)
    }
    
    func rampZoom(to factor: CGFloat) async throws {
        try await captureService.rampZoom(to: factor)
    }
    
    func setFlashMode(_ mode: FlashMode) async {
        await captureService.setFlashMode(mode)
    }
    
    private func observeThumbnails() {
        Task {
            for await thumbnail in mediaLibrary.thumbnails.compactMap({ $0 }) {
                self.thumbnail = thumbnail
            }
        }
    }
}

extension CameraController: PhotoLoader {
    func loadPhoto(withIdentifier identifier: String) async throws -> Image {
        guard let photo = try await mediaLibrary.loadPhoto(withIdentifier: identifier) else {
            throw CameraError.loadGuidePhotoFailed
        }
        return Image(photo)
    }
}

enum FlashMode {
	case on
	case off
	case auto
}
