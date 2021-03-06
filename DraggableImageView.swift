//
//  DraggableImageView.swift
//  Helper UIImageView class for draggable UIImageViews
//  Possible extensions: Rotate, Resize
//
//  Created by Jingrong (: on 29/3/15.
//

import UIKit

class DraggableImageView : UIImageView
{
    var dragStartPositionRelativeToCenter : CGPoint?
    
    weak var parentViewController = UIViewController()
    var lastRotation = CGFloat()
    var labelIdentifier = Int()
    var roomLabel = Int()
    var graphName = String()
    
    // Need to store total rotation for saving
    var totalRotation: CGFloat = 0.0
    
    // Screen size
    // Assume ipad screen size.
    let screenWidth: CGFloat = 1024.0
    let screenHeight: CGFloat = 768.0
    
    override init(image: UIImage) {
        super.init(image: image)
        
        self.userInteractionEnabled = true
        self.multipleTouchEnabled = true
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handlePan:"))
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "handlePinch:"))
        //addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: "handleRotate:"))
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Allow simultaneous
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
    func handlePan(nizer: UIPanGestureRecognizer!) {
        if nizer.state == UIGestureRecognizerState.Began {
            let locationInView = nizer.locationInView(superview)
            // To prevent out of bounds
            dragStartPositionRelativeToCenter = CGPoint(x: locationInView.x - center.x, y: locationInView.y - center.y)
            
            layer.shadowOffset = CGSize(width: 0, height: 20)
            layer.shadowOpacity = 0.3
            layer.shadowRadius = 6
            
            return
        }
        
        if nizer.state == UIGestureRecognizerState.Ended {
            dragStartPositionRelativeToCenter = nil
            
            layer.shadowOffset = CGSize(width: 0, height: 3)
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 2
            
            return
        }
        
        let locationInView = nizer.locationInView(superview)
        var xCenter = locationInView.x - self.dragStartPositionRelativeToCenter!.x
        var yCenter = locationInView.y - self.dragStartPositionRelativeToCenter!.y
        
        // Check for out of screen boundary
        if  (self.isWithinBounds()){
            UIView.animateWithDuration(0.1) {
                self.center = CGPoint(x: xCenter, y: yCenter)
            }
        }
        UIView.animateWithDuration(0.1) {
            if  (self.isWithinBounds()){
                self.center = CGPoint(x: xCenter, y: yCenter)
            }
            // Call method again to realign for corners
            self.isWithinBounds()
        }
    }
    
    func handlePinch(nizer: UIPinchGestureRecognizer!) {
        if (nizer.state == UIGestureRecognizerState.Began || nizer.state == UIGestureRecognizerState.Changed) {
            // Scale up
            if (nizer.scale > 1.0){
                if (isWithinBounds()){
                    self.transform = CGAffineTransformScale(self.transform, nizer.scale, nizer.scale)
                    nizer.scale = 1.0
                }
            } else {
                // Scale down
                self.transform = CGAffineTransformScale(self.transform, nizer.scale, nizer.scale)
                nizer.scale = 1.0
            }
            // Call method again to realign for corners
            self.isWithinBounds()
        }
        
    }
    
    /*
    func handleRotate(nizer: UIRotationGestureRecognizer!) {
        self.transform = CGAffineTransformRotate(nizer.view!.transform, nizer.rotation)
        totalRotation = totalRotation + nizer.rotation
        nizer.rotation = 0.0
        mementoManager.setOverlayFrame(graphName, roomLabel: roomLabel, overlayLabel: self.labelIdentifier, newFrame: self.frame)
        //println(totalRotation)
        
        println(self.frame)
        isWithinBounds()
    }

    */
    /*
    func rotatedView(sender:UIRotationGestureRecognizer){
        var lastRotation = CGFloat()
        if(sender.state == UIGestureRecognizerState.Ended){
            lastRotation = 0.0;
        }
        var rotation = 0.0 - (lastRotation - sender.rotation)
        var point = rotateRec.locationInView(self)
        var currentTrans = sender.view!.transform
        var newTrans = CGAffineTransformRotate(currentTrans, rotation)
        sender.view!.transform = newTrans
        lastRotation = sender.rotation
    }
    */
    
    // Helper function to check if this view is still within the 1024*768 boundary
    // Aids in slight offsetting back to within bounds
    private func isWithinBounds() -> Bool {
        let minX = CGRectGetMinX(self.frame)
        let maxX = CGRectGetMaxX(self.frame)
        let minY = CGRectGetMinY(self.frame)
        let maxY = CGRectGetMaxY(self.frame)
        
        if ( minX < 0) {
            self.center.x = self.frame.width/2.0 + 2.0
            return false
        } else if ( maxX >= screenWidth) {
            self.center.x = screenWidth - self.frame.width/2.0 - 1.0
            return false
        } else if ( maxY >= screenHeight) {
            self.center.y = screenHeight - self.frame.height/2.0 - 1.0
            return false
        } else if ( minY < 0){
            self.center.y = self.frame.height/2.0 + 2.0
            return false
        } else {
            return true
        }
    }

    
}