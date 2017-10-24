//
//  ViewController.swift
//  PiCommand
//
//  Created by William Snook on 10/11/17.
//  Copyright © 2017 billsnook. All rights reserved.
//

import UIKit
import Intents

class ViewController: UIViewController, UITextFieldDelegate {
	
	@IBOutlet weak var targetHostName: UITextField!
	@IBOutlet weak var connectButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	@IBOutlet weak var commandView: UIView!
	@IBOutlet weak var commandField: UITextField!
	@IBOutlet weak var responseView: UITextView!
	
	let targetPort = Sender()
	var isConnected = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		connectButton.setTitle( "Connect", for:  .normal )
		targetHostName.text = "zerowpi2"
		
		commandView.isHidden = true
		isConnected = false
		//Looks for single or multiple taps
		let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(self.dismissKeyboard) )
		//Uncomment the line below if you want the tap not not interfere and cancel other interactions.
		//tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
		
		activityIndicator.stopAnimating()

		INPreferences.requestSiriAuthorization() { (status) in
			print( "\nSiri authorization status: \(status)\n")
		}
}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	//Calls this function when the tap is recognized.
	@objc func dismissKeyboard() {
		//Causes the view (or one of its embedded text fields) to resign the first responder status.
		view.endEditing(true)
	}

	@IBAction func doConnect(_ sender: UIButton) {
		
		if isConnected {			// If isConnected, we must be disconnecting
			print( "\nDisconnecting from host \(targetHostName.text!)" )
			targetPort.doBreakConnection()
			isConnected = false
			targetHostName.isEnabled = true
			connectButton.setTitle( "Connect", for:  .normal )
			commandView.isHidden = true
			commandField.text = ""
			responseView.text = ""
		} else {					// Else we must be connecting
			if targetHostName.text!.count >= 0 {
				print( "\nConnecting to host \(targetHostName.text!)" )
				targetHostName.isEnabled = false
				connectButton.isEnabled = false
				activityIndicator.startAnimating()
				let hostName = self.targetHostName.text!
				DispatchQueue.global( qos: .userInitiated ).async {
					self.isConnected = self.targetPort.doMakeConnection( to: hostName, at: 5555 )
					DispatchQueue.main.async {
						if self.isConnected {
							self.connectButton.setTitle( "Disconnect", for:  .normal )
							self.commandView.isHidden = false
						} else {
							self.targetHostName.isEnabled = true
						}
						self.connectButton.isEnabled = true
						self.activityIndicator.stopAnimating()
					}
				}
			}
		}
	}
	
	@IBAction func okCmd(_ sender: UIButton) {
		if isConnected {
			let reply = targetPort.sendPi( "ok" )
			print( "\nSent ok, got \(reply)" )
			responseView.text = reply
		}
	}
	
	@IBAction func helloCmd(_ sender: UIButton) {
		if isConnected {
			let reply = targetPort.sendPi( "hello" )
			print( "\nSent hello, got \(reply)" )
			responseView.text = reply
		}
	}
	
	@IBAction func blinkCmd(_ sender: UIButton) {
		if isConnected {
			let reply = targetPort.sendPi( "blink" )
			print( "\nSent blink, got \(reply)" )
			responseView.text = reply
		}
	}
	
	@IBAction func unblinkCmd(_ sender: UIButton) {
		if isConnected {
			let reply = targetPort.sendPi( "blinkstop" )
			print( "\nSent blinkstop, got \(reply)" )
			responseView.text = reply
		}
	}

	
	// MARK: - UITextFieldDelegate
	func textFieldShouldReturn(_ textField: UITextField) -> Bool  {	// called when 'return' key pressed. return NO to ignore.
	
		guard let commandString = textField.text else { return false }
		let returnString = targetPort.sendPi( commandString )
		responseView.text = returnString
		textField.text = ""
		textField.resignFirstResponder()
		return true
	}

}

