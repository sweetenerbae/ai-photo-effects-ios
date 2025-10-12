//
//  ImageGenService.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

protocol ImageGenService {
    func generate(prompt: String, avatar: UIImage?, aspect: AiPhotoViewModel.Aspect) async throws -> UIImage
}

struct StubImageGenService: ImageGenService {
    private let context = CIContext()

    func generate(prompt: String, avatar: UIImage?, aspect: AiPhotoViewModel.Aspect) async throws -> UIImage {
        let base = avatar ?? (UIImage(named: "ob_trend") ?? UIImage(systemName: "photo")!)
        let ci = CIImage(image: base) ?? CIImage(color: .gray).cropped(to: CGRect(origin: .zero, size: CGSize(width: 512, height: 640)))

        // параметризация фильтра хэшем промпта (чтобы разные промпты давали разный вид)
        let seed = abs(prompt.hashValue % 100)
        let sat = 0.8 + CGFloat(seed % 20) / 50.0
        let blur = CGFloat((seed % 6)) * 0.5

        let color = CIFilter.colorControls()
        color.inputImage = ci
        color.saturation = Float(sat)
        color.brightness = Float(0.02)
        color.contrast = 1.05

        let gaussian = CIFilter.gaussianBlur()
        gaussian.inputImage = color.outputImage
        gaussian.radius = Float(blur)

        let output = gaussian.outputImage ?? ci

        guard let cg = context.createCGImage(output.clampedToExtent(), from: ci.extent) else {
            throw NSError(domain: "StubGen", code: 1)
        }
        return UIImage(cgImage: cg)
    }
}
