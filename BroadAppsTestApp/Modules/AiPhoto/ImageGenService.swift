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
    func generate(prompt: String,
                  avatar: UIImage?,
                  aspect: AiPhotoViewModel.Aspect,
                  template: PhotoStyle?
    ) async throws -> UIImage
}
