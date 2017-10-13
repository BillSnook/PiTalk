//
//  ViewController.swift
//  PiTalk
//
//  Created by William Snook on 10/11/17.
//  Copyright © 2017 billsnook. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet weak var targetHostName: UITextField!
	@IBOutlet weak var connectButton: UIButton!

	@IBOutlet weak var commandView: UIView!
	@IBOutlet weak var commandField: UITextField!

	let targetPort = Sender()
	var isConnected = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		connectButton.setTitle( "Connect", for:  .normal )
		targetHostName.text = "zerowpi2"
		
		commandView.isHidden = true
		isConnected = false
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func doConnect(_ sender: UIButton) {
		
		if isConnected {
			print( "\nDisconnecting from host \(targetHostName.text!)" )
			targetPort.doBreakConnection()
			isConnected = false
			connectButton.setTitle( "Connect", for:  .normal )
			targetHostName.isEnabled = true
			commandView.isHidden = true
		} else {
			if targetHostName.text!.count >= 0 {
				print( "\nConnecting to host \(targetHostName.text!)" )
				isConnected = targetPort.doMakeConnection( to: targetHostName.text!, at: 5555 )
				if isConnected {
					connectButton.setTitle( "Disconnect", for:  .normal )
					targetHostName.isEnabled = false
					commandView.isHidden = false
				}
			}
		}
	}
	
	@IBAction func blinkCmd(_ sender: UIButton) {
		if isConnected {
			let reply = targetPort.sendPi( "blink\n" )
			print( "\nSent blink, got \(reply)" )
		}
	}
	
	@IBAction func unblinkCmd(_ sender: UIButton) {
		if isConnected {
			let reply = targetPort.sendPi( "blinkstop\n" )
			print( "\nSent blinkstop, got \(reply)" )
		}
	}

}

