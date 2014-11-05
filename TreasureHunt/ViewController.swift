/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import MapKit

class ViewController: UIViewController {
  
  @IBOutlet var mapView : MKMapView!
  
    private var treasures: [Treasure] = []
    
    // An array of GeoLocation structs so that the app can keep track of which treasures the user has found and in what order.
    private var foundLocations: [GeoLocation] = []
    
    // An implicitly unwrapped optional. This is so it can be nil if necessary, such as before the user has found any treasures.
    private var polyline: MKPolyline!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.treasures = [
                HistoryTreasure(what: "Googles's first office", year: 1999, latitude: 37.44451, longitude: -122.163369),
                HistoryTreasure(what: "Facebook's first office", year: 2005, latitude: 37.444268, longitude: -122.163271),
                FactTreasure(what: "Stanford University", fact: "Founded in 1885 by Leland Stanford.", latitude: 37.427474, longitude: -122.169719),
                FactTreasure(what: "Moscone West", fact: "Host to WWDC since 2003.", latitude: 37.783083, longitude: -122.404025),
                FactTreasure(what: "Computer History Museum", fact: "Home to a working Babbage Difference Engine.", latitude: 37.414371, longitude: -122.076817),
                HQTreasure(company: "Apple", latitude: 37.331741, longitude: -122.030333),
                HQTreasure(company: "Facebook", latitude: 37.485955, longitude: -122.148555),
                HQTreasure(company: "Google", latitude: 37.422, longitude: -122.084)
        ]
        
        self.mapView.delegate = self
        self.mapView.addAnnotations(self.treasures)
        
        /* Zoom map to the region enclosing all of the treasures */
        
        //  This algorithm works by using the reduce function of an array. To reduce an array means to run a function over the array that combines each element into a single, final return value. At each step, the next element from the array is passed along with the current value for the reduce. The return value from the function then becomes the current value for the next reduce. Of course, you need to seed the reduce with an initial value. In this case, your seed is MKMapRectNull.
        
        let rectToDisplay = self.treasures.reduce(MKMapRectNull){
            (mapRect: MKMapRect, treasure: Treasure) -> MKMapRect in
                //  At each step in the reduce, you calculate a map rectangle enclosing just the single treasure.
                let treasurePointRect = MKMapRect(origin: treasure.location.mapPoint, size: MKMapSize(width: 0, height: 0))
            
            //  You then return a rectangle made up of the union of the current overall rectangle and the single treasure rectangle.
            return MKMapRectUnion(mapRect, treasurePointRect)
        }
        
        //  When the reduce finishes, the map rectangle will be the union of all the map rectangles enclosing each and every treasure point.
        
        
        //  Set the map view’s visible map rectangle to the calculated rectangle. You use some edge padding to ensure that no pins end up underneath the navigation bar or too close to the edge of the screen.
        self.mapView.setVisibleMapRect(rectToDisplay, edgePadding: UIEdgeInsetsMake(174,10,10,10), animated: false)
    }
    
    private func markTreasureAsFound(treasure: Treasure) {
        
        // Check if the location already exists in the found locations array using the global find() function, which takes a collection and an element to find in the collection. The function returns either the index into the collection where the element is found, or nil.
        if let index = find(self.foundLocations, treasure.location) {
            
            //  If the location does already exist in the found locations array, then display an alert showing at which step the user found the treasure.
            let alert = UIAlertController(
                title: "Oops!",
                message: "You've already found this treasure (at step \(index + 1))! Try again!",
                preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            // If the location doesn’t exist in the found locations array, then you add it to the array.
            self.foundLocations.append(treasure.location)
            
            
            //  If a polyline already exists, remove it from the map. If we didn’t do this, then overlays would pile up on the map each time you added a new one.
            if self.polyline != nil {
                self.mapView.removeOverlay(self.polyline)
            }
            
            //  C     reate a new MKPolyline and add it to the map view. Take note of the use of the map function on the array. This function takes each element in the array, converts it using the supplied closure and creates a new array from the results. The code above uses the short syntax for closures where the signature is completely left off because Swift can infer it from the map function’s signature. Each element in the array is passed into the closure as the $0 variable.
            var coordinates = self.foundLocations.map { $0.coordinate }
            self.polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            self.mapView.addOverlay(self.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!
    {
    //  It implements mapView:viewForAnnotation. Notice in the method signature that the annotation you pass in is of type MKAnnotation!. This means it’s an optional, so the value could be nil. But it’s an implicitly unwrapped optional, meaning you can use it without checking for nil. But if you don’t check for nil and it happens to be nil, then your app will crash at runtime. Many Objective-C APIs are wrapped like this because there are no optionals in Objective-C.
        
        if let treasure = annotation as? Treasure {
        //  Because the annotation could be nil or even something other than a Treasure instance, you need to cast it to a Treasure. You do this using the inline downcasting syntax. You perform the downcast using as? and immediately assign it to the local variable treasure. Only if the downcast succeeds will the if statement pass. This is another example of Swift’s concise syntax. A downcast and if statement all in one line! It really does help you play safe with types.
            
            
            //  If the annotation is a treasure, then dequeue a view from the map for the reuse identifier pin. This simply means that if the program has created a pin before, but it’s no longer onscreen because the user has moved the map away, then the program will reuse the view rather than create a new one. If you’re familiar with UITableViews, you’ve probably used the same concept when you dequeue and reuse a UITableViewCell. Notice the use of downcast again, this time in the non- optional form as, because you know that all “pin” annotation views will be MKPinAnnotationView instances.
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as MKPinAnnotationView!
            if view == nil {
            //  If no view could be dequeued, then create a new one and set it up as appropriate.
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                view.canShowCallout = true
                view.animatesDrop = false
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIView

            }else{
                view.annotation = annotation
                // if a view was dequeued, then change its annotation.
            }
            view.pinColor = treasure.pinColor()
            
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!)
    {
        if let treasure = view.annotation as? Treasure {
            if let alertable = treasure as? Alertable {
                let alert = alertable.alert()
                alert.addAction(
                    UIAlertAction(title: "OK",
                                style: UIAlertActionStyle.Default,
                                handler: nil))

                alert.addAction(UIAlertAction(
                    title: "Found",
                    style: UIAlertActionStyle.Default) { action in
                    self.markTreasureAsFound(treasure)
                    })
                
                alert.addAction(UIAlertAction(
                    title: "Find Nearest", style: UIAlertActionStyle.Default){ action in
                            // Create a local variable to hold a copy of the original array.
                            var sortedTreasures = self.treasures //copy
                        
                        
                            // The sort method takes a single parameter—a closure that takes two objects—and returns a Boolean indicating whether object one is ordered before object two.
                            sortedTreasures.sort {
                                
                                // Calculate the distance between the current treasure and each of the treasures you’re sorting. Notice the use of $0 and $1. This is shorthand syntax for the first and second parameters passed into a closure.
                                let distanceA = treasure.location.distanceBetween($0.location)
                                let distanceB = treasure.location.distanceBetween($1.location)
                                
                                // You check the first distance against the second distance and return true if it’s smaller. In this way, you sort the array of treasures in order of shortest to longest distance from the current treasure.
                                return distanceA < distanceB
                            }
                            // Deselect the current treasure and select the new treasure. If you’re wondering why the code selects the second element in the sorted array, it’s because the first element will always be the current treasure itself
                            mapView.deselectAnnotation(treasure, animated: true)
                            mapView.selectAnnotation(sortedTreasures[1], animated: true)
                    })

                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    
    // This method tells the map view how to render a given overlay. The overlay you’re using is MKPolyline, which has an associated renderer called MKPolylineRenderer. Notice the use of optional checking again to downcast the overlay type.
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polylineOverlay = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polylineOverlay)
            renderer.strokeColor = UIColor.blueColor()
            return renderer
        }
        return nil
    }
    
}


































