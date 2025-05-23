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
	var viewModel: ShotViewModelType

	init(viewModel: ShotViewModelType) {
		self.source = viewModel.output.previewSource
		self.viewModel = viewModel
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
			let imageView = UIImageView()
			imageView.image = UIImage(named: "tonku")
			imageView.contentMode = .scaleAspectFill
			imageView.translatesAutoresizingMaskIntoConstraints = false
			addSubview(imageView)
			NSLayoutConstraint.activate([
				imageView.topAnchor.constraint(equalTo: topAnchor),
				imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
				imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
				imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
			])
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
			startZoom = parent.viewModel.output.zoomFactor
		case .changed:
			let newZoom = startZoom * gesture.scale
			Task {
				await parent.viewModel.input.setZoom(to: newZoom)
			}
		case .ended:
			let finalZoom = startZoom * gesture.scale
			Task {
					await parent.viewModel.input.rampZoom(to: finalZoom)
			}
		default:
			break
		}
	}
}
