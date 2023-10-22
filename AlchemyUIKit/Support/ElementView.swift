//
//  AlchemyElementView.swift
//  AlchemyUIKit
//
//  Created by Arseniy Zolotarev on 10.09.2023.
//

import UIKit

final class ElementView: UIStackView {
    let model: ElementModel
    
    // MARK: - UI Elements
    private let elementImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let elementNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    // MARK: - Init
    init(frame: CGRect, model: ElementModel) {
        self.model = model
        super.init(frame: frame)
        
        elementImageView.image = UIImage(named: model.imageName)
        elementNameLabel.text = model.elementName
        
        axis = .vertical
        distribution = .fill
        alignment = .center
        addArrangedSubview(elementImageView)
        addArrangedSubview(elementNameLabel)
    }
    
    required init(coder: NSCoder) {
        fatalError("Storyboards are incompatible with truth and beauty.")
    }
}
