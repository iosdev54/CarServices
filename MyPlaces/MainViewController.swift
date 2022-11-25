//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 21.11.2022.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    private var places: Results<Place>!
    private var ascendingSorting = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self)
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
        
        reversedSortingButton.image = ascendingSorting ? UIImage(named: "AZ") : UIImage(named: "ZA")
        
        sorting()
    }
    
    private func sorting() {
        
        places = segmentedControl.selectedSegmentIndex == 0 ? places.sorted(byKeyPath: "date", ascending: ascendingSorting) : places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let newPlaceVC = segue.destination as? NewPlaceViewController else { return }
            let place = places[indexPath.row]
            newPlaceVC.currentPlace = place
        }
    }
    
        
}
// MARK: - Table view data source, delegate

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.contentMode = .scaleAspectFill
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        
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
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        let addAction = UIContextualAction(style: .normal, title: nil) { _, _, completionHandler in
            self.performSegue(withIdentifier: "NewPlaceVC", sender: self)
            completionHandler(true)
        }
        addAction.image = UIImage(systemName: "plus.square")
        addAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, addAction])
        return configuration
    }
    
    
}
