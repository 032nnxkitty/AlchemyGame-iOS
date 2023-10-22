//
//  ElementsListViewController.swift
//  AlchemyUIKit
//
//  Created by Arseniy Zolotarev on 25.09.2023.
//

import UIKit

final class ElementsListViewController: UIViewController {
    // MARK: Properties
    private let elementsManager: ElementsManager
    
    private let limitCount: Int
    
    private var selectedElements: [ElementModel: Int] = [:]
    
    private var selectedElementsCount: Int {
        selectedElements.reduce(0) { result, pair in
            result + pair.value
        }
    }
    
    var dismissCompletion: (([ElementModel: Int]) -> Void)?
    
    // MARK: UI Elements
    private let doneButton = UIBarButtonItem()
    
    private var collectionView: UICollectionView!
    
    // MARK: Init
    init(manager: ElementsManager = ElementsManagerImp.shared, limit: Int) {
        elementsManager = manager
        self.limitCount = limit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Storyboards are incompatible with truth and beauty.")
    }
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configureCollectionView()
    }
}

// MARK: - Private Methods
private extension ElementsListViewController {
    func configureAppearance() {
        title = "Opened elements"
        view.backgroundColor = .systemBackground
        doneButton.target = self
        doneButton.action = #selector(doneButtonDidTap)
        doneButton.title = "Done"
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.left = 5
        layout.sectionInset.right = 5
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UnlockedElementCell.self, forCellWithReuseIdentifier: UnlockedElementCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func reload(model: ElementModel?) {
        guard let model, let indexToReload = elementsManager.getUnlockedElements().firstIndex(of: model) else { return }
        let indexPathToReload = IndexPath(row: indexToReload, section: 0)
        collectionView.reloadItems(at: [indexPathToReload])
        updateDoneButton()
    }
    
    func updateDoneButton() {
        if selectedElementsCount == 0 {
            doneButton.title = nil
            doneButton.image = .init(systemName: "xmark.circle.fill")
        } else {
            doneButton.image = nil
            doneButton.title = "Done (\(selectedElementsCount))"
        }
    }
    
    func generateErrorFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func presentAlert() {
        
    }
}

// MARK - Actions
@objc private extension ElementsListViewController {
    func doneButtonDidTap() {
        self.dismissCompletion?(selectedElements)
        self.dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ElementsListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elementsManager.getUnlockedElements().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UnlockedElementCell.identifier, for: indexPath) as! UnlockedElementCell
        let model = elementsManager.getUnlockedElements()[indexPath.row]
        let selectionCount = selectedElements[model] ?? 0
        cell.configure(model: model, selectionCount: selectionCount)
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ElementsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ElementsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsInRow = 5
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let leftInset = flowLayout.sectionInset.left
        let rightInset = flowLayout.sectionInset.right
        let interitemSpacing = flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsInRow - 1)
        
        let totalSpace = leftInset + rightInset + interitemSpacing
        
        let width = (collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsInRow)
        let height = width * 1.5
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - UnlockedElementCellDelegate
extension ElementsListViewController: UnlockedElementCellDelegate {
    func increaseCount(for model: ElementModel?) {
        guard selectedElementsCount < limitCount else {
            presentAlert()
            generateErrorFeedback()
            return
        }
        guard let model else { return }
        selectedElements[model, default: 0] += 1
        reload(model: model)
    }
    
    func decreaseCount(for model: ElementModel?) {
        guard let model else { return }
        if selectedElements[model] == nil || selectedElements[model] == 0 {
            generateErrorFeedback()
            return
        }
        selectedElements[model]! -= 1
        reload(model: model)
    }
}
