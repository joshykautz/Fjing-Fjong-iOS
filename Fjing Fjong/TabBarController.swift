//
//  TabBarController.swift
//  Fjing Fjong
//
//  Created by Fjorge Developers on 3/20/20.
//  Copyright © 2020 Fjorge. All rights reserved.
//

import Foundation
import UIKit
import CoreData

import Alamofire
import SwiftyJSON

class TabBarController: UITabBarController {
    
    var container: NSPersistentContainer!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        LoadingOverlay.shared.showOverlay(view: self.view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(validateFjingFjongTokenSuccess), name: Notification.Name("TokenVerified"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(validateFjingFjongPlayersSuccess), name: Notification.Name("PlayersVerified"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        
        validateFjingFjongToken()
    }
    
    @objc func validateFjingFjongTokenSuccess() {
        validateFjingFjongPlayers()
    }
    
    @objc func validateFjingFjongPlayersSuccess() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.playersVerified = true
        NotificationCenter.default.post(name: Notification.Name("setupGraph"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("validateFjingFjongPhotos"), object: nil)
    }
    
    @objc func rotated() {
        LoadingOverlay.shared.redrawOverlay(view: self.view)
    }
    
    func validateFjingFjongToken(){
        let tokens = try! container.viewContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Token")) as! [Token]
        let token = tokens.first?.value as String?
        
        if (token == nil){
            getFjingFjongToken()
        }
        else {
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
            }
            else {
                print("Using existing Token from Core Data.")
                NotificationCenter.default.post(name: Notification.Name("TokenVerified"), object: nil)
            }
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Handle didSelect viewController method here
    }
    
    // TODO: Handle no internet connection
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
    
    func validateFjingFjongPlayers(){
        let metadatas = try! self.container.viewContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Metadata")) as! [Metadata]
        let playerLastSynced = metadatas.first?.playersLastSynced as Date?
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        if (playerLastSynced == nil){
            deleteFjingFjongPlayers()
            getFjingFjongPlayers()
        }
        else {
            if (playerLastSynced! < oneDayAgo!){
                deleteFjingFjongPlayers()
                getFjingFjongPlayers()
            }
            else {
                print("Using Players in Core Data.")
                NotificationCenter.default.post(name: Notification.Name("PlayersVerified"), object: nil)
            }
        }
    }
    
    func getFjingFjongPlayers(){
        let tokens = try! self.container.viewContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Token")) as! [Token]
        let token = tokens.first?.value as String?
        
        AF.request("https://api.fjingfjong.com/player",
                   method: .get,
                   headers: ["Authorization": "Bearer " + token!])
            .validate()
            .responseData { response in
                    
                do {
                    for object in JSON(response.data as Any) {
                        let player = NSEntityDescription.insertNewObject(forEntityName: "Player", into: self.container.viewContext) as! Player
                        player.id = object.1["id"].string!
                        player.name = object.1["name"].string!
                        player.rating = object.1["rating"].double!
                        player.image = object.1["image"].string
                        
                        try self.container.viewContext.save()
                    }
                    
                    print("Players saved to Core Data.")
                    
                    let metadatas = try self.container.viewContext.fetch(NSFetchRequest(entityName: "Metadata")) as! [Metadata]
                    var metadata = metadatas.first
                    
                    if (metadata == nil){
                        metadata = (NSEntityDescription.insertNewObject(forEntityName: "Metadata", into: self.container.viewContext) as! Metadata)
                    }
                    
                    metadata!.playersLastSynced = Date()
                    try self.container.viewContext.save()
                    
                    print("Players Metadata saved to Core Data.")
                    
                    NotificationCenter.default.post(name: Notification.Name("PlayersVerified"), object: nil)
                    
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
        }
    }
    
    func deleteFjingFjongPlayers(){
        do {
            let players = try self.container.viewContext.fetch(NSFetchRequest(entityName: "Player")) as! [Player]

            for player in players {
                self.container.viewContext.delete(player)
            }

            try self.container.viewContext.save()
            print("Players deleted from Core Data.")

        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}
