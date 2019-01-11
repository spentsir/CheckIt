//
//  SettingsCategoryTableViewCell.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/8/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import UIKit

protocol CategoryShowCellDelegate: class {
    func categoryShowCellSafeButtonTapped(_ sender: CategoryTableViewCell)
}

class CategoryTableViewCell: UITableViewCell {
    
    weak var delegate: CategoryShowCellDelegate?
    
    // Array of Category Colors
    private let colorsArray = [UIColor.black, .darkGray, .gray, .lightGray, .blue, .cyan, .purple, .magenta, .orange, .green]
    
    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add new category..."
        tf.borderStyle = .none
        tf.isUserInteractionEnabled = false
        tf.returnKeyType = .default
        tf.font = .boldSystemFont(ofSize: 15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let colorView: UIView = {
        let cv = UIView()
        cv.layer.cornerRadius = 10
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let editView: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()
    
    private let manageCategoryTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add Category name"
        tf.borderStyle = .roundedRect
        tf.font = .boldSystemFont(ofSize: 17)
        tf.clearButtonMode = .whileEditing
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func handleSaveButton() {
        delegate?.categoryShowCellSafeButtonTapped(self)
    }
    
    let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.alwaysBounceVertical = false
        cv.alwaysBounceHorizontal = true
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        saveButton.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
    }
    
    public func setCell(category: Category) {
        titleTextField.text = category.categoryName
        colorView.backgroundColor = category.color
    }
    
    public func editViewIsHidden(isHidden: Bool) {
        if isHidden {
            editView.isHidden = true
            titleTextField.borderStyle = .none
            titleTextField.isUserInteractionEnabled = false
        } else {
            editView.isHidden = false
            titleTextField.borderStyle = .roundedRect
            titleTextField.isUserInteractionEnabled = true
        }
    }
    
    public func getCategory() -> Category? {
        if let titleExists = titleTextField.text, titleExists.count >= 3 {
            return Category(nameOfCategory: titleTextField.text ?? "", colorOfCategory: colorView.backgroundColor ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        } else {
            return nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CategoryTableViewCell {
    fileprivate func setUpViewForCategoryLayout(_ viewForCategory: UIView) {
        
        colorView.topAnchor.constraint(equalTo: viewForCategory.topAnchor, constant: 5).isActive = true
        colorView.trailingAnchor.constraint(equalTo: viewForCategory.trailingAnchor, constant: -5).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        titleTextField.topAnchor.constraint(equalTo: viewForCategory.topAnchor, constant: 5).isActive = true
        titleTextField.leadingAnchor.constraint(equalTo: viewForCategory.leadingAnchor, constant: 20).isActive = true
        titleTextField.trailingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: -10).isActive = true
        titleTextField.bottomAnchor.constraint(equalTo: viewForCategory.bottomAnchor, constant: -5).isActive = true
    }
    
    fileprivate func setupEditViewLayout() {
        colorCollectionView.topAnchor.constraint(equalTo: editView.topAnchor, constant: 5).isActive = true
        colorCollectionView.bottomAnchor.constraint(equalTo: editView.bottomAnchor, constant: -5).isActive = true
        colorCollectionView.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -10).isActive = true
        colorCollectionView.leadingAnchor.constraint(equalTo: editView.leadingAnchor, constant: 5).isActive = true
        
        saveButton.bottomAnchor.constraint(equalTo: editView.bottomAnchor, constant: -5).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: editView.trailingAnchor, constant: -5).isActive = true
        saveButton.topAnchor.constraint(equalTo: editView.topAnchor, constant: 5).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    fileprivate func setupLayout() {
        
        let viewForCategory = UIView()
        viewForCategory.addSubview(titleTextField)
        viewForCategory.addSubview(colorView)
        setUpViewForCategoryLayout(viewForCategory)
        
        editView.addSubview(colorCollectionView)
        editView.addSubview(saveButton)
        
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellID")
        setupEditViewLayout()
        
        let stackView = UIStackView(arrangedSubviews: [viewForCategory,editView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        
    }
}

extension CategoryTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath)
        cell.backgroundColor = colorsArray[indexPath.row]
        cell.layer.cornerRadius = 12
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 25, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorView.backgroundColor = colorsArray[indexPath.item]
    }
    
}
