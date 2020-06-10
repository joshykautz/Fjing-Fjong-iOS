//
//  ScorePopUpViewController.swift
//  Fjing Fjong
//
//  Created by Fjorge Developers on 4/28/20.
//  Copyright © 2020 Fjorge. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SearchTextField
import Alamofire
import SwiftyJSON

class ScorePopUpViewController: UIViewController {
    
    var container: NSPersistentContainer!
    
    var appDelegate : AppDelegate!
        
    @IBOutlet weak var ScoreOne: UITextField!
    @IBOutlet weak var ScoreTwo: UITextField!
    @IBOutlet weak var ConfirmButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        container = appDelegate.persistentContainer
        
        ConfirmButton.isEnabled = false
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
    }
    
    func updateConfirmationButton(){
        if (ScoreOne.text != "" && ScoreTwo.text != ""){
            ConfirmButton.isEnabled = true
        }
        else{
            ConfirmButton.isEnabled = false
        }
    }
    
    @objc func dismissKeyboard() {
        ScoreOne.resignFirstResponder()
        ScoreTwo.resignFirstResponder()
    }
    
    @IBAction func EditingChanged(_ sender: Any) {
        updateConfirmationButton()
    }
    
    @IBAction func ConfirmButtonPressed(_ sender: Any) {
        submit()
        // TODO: Display a loading overlay. Might not be possible using the modal presentation.
    }
    
    @IBAction func CloseButtonTouched(_ sender: Any) {
        self.dismiss(animated: true) {
            // Dismissed
        }
    }
    
    func submit(){
        let tokens = try! container.viewContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Token")) as! [Token]
        let token = tokens.first?.value as String?
        
        var payload64 = token!.components(separatedBy: ".")[1]

        while payload64.count % 4 != 0 {
            payload64 += "="
        }

        let payloadData = Data(base64Encoded: payload64, options:.ignoreUnknownCharacters)!
        let json = try! JSONSerialization.jsonObject(with: payloadData, options: []) as! [String:Any]
        let exp = json["exp"] as! Int
        let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
        let now = Date()
        if (now > expDate) {
            deleteFjingFjongTokens()
            getFjingFjongToken()
            createFjingFjongMatch()
        }
        else {
            createFjingFjongMatch()
        }
    }
    
    func createFjingFjongMatch(){
        let tokens = try! container.viewContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Token")) as! [Token]
        let token = tokens.first?.value as String?
        
        let parameters : [String : Any] = [
            "TeamOneScore" : Int(ScoreOne.text!) as Any,
            "TeamTwoScore" : Int(ScoreTwo.text!) as Any,
            "PlayerOneId": appDelegate.playerOneGUID,
            "PlayerTwoId": appDelegate.playerTwoGUID,
            "PlayerThreeId": appDelegate.playerThreeGUID,
            "PlayerFourId": appDelegate.playerFourGUID
        ]
        
        AF.request("https://api.fjingfjong.com/match",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: ["Authorization": "Bearer " + token!])
            .validate()
            .responseData { response in
                print(response)
                UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController?.dismiss(animated: true, completion: nil)
            }
        
    }
    
    func getFjingFjongToken(){
        AF.request("https://api.fjingfjong.com/authenticate",
                   method: .post,
                   parameters: ["API_KEY": ""],
                   encoder: JSONParameterEncoder.default,
                   headers: ["Content-Type": "application/json"])
            .validate()
            .responseData { response in
                do {
                    let token = NSEntityDescription.insertNewObject(forEntityName: "Token", into: self.container.viewContext) as! Token
                    
                    token.value = JSON(response.data as Any)["token"].string!
                    
                    try self.container.viewContext.save()
                    
                    print("Token saved to Core Data.")
                    
                    NotificationCenter.default.post(name: Notification.Name("TokenVerified"), object: nil)
                    
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
            }
    }
    
    func deleteFjingFjongTokens(){
        do {
            let tokens = try self.container.viewContext.fetch(NSFetchRequest(entityName: "Token")) as! [Token]

            for token in tokens {
                self.container.viewContext.delete(token)
            }

            try self.container.viewContext.save()
            print("Tokens deleted from Core Data.")

        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}
