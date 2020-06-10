//
//  Player+CoreDataProperties.swift
//  
//
//  Created by Fjorge Developers on 4/15/20.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var id: String?
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var photo: Data?
    @NSManaged public var rating: Double

}
