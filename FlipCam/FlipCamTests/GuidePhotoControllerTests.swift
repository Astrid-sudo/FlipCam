//
//  GuidePhotoControllerTests.swift
//  FlipCamTests
//
//  Created by Astrid Lin on 2025/3/6.
//

import UIKit
import Testing
@testable import FlipCam

@Suite("GuidePhotoController Tests")
struct GuidePhotoControllerTests {
	@Test("Guide photo can be applied and loaded")
	func testGuidePhotoApplication() async throws {
		let mockPhotoLoader = MockPhotoLoader()
		let controller = await GuidePhotoController(photoLoader: mockPhotoLoader)

		let testIdentifier = "test_photo"
		await controller.applyGuidePhoto(testIdentifier)

		await #expect(controller.guidePhotoIdentifier == testIdentifier)
		await #expect(controller.processedGuidePhoto != nil)
	}

	@Test("Guide photo opacity can be adjusted")
	func testGuidePhotoOpacity() async throws {
		let mockPhotoLoader = MockPhotoLoader()
		let controller = await GuidePhotoController(photoLoader: mockPhotoLoader)

		let testOpacity = 0.7
		await controller.setGuidePhotoOpacity(testOpacity)

		await #expect(controller.guidePhotoOpacity == testOpacity)
	}

	@Test("Guide photo effect can be changed")
	func testGuidePhotoEffect() async throws {
		let mockPhotoLoader = MockPhotoLoader()
		let controller = await GuidePhotoController(photoLoader: mockPhotoLoader)

		let testEffect = GuidePhotoEffect.outline
		await controller.setGuidePhotoEffect(testEffect)

		await #expect(controller.currentGuidePhotoEffect == testEffect)
		await #expect(controller.processedGuidePhoto != nil)
	}

	@Test("Guide photo visibility can be toggled")
	func testGuidePhotoVisibility() async throws {
		let mockPhotoLoader = MockPhotoLoader()
		let controller = await GuidePhotoController(photoLoader: mockPhotoLoader)

		let initialVisibility = await controller.shouldShowGuidePhoto
		await controller.toggleGuidePhotoVisibility()

		await #expect(controller.shouldShowGuidePhoto == !initialVisibility)
	}
}

private class MockPhotoLoader: PhotoLoader {
	func loadPhoto(withIdentifier identifier: String) async throws -> UIImage {
		return UIImage()
	}
}
