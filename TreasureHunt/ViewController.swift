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
  
    var treasures: [Treasure] = []
    
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
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
    }
    
}


































