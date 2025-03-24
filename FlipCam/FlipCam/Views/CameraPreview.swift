//
//  CameraPreview.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import SwiftUI
@preconcurrency import AVFoundation

struct CameraPreview: UIViewRepresentable {

	private let source: PreviewSource
	var camera: Camera

	init(source: PreviewSource, camera: Camera) {
		self.source = source
		self.camera = camera
	}

	func makeUIView(context: Context) -> PreviewView {
		let preview = PreviewView()
		source.connect(to: preview)

		let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator,
												   action: #selector(Coordinator.handlePinch(_:)))
		preview.addGestureRecognizer(pinchGesture)

		return preview
	}

	func updateUIView(_ previewView: PreviewView, context: Context) {}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class PreviewView: UIView, PreviewTarget {

		init() {
			super.init(frame: .zero)
	#if targetEnvironment(simulator)
			// The capture APIs require running on a real device. If running
			// in Simulator, display a static image to represent the video feed.
			let imageView = UIImageView(frame: UIScreen.main.bounds)
			imageView.image = UIImage(named: "video_mode")
			imageView.contentMode = .scaleAspectFill
			imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			addSubview(imageView)
	#endif
		}

		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override class var layerClass: AnyClass {
			AVCaptureVideoPreviewLayer.self
		}

		var previewLayer: AVCaptureVideoPreviewLayer {
			layer as! AVCaptureVideoPreviewLayer
		}

		nonisolated func setSession(_ session: AVCaptureSession) {
			Task { @MainActor in
				previewLayer.session = session
			}
		}
	}
}

protocol PreviewSource: Sendable {
	func connect(to target: PreviewTarget)
}

protocol PreviewTarget {
	func setSession(_ session: AVCaptureSession)
}

struct DefaultPreviewSource: PreviewSource {

	private let session: AVCaptureSession

	init(session: AVCaptureSession) {
		self.session = session
	}

	func connect(to target: PreviewTarget) {
		target.setSession(session)
	}
}

class Coordinator: NSObject {
	var parent: CameraPreview
	private var startZoom: CGFloat = 1.0

	init(_ parent: CameraPreview) {
		self.parent = parent
	}

	@MainActor @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
		switch gesture.state {
		case .began:
			startZoom = parent.camera.zoomFactor
		case .changed:
			let newZoom = startZoom * gesture.scale
			Task {
				do {
					try await parent.camera.setZoom(factor: newZoom)
				} catch {
					logger.error("Failed to setZoom.")
				}
			}
		case .ended:
			let finalZoom = startZoom * gesture.scale
			Task {
				do {
					try await parent.camera.rampZoom(to: finalZoom)
				} catch {
					logger.error("Failed to rampZoom.")
				}
			}
		default:
			break
		}
	}
}
