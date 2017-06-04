//
//  ColorPickerPreviewView.swift
//  ios_course_hw_4
//
//  Created by Danil Mironov on 30.04.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

protocol ColorPickerPreviewViewProtocol {
    func gradientInitPressed(atIndex index: Int)
    func setupInitGradiendColor(withColor color: UIColor)
}

@IBDesignable class ColorPickerPreviewView: CommonView {
    @IBInspectable var itemsCount: Int = 4 {
        didSet {
            setupItems()
        }
    }
    var colors: [UIColor] = [.white, .red, .green] {
        didSet {
            setupItems()
        }
    }
    var gradientColor: UIColor? {
        didSet {
            currentCheckedIndex = itemsCount - 1
            setupItems()
        }
    }

    private var currentCheckedIndex = 0
    private var _currentColor: UIColor = UIColor.white
    var currentColor: UIColor {
        get {
            if let gradientColor = gradientColor {
                return gradientColor
            } else {
                return colors[currentCheckedIndex]
            }
        }
        set {
            for colorNum in 0..<colors.count {
                if colors[colorNum].toHexString() == newValue.toHexString() {
                    currentCheckedIndex = colorNum
                    _currentColor = colors[colorNum]
                    setupItems()
                    return
                }
            }
            delegate?.setupInitGradiendColor(withColor: newValue)
            gradientColor = newValue
        }
    }
    
    var delegate: ColorPickerPreviewViewProtocol?
    
    private var itemsStack = UIStackView()
    private var colorPreviewItems = [ColorPreviewItemView]()
    private var tapRecognizers = [UITapGestureRecognizer]()
    
    override func commonInit() {
        super.commonInit()
        clipsToBounds = true
        
        setupItems()
        setupStack()
    }
    
    func setupStack() {
        itemsStack.spacing = CGFloat(10)
        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(itemsStack)
        NSLayoutConstraint(item: itemsStack, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: itemsStack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 10).isActive = true
    }
    
    func setupItems() {
        for colorPreviewItem in colorPreviewItems {
            itemsStack.removeArrangedSubview(colorPreviewItem)
            colorPreviewItem.removeFromSuperview()
        }
        colorPreviewItems.removeAll()
        tapRecognizers.removeAll()
        
        for index in 0..<itemsCount - 1 {
            createSquare(withColor: colors[index % colors.count])
        }
        
        if let settedGradientColor = gradientColor {
            createSquare(withColor: settedGradientColor)
        } else {
            createSquare(withGradient: true)
        }
        
        setCheckedPreview(atIndex: currentCheckedIndex)
    }
    
    func createSquare(withColor color: UIColor = .red, withGradient gradient: Bool = false) {
        var colorPreviewItemView: ColorPreviewItemView
        if gradient {
            colorPreviewItemView = ColorPreviewItemView(withGradient: gradient)
        } else {
            colorPreviewItemView = ColorPreviewItemView(withColor: color)
        }
        
        colorPreviewItemView.translatesAutoresizingMaskIntoConstraints = false
        colorPreviewItemView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        colorPreviewItemView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(self.handleTap(_:)))
        colorPreviewItemView.addGestureRecognizer(tap)
        
        itemsStack.addArrangedSubview(colorPreviewItemView)
        
        colorPreviewItems.append(colorPreviewItemView)
        tapRecognizers.append(tap)
    }
    
    func setCheckedPreview(atIndex index: Int) {
        for current in 0..<colorPreviewItems.count {
            if current == index {
                colorPreviewItems[current].isChecked = true
            } else {
                colorPreviewItems[current].isChecked = false
            }
        }
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        guard let index = tapRecognizers.index(of: sender) else {
            fatalError("Didn't recognazied \(sender)")
        }
        
        // Gradient pressed
        if index == colorPreviewItems.count - 1 {
            delegate?.gradientInitPressed(atIndex: index)
        } else {
            if index != currentCheckedIndex {
                setCheckedPreview(atIndex: index)
            }
            currentCheckedIndex = index
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 100)
    }

}
