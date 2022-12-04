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
    private let segueIdentifierShowDetail = "showDetail"
    private let segueIdentifierToNewPlaceVC = "NewPlaceVC"
    private let cell = "Cell"
    private let dateKeyPath = "date"
    private let nameKeyPath = "name"
    private let sortByName = "name CONTAINS[cd] %@"
    private let sortByLocation = "location CONTAINS[cd] %@"
    private let sortByType = "type CONTAINS[cd] %@"
    private let scopeButtonTitles = ["Name", "Location", "Type"]
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
            return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self)
        
        //Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.font = UIFont.searchTextFieldFont
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.segmentedControlFont as Any], for: .normal)
    }
    
    @IBAction func unwindSegue(_ unwindSegue: UIStoryboardSegue) {
        
        guard let newPlaceVC = unwindSegue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        
        ascendingSorting.toggle()
        
        reversedSortingButton.image = ascendingSorting ? UIImage.sortByAZ : UIImage.sortByZA
        
        sorting()
    }
    
    private func sorting() {
        
        places = segmentedControl.selectedSegmentIndex == 0 ? places.sorted(byKeyPath: dateKeyPath, ascending: ascendingSorting) : places.sorted(byKeyPath: nameKeyPath, ascending: ascendingSorting)
        
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == segueIdentifierShowDetail {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let newPlaceVC = segue.destination as? NewPlaceViewController else { return }
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            newPlaceVC.currentPlace = place
        }
    }
        
}
// MARK: - Table view data source, delegate

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath) as! CustomTableViewCell
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
                 
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.cellRating.rating = Int(place.rating)
        
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.contentMode = .scaleAspectFill
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        deleteAction.image = UIImage.delete
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let addAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completionHandler in
            guard let `self` = self else { return }
            self.performSegue(withIdentifier: self.segueIdentifierToNewPlaceVC, sender: self)
            completionHandler(true)
        }
        addAction.image = UIImage.addNewItem
        addAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [addAction])
        return configuration
    }
    
    
}

//MARK: - UISearchController
extension MainViewController: UISearchResultsUpdating, UISearchBarDelegate {
   
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchTaxt(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchTaxt(_ searchText: String) {
        
    switch searchController.searchBar.selectedScopeButtonIndex {
    case 0: filteredPlaces = places.filter(sortByName, searchText)
    case 1: filteredPlaces = places.filter(sortByLocation, searchText)
    case 2: filteredPlaces = places.filter(sortByType, searchText)
    default: filteredPlaces = places.filter(sortByName, searchText)
    }
        tableView.reloadData()
        
        /*
        //Фильтрация поиска без использования ScopeBar
        filteredPlaces = places.filter("name CONTAINS[cd] %@ OR location CONTAINS[cd] %@", searchText, searchText)
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
