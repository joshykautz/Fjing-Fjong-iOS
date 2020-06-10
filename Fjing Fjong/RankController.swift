//
//  RankController.swift
//  Fjing Fjong
//
//  Created by Fjorge Developers on 3/20/20.
//  Copyright © 2020 Fjorge. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Lottie
import AVFoundation
import ScrollableGraphView
import Alamofire
import SwiftyJSON

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

extension UIImage {
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)
        self.init(data: imageData)
    }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}



class RankController: UIViewController, ScrollableGraphViewDataSource {
    
    var container: NSPersistentContainer!
        
    var graphView: ScrollableGraphView!
    var graphConstraints = [NSLayoutConstraint]()
    
    private var plotTuples: [(name: String, rating: Double)] = []
    private var plotNames: [String] = []
    private var plotRatings: [Double] = []
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        return plotRatings[pointIndex]
    }

    func label(atIndex pointIndex: Int) -> String {
        return plotNames[pointIndex]
    }

    func numberOfPoints() -> Int {
        return plotRatings.count
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        container = appDelegate.persistentContainer
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
                                
        NotificationCenter.default.addObserver(self, selector: #selector(on(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupGraph), name: Notification.Name("setupGraph"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(validateFjingFjongPhotos), name: Notification.Name("validateFjingFjongPhotos"), object: nil)
    
        if(appDelegate.playersVerified){
            NotificationCenter.default.post(name: Notification.Name("setupGraph"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("validateFjingFjongPhotos"), object: nil)
        }
    }
    
    @objc func setupGraph() {
        let players = try! self.container.viewContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Player")) as! [Player]
        for player in players {
            self.plotTuples.append ((player.name!,player.rating))
        }

        self.plotTuples = self.plotTuples.sorted(by: {$0.rating > $1.rating})

        for tuple in self.plotTuples {
            self.plotNames.append(tuple.name)
            self.plotRatings.append(tuple.rating)
        }

        self.graphView = ScrollableGraphView(frame: self.view.frame, dataSource: self)
        let barPlot = BarPlot(identifier: "barPlot")
        barPlot.barWidth = 25
        barPlot.barLineWidth = 1
        barPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        barPlot.animationDuration = 1.5

        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)

        if self.traitCollection.userInterfaceStyle == .light {
            barPlot.barLineColor = UIColor(rgb: 0x16aafc)
            barPlot.barColor = UIColor(rgb: 0x16aafc).withAlphaComponent(0.5)
            referenceLines.referenceLineColor = UIColor.black.withAlphaComponent(0.2)
            referenceLines.referenceLineLabelColor = UIColor.black
            referenceLines.dataPointLabelColor = UIColor.black.withAlphaComponent(0.5)
            self.graphView.backgroundFillColor = UIColor(rgb: 0xffffff)

        }
        else {
            barPlot.barLineColor = UIColor(rgb: 0x777777)
            barPlot.barColor = UIColor(rgb: 0x777777).withAlphaComponent(0.5)
            referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
            referenceLines.referenceLineLabelColor = UIColor.white
            referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
            self.graphView.backgroundFillColor = UIColor(rgb: 0x333333)
        }

        self.graphView.shouldAnimateOnStartup = true
        self.graphView.shouldAnimateOnAdapt = true
        self.graphView.shouldRangeAlwaysStartAtZero = true
        self.graphView.dataPointSpacing = 80
        self.graphView.rangeMax = self.plotRatings.max()!
        //self.graphView.topMargin = self.view.safeAreaLayoutGuide.layoutFrame.origin.y
        self.graphView.topMargin = 44
        // TODO: don't set up graph until after the tab bar controller has loaded so that the height of the tab bar controller is 83 instead of 49. Use async dispatch queue like i do for image downloads.
        self.graphView.bottomMargin = 83 + 10
        //self.graphView.bottomMargin = self.tabBarController!.tabBar.frame.height + 10
        self.graphView.addPlot(plot: barPlot)
        self.graphView.addReferenceLines(referenceLines: referenceLines)
        self.view.addSubview(self.graphView)
        self.setupConstraints()

        LoadingOverlay.shared.fadeOverlay()
    }
    
    @objc func validateFjingFjongPhotos() {
        let metadatas = try! self.container.viewContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Metadata")) as! [Metadata]
        let photosLastSynced = metadatas.first?.photosLastSynced as Date?
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        if (photosLastSynced == nil){
            getFjingFjongPhotos()
        }
        else {
            if (photosLastSynced! < oneWeekAgo!){
                getFjingFjongPhotos()
            }
            else {
                print("Using Photos in Core Data.")
            }
        }
    }
    
    func getFjingFjongPhotos() {
        let players = try! self.container.viewContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Player")) as! [Player]
        
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            for player in players {
                do{
                    let photo = try UIImage(withContentsOfUrl: URL(string: player.image!)!)
                    player.photo = photo!.pngData()
                }
                catch {
                    fatalError("Failure to download image: \(error)")
                }
            }
            
            do{
                try self.container.viewContext.save()
                print("Photos saved to Core Data.")
                
                let metadatas = try self.container.viewContext.fetch(NSFetchRequest(entityName: "Metadata")) as! [Metadata]
                var metadata = metadatas.first
                
                if (metadata == nil){
                    metadata = (NSEntityDescription.insertNewObject(forEntityName: "Metadata", into: self.container.viewContext) as! Metadata)
                }
                
                metadata!.photosLastSynced = Date()
                try self.container.viewContext.save()
                
                print("Photos Metadata updated in Core Data.")
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    
    @objc
    private func on(_ notification: Notification) {
        let orientation = UIApplication.shared.windows.first?.windowScene!.interfaceOrientation
        
        switch orientation {
            case .landscapeLeft, .landscapeRight:
                break
                // TODO: Change locations of items
                //print("Landscape")
            default:
                break
                // TODO: Change locations of items
                //print("Portrait")
        }
    }
    
    private func setupConstraints() {
        
        self.graphView.translatesAutoresizingMaskIntoConstraints = false
        graphConstraints.removeAll()
        
        let topConstraint = NSLayoutConstraint(item: self.graphView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.graphView!, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.graphView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.graphView!, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
        
        graphConstraints.append(topConstraint)
        graphConstraints.append(bottomConstraint)
        graphConstraints.append(leftConstraint)
        graphConstraints.append(rightConstraint)
                
        self.view.addConstraints(graphConstraints)
    }
}
