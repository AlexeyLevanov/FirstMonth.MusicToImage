//
//  ViewController.swift
//  1. MusicToImage
//
//  Created by Alexey Levanov on 10.08.2021.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	let recognitionModel = MobileNetV2()
	let pulseButton: PulseButton = PulseButton.init(type: .custom)
	let label: UILabel = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		pulseButton.frame = CGRect.init(x: 100, y: 100, width: 100, height: 100)
		pulseButton.center = CGPoint.init(x: view.center.x, y: view.frame.size.height - pulseButton.frame.size.height - 50)
		pulseButton.buttonColor = UIColor.init(red: 10/255.0, green: 59/255.0, blue: 134/255.0, alpha: 1)
		pulseButton.pulseColor = UIColor.init(red: 45/255.0, green: 99/255.0, blue: 170/255.0, alpha: 1)
		pulseButton.pulseRadius = 12
		pulseButton.pulseDuration = 1.5
		pulseButton.cornerRadius = 50
		pulseButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		view.addSubview(pulseButton)
		
		let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
		imageView.image = UIImage.init(named: "playAlong")
		imageView.center = CGPoint.init(x: pulseButton.frame.size.width/2 + 3, y: pulseButton.frame.size.height/2)
		pulseButton.addSubview(imageView)
		
		let timer = Timer.scheduledTimer(timeInterval: 0.7,
										 target: self,
										 selector: #selector(updateTimer),
										 userInfo: nil,
										 repeats: true)
		timer.fire()
		
		label.frame = CGRect.init(x: 10, y: 10, width: self.view.frame.size.width - 10*2, height: 300)
		label.numberOfLines = 0
		label.textAlignment = .center
		view.addSubview(label)
	}
 
	@objc func updateTimer() {
		pulseButton.makePulse()
	}
	
	@objc func buttonTapped() {
		let imagePickerController = UIImagePickerController()
		 imagePickerController.allowsEditing = false
		 imagePickerController.sourceType = .photoLibrary
		 imagePickerController.delegate = self
		 present(imagePickerController, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
		let model = try? VNCoreMLModel(for: recognitionModel.model)
		guard let strongModel = model else { return }
		let request = VNCoreMLRequest(model: strongModel) { (request, error) in
			guard let results = request.results as? [VNClassificationObservation] else { return }
			// Выводим три основных тезиса
			// Иногда идентификаторы содержат перечисление через запятую. нужно разбивать и вытаскивать каждое слово отдельно. И решить  - брать ли все или только одно
			DispatchQueue.main.async {
				self.label.text = "Песня о \(results[0].identifier) и \n +  \(results[1].identifier) и еще o\n \(results[2].identifier)"
			}
		}
//		guard let image = UIImage(named: "me") else { return }
		guard let ciImage: CIImage = CIImage(image: tempImage) else { return }
		let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
		DispatchQueue.global(qos: .userInteractive).async {
			do
			{
				try handler.perform([request])
			} catch { print("error") }
		}
		self.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}

}

