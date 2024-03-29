//
//  AddEditConsoleViewController.swift
//  MyGames
//
//  Created by Eduardo Peregrino on 30/11/19.
//  Copyright © 2019 Eduardo Peregrino. All rights reserved.
//

import UIKit
import Photos

class AddEditConsoleViewController: UIViewController {

    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var ivCover: UIImageView!
    @IBOutlet weak var btCover: UIButton!
    @IBOutlet weak var btAddEdit: UIButton!
    
    var console: Console!
    
    // tip. Lazy somente constroi a classe quando for usar
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .white
        return pickerView
    }()
    var consolesManager = ConsolesManager.shared
    
    @IBAction func AddEditCover(_ sender: UIButton) {
        // para adicionar uma imagem da biblioteca
        print("para adicionar uma imagem da biblioteca")
        
        
        let alert = UIAlertController(title: "Selecinar capa", message: "De onde você quer escolher a capa?", preferredStyle: .actionSheet)
        
         let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default, handler: {(action: UIAlertAction) in
             self.selectPicture(sourceType: .photoLibrary)
         })
         alert.addAction(libraryAction)
        
         let photosAction = UIAlertAction(title: "Album de fotos", style: .default, handler: {(action: UIAlertAction) in
             self.selectPicture(sourceType: .savedPhotosAlbum)
         })
         alert.addAction(photosAction)
        
         let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
         alert.addAction(cancelAction)
        
         present(alert, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerController.SourceType) {
       
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                   
                    self.chooseImageFromLibrary(sourceType: sourceType)
                   
                } else {
                   
                    print("unauthorized -- TODO message")
                }
            })
        } else if photos == .authorized {
           
            self.chooseImageFromLibrary(sourceType: sourceType)
        }
    }
    
    func chooseImageFromLibrary(sourceType: UIImagePickerController.SourceType) {
        
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.navigationBar.tintColor = UIColor(named: "main")
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addEditConsole(_ sender: UIButton) {
        //TODO: Save console here
        // acao salvar novo ou editar existente
        if console == nil {
          console = Console(context: context)
        }
        console.name = tfTitle.text
        console.image = ivCover.image
        
        do {
           try context.save()
        } catch {
           print(error.localizedDescription)
        }
        // Back na navigation
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddEditConsoleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
   
   
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return consolesManager.consoles.count
    }
   
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let console = consolesManager.consoles[row]
        return console.name
    }
}

extension AddEditConsoleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // tip. implementando os 2 protocols o evento sera notificando apos user selecionar a imagem
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            // ImageView won't update with new image
            // bug fixed: https://stackoverflow.com/questions/42703795/imageview-wont-update-with-new-image
            DispatchQueue.main.async {
                self.ivCover.image = pickedImage
                self.ivCover.setNeedsDisplay()
                self.btCover.setTitle(nil, for: .normal)
                self.btCover.setNeedsDisplay()
            }
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
