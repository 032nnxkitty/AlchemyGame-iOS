//
//  PlayingAreaViewController.swift
//  AlchemyUIKit
//
//  Created by Arseniy Zolotarev on 10.09.2023.
//

import UIKit

final class PlayingAreaViewController: UIViewController {
    // MARK: Properties
    private let elementsManager: ElementsManager
    
    private let playingAreaView = UIView()
    
    private var elementsViewArray: [ElementView] {
        self.playingAreaView.subviews.compactMap { $0 as? ElementView }
    }
    
    private var playingAreaSize: CGSize {
        return playingAreaView.frame.size
    }
    
    private var maxElementsCount: Int {
        return Int(playingAreaSize.width / UIConstants.elementWidth) * Int(playingAreaSize.height / UIConstants.elementHeight)
    }
    
    var isDeletingMode: Bool = false
    
    // MARK: Init
    init(manager: ElementsManager = ElementsManagerImp.shared) {
        elementsManager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Storyboards are incompatible with truth and beauty.")
    }
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configurePlayingAreaView()
        configureToolbar()
    }
}

// MARK: - Private Methods
private extension PlayingAreaViewController {
    func configureAppearance() {
        title = "Alchemy"
        view.backgroundColor = .systemBackground
    }
    
    func configurePlayingAreaView() {
        playingAreaView.translatesAutoresizingMaskIntoConstraints = false
        playingAreaView.backgroundColor = .systemGray6
        playingAreaView.layer.cornerRadius = 16
        
        view.addSubview(playingAreaView)
        NSLayoutConstraint.activate([
            playingAreaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playingAreaView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            playingAreaView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            playingAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(stopDeletingMode))
        playingAreaView.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(createBaseElements))
        doubleTap.numberOfTapsRequired = 2
        playingAreaView.addGestureRecognizer(doubleTap)
    }
    
    func configureToolbar() {
        toolbarItems = [
            .init(image: .init(systemName: "plus"), style: .plain, target: self, action: #selector(showElementsList)),
            .init(image: .init(systemName: "square.grid.3x3"), style: .plain, target: self, action: #selector(alignAllElements)),
            .init(systemItem: .flexibleSpace),
            .init(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteAllElements)),
        ]
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func createElementView(center: CGPoint, model: ElementModel) -> ElementView {
        let elementFrame = CGRect(
            x: center.x - UIConstants.elementWidth / 2,
            y: center.y - UIConstants.elementHeight / 2,
            width: UIConstants.elementWidth,
            height: UIConstants.elementHeight
        )
        
        let elementView = ElementView(frame: elementFrame, model: model)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(moveView))
        elementView.addGestureRecognizer(panGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(copyElement))
        doubleTapGesture.numberOfTapsRequired = 2
        elementView.addGestureRecognizer(doubleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(startDeletingMode))
        elementView.addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnElement))
        elementView.addGestureRecognizer(tapGesture)
        
        return elementView
    }
    
    func findIntersection(for selectedElementView: ElementView) {
        guard !isDeletingMode else { return }
        var match = true
        
        for anotherElementView in elementsViewArray where selectedElementView !== anotherElementView && selectedElementView.intersectionMoreThan50Percent(anotherElementView)  {
            
            guard let newElementModel = elementsManager.match(selectedElementView.model, anotherElementView.model) else {
                match = false
                continue
            }
            let newElementView = createElementView(center: selectedElementView.center, model: newElementModel)
            addElementViewsAnimated([newElementView])
            
            selectedElementView.removeFromSuperview()
            anotherElementView.removeFromSuperview()
            
            match = true
            
            break
        }
        
        if !match {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            selectedElementView.shake()
        }
    }
    
    func addElementViewsAnimated(_ subviews: [ElementView]) {
        subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            $0.alpha = 0
            
            self.playingAreaView.addSubview($0)
        }
        
        UIView.animate(withDuration: 0.3) {
            subviews.forEach {
                $0.transform = .identity
                $0.alpha = 1
            }
        }
    }
    
    func moveElementInsidePlayingArea(_ elementView: UIView, to point: CGPoint) {
        let halfElementWidth = UIConstants.elementWidth / 2
        let halfElementHeight = UIConstants.elementHeight / 2
        
        let minX = halfElementWidth
        let minY = halfElementHeight
        let maxX = playingAreaSize.width - halfElementWidth
        let maxY = playingAreaSize.height - halfElementHeight
        
        var newX = point.x
        var newY = point.y
        
        if newX < minX {
            newX = minX
        } else if newX > maxX {
            newX = maxX
        }
        
        if newY < minY {
            newY = minY
        } else if newY > maxY {
            newY = maxY
        }
        
        elementView.center = CGPoint(x: newX, y: newY)
    }
    
    func checkLocationForCreatingBaseElements(_ point: inout CGPoint) {
        let horizontalIndent = UIConstants.elementWidth + UIConstants.inset
        let verticalIndent = UIConstants.elementHeight + UIConstants.inset
        
        // left
        if point.x < horizontalIndent {
            point.x = horizontalIndent
        }
        
        // right
        if point.x > playingAreaSize.width - horizontalIndent {
            point.x = playingAreaSize.width - horizontalIndent
        }
        
        // top
        if point.y < verticalIndent {
            point.y = verticalIndent
        }
        
        // bottom
        if point.y > playingAreaSize.height - verticalIndent {
            point.y = playingAreaSize.height - verticalIndent
        }
    }
    
    func moveToPlayingAreaIfNeeded(elementView: UIView) {
        let halfElementWidth = UIConstants.elementWidth / 2
        let halfElementHeight = UIConstants.elementHeight / 2
        
        let minX = halfElementWidth
        let minY = halfElementHeight
        let maxX = playingAreaSize.width - halfElementWidth
        let maxY = playingAreaSize.height - halfElementHeight
        
        var newX = elementView.center.x
        var newY = elementView.center.y
        
        if newX < minX {
            newX = minX
        } else if newX > maxX {
            newX = maxX
        }
        
        if newY < minY {
            newY = minY
        } else if newY > maxY {
            newY = maxY
        }
        
        UIView.animate(withDuration: 0.2) {
            elementView.center = CGPoint(x: newX, y: newY)
        }
    }
    
    func presentAlert(_ text: String) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
    
    func addSelectedElementsToPlayingArea(_ elements: [ElementModel: Int]) {
        let elementViews: [ElementView] = elements.flatMap { model, count in
            (0..<count).map { _ in
                let halfWidth = Int(UIConstants.elementWidth / 2)
                let halfHeight = Int(UIConstants.elementHeight / 2)
                let x = CGFloat(Int.random(in: halfWidth..<(Int(self.playingAreaSize.width) - halfWidth)))
                let y = CGFloat(Int.random(in: halfHeight..<(Int(self.playingAreaSize.height) - halfHeight)))
                return self.createElementView(center: CGPoint(x: x, y: y), model: model)
            }
        }
        addElementViewsAnimated(elementViews)
    }
}


// MARK: - Actions
@objc private extension PlayingAreaViewController {
    func createBaseElements(_ gesture: UITapGestureRecognizer) {
        guard !isDeletingMode else { return }
        
        guard elementsViewArray.count <= maxElementsCount - 4 else {
            presentAlert("Playing area filled")
            return
        }
        
        var tapLocationPoint = gesture.location(in: playingAreaView)
        checkLocationForCreatingBaseElements(&tapLocationPoint)
        
        let tapX = tapLocationPoint.x
        let tapY = tapLocationPoint.y
        let horizontalOffset = UIConstants.elementWidth / 2 + UIConstants.inset
        let verticalOffset = UIConstants.elementHeight / 2 + UIConstants.inset
        
        let (waterModel, earthModel, airModel, fireModel) = elementsManager.getFourBaseElements()
        
        let waterCenter = CGPoint(x: tapX - horizontalOffset, y: tapY - verticalOffset)
        let waterView = createElementView(center: waterCenter, model: waterModel)
        
        let earthCenter = CGPoint(x: tapX + horizontalOffset, y: tapY - verticalOffset)
        let earthView = createElementView(center: earthCenter, model: earthModel)
        
        let airCenter = CGPoint(x: tapX + horizontalOffset,y: tapY + verticalOffset)
        let airView = createElementView(center: airCenter, model: airModel)
        
        let fireCenter = CGPoint(x: tapX - horizontalOffset,y: tapY + verticalOffset)
        let fireView = createElementView(center: fireCenter, model: fireModel)
        
        addElementViewsAnimated([waterView, earthView, airView, fireView])
    }
    
    func moveView(_ gesture: UIPanGestureRecognizer) {
        guard let movedView = gesture.view, let elementView = movedView as? ElementView else { return }
        
        switch gesture.state {
        case .began:
            playingAreaView.bringSubviewToFront(elementView)
            fallthrough
        case .changed:
            let translation = gesture.translation(in: playingAreaView)
            let changeX = (gesture.view?.center.x ?? 0) + translation.x
            let changeY = (gesture.view?.center.y ?? 0) + translation.y
            
            let gestureChangePoint = CGPoint(x: changeX, y: changeY)
            gesture.setTranslation(.zero, in: gesture.view)
            moveElementInsidePlayingArea(elementView, to: gestureChangePoint)
        case .ended:
            findIntersection(for: elementView)
        default:
            return
        }
    }
    
    func copyElement(_ gesture: UITapGestureRecognizer) {
        guard !isDeletingMode else {
            return
        }
        
        guard elementsViewArray.count < maxElementsCount else {
            presentAlert("Playing area filled")
            return
        }
        
        guard let gestureView = gesture.view, let elementView = gestureView as? ElementView else {
            return
        }
        
        let horizontalOffset = UIConstants.elementWidth / (Bool.random() ? 4 : -4)
        let verticalOffset = UIConstants.elementHeight / 2 + UIConstants.inset
        let copiedViewCenter = elementView.center
        
        let center1 = CGPoint(
            x: copiedViewCenter.x + horizontalOffset,
            y: copiedViewCenter.y - verticalOffset
        )
        let newElement1 = createElementView(center: center1, model: elementView.model)
        
        let center2 = CGPoint(
            x: copiedViewCenter.x - horizontalOffset,
            y: copiedViewCenter.y + verticalOffset
        )
        let newElement2 = createElementView(center: center2, model: elementView.model)
        
        elementView.removeFromSuperview()
        
        addElementViewsAnimated([newElement1, newElement2])
        
        moveToPlayingAreaIfNeeded(elementView: newElement2)
        moveToPlayingAreaIfNeeded(elementView: newElement1)
    }
    
    func alignAllElements() {
        isDeletingMode ? stopDeletingMode() : nil
        
        let numberOfElementsInRow = Int(playingAreaSize.width / UIConstants.elementWidth)
        let numberOfElementsInColumn = Int(playingAreaSize.height / UIConstants.elementHeight)
        
        let horizontalInset = (playingAreaSize.width - CGFloat(numberOfElementsInRow) * UIConstants.elementWidth) / CGFloat(numberOfElementsInRow - 1)
        let verticalInset = (playingAreaSize.height - CGFloat(numberOfElementsInColumn) * UIConstants.elementHeight) / CGFloat(numberOfElementsInColumn - 1)
        
        var column: CGFloat = 0
        var row: CGFloat = 0
        
        for (i, element) in elementsViewArray.enumerated() {
            if i != 0 && i % numberOfElementsInRow == 0 {
                column = 0
                row += 1
            }
            let xOffset = Int(horizontalInset * column)
            let yOffset = Int(verticalInset * row)
            
            let x = Int(UIConstants.elementWidth / 2) + Int(UIConstants.elementWidth * column) + xOffset
            let y = Int(UIConstants.elementHeight / 2) + Int(UIConstants.elementHeight * row) + yOffset
            
            UIView.animate(withDuration: 0.3) {
                element.center = CGPoint(
                    x: x,
                    y: y
                )
            }
            column += 1
        }
    }
    
    func startDeletingMode() {
        guard !isDeletingMode else { return }
        isDeletingMode = true
        // show label

        elementsViewArray.forEach {
            $0.wiggle()
        }
    }
    
    func stopDeletingMode() {
        guard isDeletingMode else { return }
        isDeletingMode = false
        // hide label
        
        elementsViewArray.forEach {
            $0.stopAnimation()
        }
    }
    
    func tapOnElement(_ gesture: UITapGestureRecognizer) {
        if isDeletingMode {
            guard let tappedView = gesture.view, let elementView = tappedView as? ElementView else { return }
            
            UIView.animate(withDuration: 0.3) {
                elementView.alpha = 0
                elementView.transform = .init(scaleX: 1.3, y: 1.3)
            } completion: { _ in
                elementView.removeFromSuperview()
            }
        } else {
//            show info
        }
    }
    
    func deleteAllElements() {
        UIView.animate(withDuration: 0.2) {
            self.elementsViewArray.forEach {
                $0.center = CGPoint(
                    x: self.playingAreaSize.width - UIConstants.elementWidth / 2,
                    y: self.playingAreaSize.height - UIConstants.elementHeight / 2
                )
                $0.alpha = 0
            }
        } completion: { a in
            self.elementsViewArray.forEach { $0.removeFromSuperview() }
        }
    }
    
    func showElementsList() {
        let elementsLimit = maxElementsCount - elementsViewArray.count
        let vc = ElementsListViewController(limit: elementsLimit)
        vc.dismissCompletion = { [weak self] selectedElements in
            guard let self else { return }
            self.addSelectedElementsToPlayingArea(selectedElements)
        }
        let navi = UINavigationController(rootViewController: vc)
        present(navi, animated: true)
    }
}
