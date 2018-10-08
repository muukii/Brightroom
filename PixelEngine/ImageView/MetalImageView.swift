//
//  MetalImageView.swift
//  PixelEngine
//
//  Created by muukii on 10/9/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation

#if canImport(MetalKit) && !targetEnvironment(simulator)
import MetalKit

open class MetalImageView : MTKView, HardwareImageViewType {

  public var image: CIImage? {
    didSet {
      renderImage()
    }
  }

  private let colorSpace = CGColorSpaceCreateDeviceRGB()

  private lazy var commandQueue: MTLCommandQueue = { [unowned self] in
    return self.device!.makeCommandQueue()!
    }()

  private lazy var ciContext: CIContext = {
    [unowned self] in
    return CIContext(mtlDevice: self.device!)
    }()

  public override init(
    frame frameRect: CGRect,
    device: MTLDevice?
    ) {
    super.init(
      frame: frameRect,
      device: device ??
        MTLCreateSystemDefaultDevice()
    )
    if super.device == nil {
      fatalError("Device doesn't support Metal")
    }
    framebufferOnly = false
  }

  public required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func renderImage() {
    guard
      let image = image,
      let targetTexture = currentDrawable?.texture else
    {
      return
    }

    let commandBuffer = commandQueue.makeCommandBuffer()

    let bounds = CGRect(
      origin: .zero,
      size: drawableSize
    )
    let originX = image.extent.origin.x
    let originY = image.extent.origin.y
    let scaleX = drawableSize.width / image.extent.width
    let scaleY = drawableSize.height / image.extent.height
    let scale = min(scaleX, scaleY)
    let scaledImage = image
      .transformed(by: CGAffineTransform(translationX: -originX, y: -originY))
      .transformed(by: CGAffineTransform(scaleX: scale, y: scale))

    ciContext.render(
      scaledImage,
      to: targetTexture,
      commandBuffer: commandBuffer,
      bounds: bounds,
      colorSpace: colorSpace
    )

    commandBuffer?.present(currentDrawable!)
    commandBuffer?.commit()
  }
}

#endif
