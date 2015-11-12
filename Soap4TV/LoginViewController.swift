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
	
	
	@IBAction func loginAction(sender: AnyObject) { doLogin()}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

	func doLogin() {
	
		guard let login = loginField.text where login.count > 2, let password = passwordField.text where password.count > 2 else {
			return
		}
		
		API().login(login, password: password) { result, error in
			self.errorTitle.hidden = true
			self.errorMessage.hidden = true
			if let error = error {
				print("Network error, \(error)")
				self.errorTitle.hidden = false
				return
			}
			if let result = result {
				if result["ok"] == 1 {
					Defaults[.token] = result["token"].stringValue
					Defaults[.till] = result["till"].intValue
					Defaults[.sid] = result["sid"].stringValue
					self.performSegueWithIdentifier("openAppSegue", sender: nil)
				} else {
					self.errorTitle.hidden = false
					self.errorMessage.hidden = false
					return
				}
			}
		}
	}
	
	
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

}
