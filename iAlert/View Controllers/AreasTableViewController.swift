//
//  AreasTableViewController.swift
//  iAlert
//
//  Created by Assaf Tayouri on 11/05/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import UIKit

class AreasTableViewController: UITableViewController {
    
    let areaReuseIdentifier = "areaCell"
    var searchAreas:[Area]!
    var allAreas:[Area]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchAreas = allAreas
        
    }
    
    
    override func loadView() {
        super.loadView()
        initNavigationBar()
        tableView.register(AreaTableViewCell.self, forCellReuseIdentifier: areaReuseIdentifier)
        tableView.allowsSelection = false
    }
    
    func initNavigationBar()
    {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationController?.navigationBar.barTintColor = UIColor.PRIMARY_COLOR
        navigationController?.navigationBar.barStyle = .blackOpaque
        
        navigationItem.title = "Areas".localized
        
        let searchVC = UISearchController(searchResultsController: nil)
        searchVC.searchResultsUpdater = self
        
        if Settings.shared.direction == .RTL
        {
            searchVC.searchBar.semanticContentAttribute = .forceRightToLeft
        }
        else if Settings.shared.direction == .LTR
        {
            searchVC.searchBar.semanticContentAttribute = .forceLeftToRight
        }
        
        searchVC.searchBar.placeholder = "search".localized
        searchVC.obscuresBackgroundDuringPresentation = false
        
        let cancelButtonAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        searchVC.searchBar.setValue("Cancel".localized, forKey:"_cancelButtonText")
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        
        
        searchVC.searchBar.tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [type(of: searchVC.searchBar)]).tintColor = .white
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchVC
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(close))
    }
    
    @objc func close()
    {
        dismiss(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchAreas.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: areaReuseIdentifier, for: indexPath) as! AreaTableViewCell
        let area = searchAreas[indexPath.row]
        cell.areaCodeLabel.text = "\(area.areaCode)"
        cell.cityNameLabel.text = "\(area)"
        cell.area = area
        cell.delegate = self
        cell.checkbox.setOn(area.isPreffered,execCallback: false)
        cell.checkbox.checkboxValueChangedBlock = cell.valueChanged
        
        return cell
    }
}

extension AreasTableViewController:AreasDelegate
{
    func checkMaximumCurrentSafePlaces() -> Bool {
        var count = 0
        self.allAreas.forEach{ area in
            if count >= 10
            {
                return
            }
            count += area.isPreffered == true ? 1 : 0
        }
        if count >= 10
        {
            showAlert(title: "Areas".localized, message: "maximum cities".localized,completion: nil)
            return true;
        }
        
        return false
    }
    
    func showAlert(title:String?,message:String?,completion:(()->Void)?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default,handler:{_ in
            completion?()
        }))
        present(alert, animated: true, completion: completion)
    }
    
    
}

extension AreasTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,searchText.isEmpty == false
        {
            let lowCase = searchText.lowercased()
            searchAreas = allAreas.filter{
                return "\($0.areaCode)".contains(lowCase) || $0.containsInCity(keyWord: lowCase)
            }
        }
        else
        {
            searchAreas = allAreas
            
        }
        tableView.reloadData()
    }
}
