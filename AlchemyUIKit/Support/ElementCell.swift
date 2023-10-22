//
//  ElementCell.swift
//  AlchemyUIKit
//
//  Created by Arseniy Zolotarev on 25.09.2023.
//

import UIKit

protocol UnlockedElementCellDelegate {
    func increaseCount(for model: ElementModel?)
    
    func decreaseCount(for model: ElementModel?)
}

final class UnlockedElementCell: UICollectionViewCell {
    // MARK - Properties
    static let identifier = "unlocked.cell.identifier"
    
    private var model: ElementModel?
    
    var delegate: UnlockedElementCellDelegate?
    
    // MARK: - UI Elements
    private let elementImageView = UIImageView()
    
    private let elementNameLabel = UILabel()
    
    private let selectionCountLabel = UILabel()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Storyboards are incompatible with truth and beauty.")
    }
    
    // MARK: Public Methods
    func configure(model: ElementModel, selectionCount: Int) {
        self.model = model
        elementImageView.image = UIImage(named: model.imageName)
        elementNameLabel.text = model.elementName
        
        selectionCountLabel.text  = "\(selectionCount)"
    }
    
    // MARK: Private Methods
    private func configureAppearance() {
        elementImageView.contentMode = .scaleAspectFit
        elementNameLabel.font = .preferredFont(forTextStyle: .footnote)
        
        let stepper = getStepper()
        
        let containerStack = UIStackView()
        containerStack.axis = .vertical
        containerStack.distribution = .fill
        containerStack.alignment = .center
        containerStack.frame = self.bounds
        addSubview(containerStack)
        
        [elementImageView, elementNameLabel, stepper].forEach {
            containerStack.addArrangedSubview($0)
        }
    }
    
    func getStepper() -> UIView {
        let cornerRadius: CGFloat = 4
        
        let decreaseButton = UIButton()
        decreaseButton.setTitle("-", for: .normal)
        decreaseButton.setTitleColor(.black, for: .normal)
        decreaseButton.backgroundColor = .systemGray5
        decreaseButton.addTarget(self, action: #selector(decrease), for: .touchUpInside)
        decreaseButton.layer.cornerRadius = cornerRadius
        
        selectionCountLabel.textAlignment = .center
        selectionCountLabel.font = .preferredFont(forTextStyle: .footnote)
        
        let increaseButton = UIButton()
        increaseButton.setTitle("+", for: .normal)
        increaseButton.setTitleColor(.black, for: .normal)
        increaseButton.backgroundColor = .systemGray5
        increaseButton.addTarget(self, action: #selector(increase), for: .touchUpInside)
        increaseButton.layer.cornerRadius = cornerRadius

        let stepperStack = UIStackView()
        stepperStack.axis = .horizontal
        stepperStack.distribution = .fillEqually
        stepperStack.alignment = .center
        stepperStack.backgroundColor = .systemGray6
        stepperStack.layer.cornerRadius = cornerRadius
        
        [decreaseButton, selectionCountLabel, increaseButton].forEach {
            stepperStack.addArrangedSubview($0)
        }
        
        return stepperStack
    }
    
    @objc private func increase() {
        delegate?.increaseCount(for: self.model)
    }
    
    @objc private func decrease() {
        delegate?.decreaseCount(for: self.model)
    }
}
