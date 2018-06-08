//
//  ViewController.swift
//  FoodServiceManager
//
//  Created by Victoria Kravets on 08.06.2018.
//  Copyright © 2018 Victoria Kravets. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: -
    //MARK: Properties
 
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    @IBOutlet weak var nameTextField: UITextField?
    @IBOutlet weak var menuLabel: UILabel?
    @IBOutlet weak var findMenuButton: UIButton?
    @IBOutlet weak var dayPickerView: UIPickerView?
    @IBOutlet weak var chooseDayLabel: UILabel?
    @IBOutlet weak var enterNameLabel: UILabel?

    var signInButton: GIDSignInButton?
    
    private let service = GTLRSheetsService()
    
    private var checkingName = ""
    private var rowNumber = -1
    private var result = ""
    private var day = ""
    
    //MARK: -
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureGoogleSingIn()
        self.configureButton()
    }
    
    //MARK: -
    //MARK: Actions
    
    @IBAction func findMenu(_ sender: UIButton) {
        self.nameTextField?.text.do { self.checkingName = $0 }
        self.listMajors(range: Constants.nameRange)
    }
    
    //MARK: -
    //MARK: GoogleSingIn
    
    func sign(_ signIn: GIDSignIn?, didSignInFor user: GIDGoogleUser?,
              withError error: Error!) {

        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
            
        } else {
            self.configureLabels()
            self.service.authorizer = user?.authentication.fetcherAuthorizer()
        }
    }
    
    //MARK: -
    //MARK: PickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.Days.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.Days[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.day = Constants.Days[row]
    }
    
    //MARK: -
    //MARK: Private
    
    private func listMajors(range: String) {
       
        let spreadsheetId = Constants.spreadsheetId
        let range = "\(self.day)\(range)"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    @objc private func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        result.values.do { rows in
             if self.rowNumber < 0 {
                for number in 0...rows.count - 1 {
                    let name: String? = rows[number][0] as? String
                    
                    if name == checkingName {
                        self.rowNumber = number + 3
                        self.listMajors(range: "!A\(self.rowNumber):M\(self.rowNumber)")
                        break
                    }
                }
                
                if self.rowNumber < 0 {
                    self.checkResult()
                }
                
            } else {
                for row in 1...rows[0].count - 1 {
                    let dish: String? = rows[0][row] as? String
                    if dish == "1" {
                        self.result.append("\(Constants.Dishes[row-1])\n")
                    }
                }

                self.menuLabel?.text = self.result
                self.clearValues()
            }
        }
    }
    
    private func clearValues() {
        self.checkingName = ""
        self.result = ""
        self.rowNumber = -1
    }
    
    private func checkResult() {
        if self.result.isEmpty {
            self.menuLabel?.text = "Ничего не найдено по этому имени"
            return
        }
    }
    
    private func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func configureGoogleSingIn() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    private func configureButton() {
            self.signInButton = GIDSignInButton(frame: CGRect(x: 140, y: 20, width: 122, height: 48))
            self.signInButton.do(self.view.addSubview(_:))
    }
    
    private func configureLabels() {
        self.signInButton?.isHidden = true
        self.nameTextField?.isHidden = false
        self.findMenuButton?.isHidden = false
        self.dayPickerView?.isHidden = false
        self.chooseDayLabel?.isHidden = false
        self.enterNameLabel?.isHidden = false
    }
}
