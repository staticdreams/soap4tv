//
//  LoginViewController.swift
//  Soap4TV
//
//  Created by Peter on 09/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class LoginViewController: UIViewController {

	@IBOutlet weak var loginField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	
	@IBOutlet weak var errorTitle: UILabel!
	@IBOutlet weak var errorMessage: UILabel!
	
	var token = ""
	
	@IBAction func loginAction(sender: AnyObject) { doLogin()}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		loginField.text = Defaults.hasKey(.login) ? Defaults[.login]! : ""
		passwordField.text = Defaults.hasKey(.password) ? Defaults[.password]! : ""
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
		
		API().login(login, password: password) { result, error in
			self.errorTitle.hidden = true
			self.errorMessage.hidden = true
			if let error = error {
				print("Network error, \(error)")
				self.errorTitle.hidden = false
				activityIndicator.stopAnimating()
				self.loginButton.userInteractionEnabled = true
			}
			if let result = result {
				if result["ok"] == 1 {
//					print("Current token is: \(result["token"].stringValue)")
					Defaults[.login] = login
					Defaults[.password] = password
					Defaults[.token] = result["token"].stringValue
					Defaults[.till] = result["till"].intValue
					Defaults[.sid] = result["sid"].stringValue
					self.token = result["token"].stringValue
					delay(0.5) {
						self.loginButton.userInteractionEnabled = true
						activityIndicator.stopAnimating()
						self.performSegueWithIdentifier("openAppSegue", sender: nil)
					}
				} else {
					activityIndicator.stopAnimating()
					self.errorTitle.hidden = false
					self.errorMessage.hidden = false
					self.loginButton.userInteractionEnabled = true
					return
				}
			}
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
