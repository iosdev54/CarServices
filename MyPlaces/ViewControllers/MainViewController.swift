//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 21.11.2022.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    //MARK: - Private constants
    private let titileNavBar = "Auto Services"
    private let cellNibName = "CarServiceTableViewCell"
    private let segueIdentifierShowDetail = "showDetail"
    private let segueIdentifierNewService = "NewService"
    private let cell = "Cell"
    private let dateKeyPath = "date"
    private let nameKeyPath = "name"
    private let ratingKeyPath = "rating"
    private let sortByName = "name CONTAINS[cd] %@"
    private let sortByLocation = "location CONTAINS[cd] %@"
    private let sortByType = "type CONTAINS[cd] %@"
    private let scopeButtonTitles = ["Name", "Location", "Type"]
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var services: Results<Service>!
    private var filteredServices: Results<Service>!
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        services = realm.objects(Service.self)
        
        tableView.register(UINib(nibName: cellNibName, bundle: nil), forCellReuseIdentifier: cell)
        
        setupSearchController()
        
        customTitleInNavBar()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                let alertController = UIAlertController(title: "Are you sure you want to delete the service?", message: nil, preferredStyle: .actionSheet)
                let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                    guard let `self` = self else { return }
                    let service = self.services[indexPath.row]
                    StorageManager.deleteObject(service)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                
                alertController.addAction(delete)
                alertController.addAction(cancel)
                
                present(alertController, animated: true)
            }
        }
    }
    
    private func setupSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.font = UIFont.searchTextFieldFont
    }
    
    func customTitleInNavBar() {
        
        let imageView = UIImageView()
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.widthAnchor.constraint(equalToConstant: 30)
        ])
        imageView.image = UIImage.titleIcon
        imageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = titileNavBar
        titleLabel.font = UIFont.navigationBarFont
        
        let hStack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        hStack.spacing = 7
        hStack.alignment = .center
        
        navigationItem.titleView = hStack
    }
    
    @IBAction func unwindSegue(_ unwindSegue: UIStoryboardSegue) {
        
        guard let newServiceVC = unwindSegue.source as? NewServiceViewController else { return }
        
        newServiceVC.saveService()
        tableView.reloadData()
    }
    
    @IBAction func sorting(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Sorting", message: "Select type", preferredStyle: .actionSheet)
        let aspending = UIAlertAction(title: "Asсending", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.services = self.services.sorted(byKeyPath: self.nameKeyPath, ascending: true)
            self.tableView.reloadData()
        }
        let descending = UIAlertAction(title: "Descending", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.services = self.services.sorted(byKeyPath: self.nameKeyPath, ascending: false)
            self.tableView.reloadData()
        }
        let latest = UIAlertAction(title: "Latest", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.services = self.services.sorted(byKeyPath: self.dateKeyPath, ascending: false)
            self.tableView.reloadData()
        }
        let oldest = UIAlertAction(title: "Oldest", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.services = self.services.sorted(byKeyPath: self.dateKeyPath, ascending: true)
            self.tableView.reloadData()
        }
        let rating = UIAlertAction(title: "Rating", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.services = self.services.sorted(byKeyPath: self.ratingKeyPath, ascending: false)
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(aspending)
        alertController.addAction(descending)
        alertController.addAction(latest)
        alertController.addAction(oldest)
        alertController.addAction(rating)
        alertController.addAction(cancel)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == segueIdentifierShowDetail {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let newServiceVC = segue.destination as? NewServiceViewController else { return }
            let service = isFiltering ? filteredServices[indexPath.row] : services[indexPath.row]
            newServiceVC.currentService = service
        }
    }
    
}
// MARK: - Table view data source, delegate

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredServices.count
        }
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath) as! CarServiceTableViewCell
        
        let service = isFiltering ? filteredServices[indexPath.row] : services[indexPath.row]
        
        cell.configureCell(indexPath: indexPath, servise: service)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueIdentifierShowDetail, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let service = services[indexPath.row]
//
//        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
//            StorageManager.deleteObject(service)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            completionHandler(true)
//        }
//        deleteAction.image = UIImage.delete
//        deleteAction.backgroundColor = .systemRed
//
//        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
//        return configuration
//    }
//
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let addAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completionHandler in
//            guard let `self` = self else { return }
//            self.performSegue(withIdentifier: self.segueIdentifierNewService, sender: self)
//            completionHandler(true)
//        }
//        addAction.image = UIImage.addNewItem
//        addAction.backgroundColor = .systemBlue
//
//        let configuration = UISwipeActionsConfiguration(actions: [addAction])
//        return configuration
//    }
    
    
}

//MARK: - UISearchController
extension MainViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchTaxt(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchTaxt(_ searchText: String) {
        
        switch searchController.searchBar.selectedScopeButtonIndex {
        case 0: filteredServices = services.filter(sortByName, searchText)
        case 1: filteredServices = services.filter(sortByLocation, searchText)
        case 2: filteredServices = services.filter(sortByType, searchText)
        default: filteredServices = services.filter(sortByName, searchText)
        }
        tableView.reloadData()
        
        /*
         //Фильтрация поиска без использования ScopeBar
         filteredServices = services.filter("name CONTAINS[cd] %@ OR location CONTAINS[cd] %@", searchText, searchText)
         tableView.reloadData()
         */
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = scopeButtonTitles
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsScopeBar = false
    }
    
}
