//
//  Metadata+CoreDataProperties.swift
//  
//
//  Created by Fjorge Developers on 4/19/20.
//
//

import Foundation
import CoreData


extension Metadata {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Metadata> {
        return NSFetchRequest<Metadata>(entityName: "Metadata")
    }

    @NSManaged public var playersLastSynced: Date?
    @NSManaged public var photosLastSynced: Date?

}
