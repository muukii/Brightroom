//
//  ColorHighlightsControl.swift
//  PixelEngine
//
//  Created by Danny on 19.11.18.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation

import PixelEngine

open class ColorHighlightsControlBase : FilterControlBase {
  
  public required init(context: PixelEditContext) {
    super.init(context: context)
  }
}

open class ColorHighlightsControl : ColorHighlightsControlBase {
  
  open override var title: String {
    return L10n.editBrightness
  }
  
  public let slider = StepSlider(frame: .zero)
  
  open override func setup() {
    super.setup()
    
    backgroundColor = Style.default.control.backgroundColor
    
    let containerGuide = UILayoutGuide()
    
    addLayoutGuide(containerGuide)
    addSubview(slider)
    
    slider.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      
      containerGuide.topAnchor.constraint(equalTo: slider.superview!.topAnchor),
      containerGuide.rightAnchor.constraint(equalTo: slider.superview!.rightAnchor, constant: -44),
      containerGuide.leftAnchor.constraint(equalTo: slider.superview!.leftAnchor, constant: 44),
      
      slider.topAnchor.constraint(greaterThanOrEqualTo: containerGuide.topAnchor),
      slider.rightAnchor.constraint(equalTo: containerGuide.rightAnchor),
      slider.leftAnchor.constraint(equalTo: containerGuide.leftAnchor),
      slider.bottomAnchor.constraint(lessThanOrEqualTo: containerGuide.bottomAnchor),
      slider.centerYAnchor.constraint(equalTo: containerGuide.centerYAnchor),
      ])
    
    slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
  }
  
  open override func didReceiveCurrentEdit(_ edit: EditingStack.Edit) {
    
    slider.set(value: edit.filters.highlights?.value ?? 0, in: FilterHighlights.range)
    
  }
  
  @objc
  private func valueChanged() {
    
    let value = slider.transition(in: FilterHighlights.range)
    guard value != 0 else {
      context.action(.setFilter({ $0.highlights = nil }))
      return
    }
    var f = FilterHighlights()
    f.value = value
    context.action(.setFilter({ $0.highlights = f }))
  }
}
