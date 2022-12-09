//
//  NewServiceViewController.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 22.11.2022.
//

import UIKit

class NewServiceViewController: UITableViewController {
    
    //MARK: - Private constants
    private let segueIdentifierShowService = "showService"
    
    var currentService: Service!
    private var imageIsChanged = false
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceName: UITextField!
    @IBOutlet weak var serviceType: UITextField!
    @IBOutlet weak var serviceLocation: UITextField!
    @IBOutlet weak var servicePhone: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        
        //Для отслеживания редактирования поля name
        serviceName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        setupEditScreen()
        
        tableView.makeCorner(with: 10)
        
        //Убираем границу под рейтингом
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: CGFloat.leastNormalMagnitude))
        //Убираем отстпуп над секцией
        tableView.sectionHeaderTopPadding = CGFloat.leastNormalMagnitude
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cameraIcon = UIImage.cameraIcon
        let photoIcon = UIImage.photoIcon
        
        if indexPath.row == 0 {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                guard let `self` = self else { return }
                self.chooseImagePicker(sourse: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { [weak self] _ in
                guard let `self` = self else { return }
                self.chooseImagePicker(sourse: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            
        } else {
            //Скрываем клавиатуту по нажатию за пределами клавиатуры и прелелами первой ячейки
            view.endEditing(true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func saveService() {
        
        let image = imageIsChanged ? serviceImage.image : UIImage.placeholder
        
        let imageData = image?.pngData()
        
        let newService = Service(name: serviceName.text!, type: serviceType.text, location: serviceLocation.text, phone: servicePhone.text, imageData: imageData, rating: Double(ratingControl.rating))
        
        if currentService != nil {
            try! realm.write {
                currentService?.name = newService.name
                currentService?.type = newService.type
                currentService?.location = newService.location
                currentService?.phone = newService.phone
                currentService?.imageData = newService.imageData
                currentService?.rating = newService.rating
            }
        } else {
            StorageManager.saveObject(newService)
        }
    }
    
    private func setupEditScreen() {
        
        if currentService != nil {
            
            setupNavigationBar()
            
            imageIsChanged = true
            
            serviceName.text = currentService.name
            serviceType.text = currentService.type
            serviceLocation.text = currentService.location
            servicePhone.text = currentService.phone
            ratingControl.rating = Int(currentService.rating)
            
            guard let data = currentService?.imageData, let image = UIImage(data: data) else { return }
            serviceImage.image = image
            serviceImage.contentMode = .scaleAspectFill
            serviceImage.clipsToBounds = true
        }
    }
    
    private func setupNavigationBar() {
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentService?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, let mapVC = segue.destination as? MapViewController else { return }
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == segueIdentifierShowService {
            mapVC.place.name = serviceName.text!
            mapVC.place.location = serviceLocation.text
            mapVC.place.type = serviceType.text
            mapVC.place.imageData = serviceImage.image?.pngData()
        }
    }
    
}
//MARK: - Text field delegate

extension NewServiceViewController: UITextFieldDelegate {
    
    //Скрываем клавиатуту по нажатию на done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        
        saveButton.isEnabled = serviceName.text?.isEmpty == false ? true : false
    }
    
}

//MARK: - Work with image

extension NewServiceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(sourse: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourse) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourse
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        serviceImage.image = info[.editedImage] as? UIImage
        serviceImage.contentMode = .scaleAspectFill
        serviceImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
    
}

//MARK: - MapViewControllerDelegate
extension NewServiceViewController: MapViewControllerDelegate {
    
    func getAddress(_ address: String?) {
       
        serviceLocation.text = address
    }
}
