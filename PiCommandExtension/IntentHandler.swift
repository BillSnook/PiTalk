//
//  IntentHandler.swift
//  PiCommandExtension
//
//  Created by William Snook on 10/24/17.
//  Copyright © 2017 billsnook. All rights reserved.
//

import Intents
import AVFoundation

import PiTalker

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension, INSendMessageIntentHandling {
	
	
	override func handler(for intent: INIntent) -> Any {
		// This is the default implementation.  If you want different objects to handle different intents,
		// you can override this and return the handler you want for that particular intent.
		print( "In Siri Intent handler" )
		
		return self
	}
	
	// MARK: - INSendMessageIntentHandling
	
	// MARK: 1. Resolve
	public func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INPersonResolutionResult]) -> Swift.Void) {
		
		if let recipients = intent.recipients {
			var resolutionResults = [INPersonResolutionResult]()
			
			for recipient in recipients {
				let matchingContacts = ContactManager.matching( recipient.displayName )
				
				switch matchingContacts.count {
				case 2 ... Int.max:
					// We need Siri's help to ask user to pick one from the matches.
					let disambiguationOptions: [INPerson] = matchingContacts.map { contact in
						return contact.inPerson()
					}
					
					resolutionResults += [.disambiguation(with: disambiguationOptions)]
					
				case 1:
					let recipientMatched = matchingContacts[0].inPerson()
					resolutionResults += [.success(with: recipientMatched)]
					
				case 0:
					resolutionResults += [.unsupported()]
					
				default:
					break
				}
			}
			
			completion(resolutionResults)
			
		} else {
			// No recipients are provided. We need to prompt for a value.
			completion([INPersonResolutionResult.needsValue()])
		}
	}
	
	public func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Swift.Void) {
		if let text = intent.content, !text.isEmpty {
			completion(INStringResolutionResult.success(with: text))
		}
		else {
			completion(INStringResolutionResult.needsValue())
		}
	}
	
	// MARK: 2. Confirm
	
	public func confirm(intent: INSendMessageIntent, completion: @escaping(INSendMessageIntentResponse) -> Swift.Void) {
		
//        if UCAccount.shared().hasValidAuthentication {
		completion(INSendMessageIntentResponse(code: .success, userActivity: nil))
//        }
//        else {
//            // Creating our own user activity to include error information.
//            let userActivity = NSUserActivity(activityType: String(describing: INSendMessageIntent.self))
//            userActivity.userInfo = [NSString(string: "error"):NSString(string: "UserLoggedOut")]
//
//            completion(INSendMessageIntentResponse(code: .failureRequiringAppLaunch, userActivity: userActivity))
//        }
	}
	
	// MARK: 3. Handle
	public func handle( intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Swift.Void) {
		if intent.recipients != nil && intent.content != nil {
			var recips = [String]()
			for recip in intent.recipients! {
				recips.append( recip.contactIdentifier! )	// Machine name
			}
			
			// Check content, may need help to be a recognized command
			let success = send( intent.content!, to: recips[0] )
//            let success = true // UCAccount.shared().sendMessage(intent.content, toRecipients: recips)
			completion(INSendMessageIntentResponse(code: success ? .success : .failure, userActivity: nil))
		} else {
			completion(INSendMessageIntentResponse(code: .failure, userActivity: nil))
		}
	}
	
	func send( _ message: String, to recipient: String ) -> Bool {
		
		var msg = message.lowercased()	// Siri sometimes capitalizes the first word
		if msg.contains( "blink" ) {
			msg = "blink"
		} else if msg.contains( "stop" ) {
			msg = "blinkstop"
		} else if msg.contains( "ok" ) {
			msg = "ok"
		} else if msg.contains( "hello" ) {
			msg = "hello"
		} else {
			msg = "unrecognized"
		}
		
		let targetPort = Sender()
		let result = targetPort.doMakeConnection( to: recipient, at: 5555 )
		if result {
			_ = targetPort.sendPi( msg )
			targetPort.doBreakConnection()
		}
		
		return result
	}
	
}
