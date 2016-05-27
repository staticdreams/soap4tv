//
//  LoginViewController.swift
//  Soap4TV
//
//  Created by Peter on 09/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import KeychainAccess


class LoginViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var loginField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	
	@IBOutlet weak var errorTitle: UILabel!
	@IBOutlet weak var errorMessage: UILabel!
	
	var token = ""
	
	let keychain = Keychain(service: "me.soap4.password")
		.synchronizable(true)
	
	var api = API()
	var tvdb = TVDB()
	
	// MARK: - Methods
	
	@IBAction func loginAction(sender: AnyObject) { doLogin()}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		loginField.text = Defaults.hasKey(.login) ? Defaults[.login]! : ""
		passwordField.text = (loginField.text!.count > 0) ? keychain[ loginField.text! ] : ""
		
		tvdb.login(Config.tvdb.username, userkey: Config.tvdb.userKey, apikey: Config.tvdb.apikey) { result, error in
			if let error = error {
				print("Error logging into TVDB: \(error)")
				Defaults[.TVDBToken] = nil
			}
			if let result = result where result["token"] != nil {
				Defaults[.TVDBToken] = result["token"].stringValue
			}
		}
		
		if (loginField.text?.count > 0 && passwordField.text?.count > 0) {
			doLogin()
		}
	}
	
	override var preferredFocusedView: UIView? {
		if (loginField.text?.count > 0 && passwordField.text?.count > 0) {
			return self.loginButton
		}
		
		if (loginField.text?.count > 0) {
			return passwordField
		}
		
		return loginField
	}

	func doLogin() {
	
		guard let login = loginField.text where login.count > 2, let password = passwordField.text where password.count > 2 else {
			return
		}
		
		let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
		
		activityIndicator.center = self.view.center
		activityIndicator.hidesWhenStopped = true
		view.addSubview(activityIndicator)
		activityIndicator.startAnimating()
		loginButton.userInteractionEnabled = false
		
		api.login(login, password: password) { result, error in
			self.errorTitle.hidden = true
			self.errorMessage.hidden = true
			if let error = error {
				print("Network error, \(error)")
				self.errorTitle.hidden = false
				activityIndicator.stopAnimating()
				self.loginButton.userInteractionEnabled = true
			}
			if let result = result where result["ok"] == 1 {
				Defaults[.login] = login
				Defaults[.token] = result["token"].stringValue
				Defaults[.till] = result["till"].intValue
				Defaults[.sid] = result["sid"].stringValue
				self.token = result["token"].stringValue
				delay(0.5) {
					self.loginButton.userInteractionEnabled = true
					activityIndicator.stopAnimating()
					self.performSegueWithIdentifier("openAppSegue", sender: nil)
				}
				
				// saving password to keychain
				self.keychain[login] = password
				
			} else {
				activityIndicator.stopAnimating()
				self.errorTitle.hidden = false
				self.errorMessage.hidden = false
				self.loginButton.userInteractionEnabled = true
				
				self.keychain[login] = nil
				return
			}
			
		}
	}
	
	// MARK: - UITextFieldDelegate
	
	func textFieldDidEndEditing(textField: UITextField) {
		if (textField == passwordField) {
			self.view.setNeedsFocusUpdate()
			self.view.updateFocusIfNeeded()
		}
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "openAppSegue" {
			if let destination = (segue.destinationViewController as! MainNavigationController).childViewControllers.first as? HomeViewController {
				destination.token = token
			}
		}
    }

	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

}
