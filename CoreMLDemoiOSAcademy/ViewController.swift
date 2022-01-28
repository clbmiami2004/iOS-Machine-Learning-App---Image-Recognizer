//
//  ViewController.swift
//  CoreMLDemoiOSAcademy
//
//  Created by Christian Lorenzo on 1/27/22.
//

import UIKit
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Select Image"
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(label)
        view.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapImage))
        
        tap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 20, y: view.safeAreaInsets.top,
                                 width: view.frame.size.width - 40,
                                 height: view.frame.size.width - 40)
        
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top + (view.frame.size.width - 40),
                             width: view.frame.size.width - 40,
                             height: 100)
    }
    
    @objc func didTapImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func analyzedImage(image: UIImage?) {
        guard let buffer = image?.resize(size: CGSize(width: 224, height: 224))?.getCVPixelBuffer() else {
            return
        }
        
        do {
            let config = MLModelConfiguration()
            let model = try GoogLeNetPlaces(configuration: config)
            let input = GoogLeNetPlacesInput(sceneImage: buffer)
            
            let output = try model.prediction(input: input)
            let text = output.sceneLabel
            label.text = text
        }
        catch {
            print(error.localizedDescription)
        }
    }

    ///Image Picker Delegate Functions:

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //Cancel
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        imageView.image = image
        analyzedImage(image: image)
    }

}

