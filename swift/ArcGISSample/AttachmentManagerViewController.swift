//
//  AttachmentManagerViewController.swift
//  ArcGISSample
//
//  Created by esrij on 2015/07/27.
//  Copyright (c) 2015年 esrij. All rights reserved.
//

import UIKit
import ArcGIS

class AttachmentManagerViewController: UIViewController, AGSAttachmentManagerDelegate, AGSFeatureLayerEditingDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    var agsMapView: AGSMapView!
    var agsFeatureLayer: AGSFeatureLayer!
    var agsAttachmentMgr: AGSAttachmentManager!
    var image: UIImage!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.agsMapView = AGSMapView(frame: self.view.bounds)
        self.view.addSubview(self.agsMapView)
        
        //タイルマップサービスレイヤーの追加
        let url = NSURL(string: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL:url)
        self.agsMapView.addMapLayer(tiledLyr, withName:"Tiled Layer")

        //写真を添付する編集用フィーチャレイヤーの追加
        //let featureLayerUrl = NSURL(string: "http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/SanFrancisco/311Incidents/FeatureServer/0")
        let featureLayerUrl = NSURL(string: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/CommercialDamageAssessment/FeatureServer/0")
        self.agsFeatureLayer = AGSFeatureLayer(URL: featureLayerUrl, mode: .OnDemand)
        self.agsMapView.addMapLayer(agsFeatureLayer, withName:"Feature Layer")
        
        
        let buttonAttachment = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addAttachment:")
        var buttons = ([buttonAttachment])
        var toolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44))
        toolbar.setItems(buttons as [AnyObject], animated: true)
        self.view .addSubview(toolbar)
        
        //マップの中心にカーソルを表示
        self.drawCenterSign()
        
    }
    
    
    func drawCenterSign() {
        
        UIGraphicsBeginImageContext(CGSizeMake(20, 20))
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 1.0)
        CGContextMoveToPoint(context, 10, 0)
        CGContextAddLineToPoint(context, 10, 20)
        CGContextMoveToPoint(context, 0, 10)
        CGContextAddLineToPoint(context, 20, 10)
        CGContextStrokePath(context)
        
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        
        CGContextSetLineWidth(context, 1.0)
        CGContextMoveToPoint(context, 10, 9)
        CGContextAddLineToPoint(context, 10, 11)
        CGContextMoveToPoint(context, 9, 10)
        CGContextAddLineToPoint(context, 11, 9)
        CGContextStrokePath(context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let caLayer = CALayer()
        caLayer.frame = CGRectMake(self.agsMapView.frame.size.width / 2 - 10, self.agsMapView.frame.size.height / 2 - 10, 20, 20)
        caLayer.contents = image.CGImage
        self.view.layer.addSublayer(caLayer)
        
    }
    
    
    func addAttachment (sender: UIBarButtonItem) {
        
        //添付する写真をフォトライブリから選択
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .PhotoLibrary
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        
    }

    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {

        
        self.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        //ジオメトリと属性を指定してフィーチャを新規に作成する
        let agsPoint = self.agsMapView.visibleAreaEnvelope.center
        let agsFeature = AGSGraphic()
        agsFeature.geometry = agsPoint
        //agsFeature.setAttribute("Tree Maintenance or Damage", forKey: "req_type")
        agsFeature.setAttribute("Minor", forKey: "typdamage")
        
        //フィーチャをフィーチャレイヤーに更新
        self.agsFeatureLayer.applyEditsWithFeaturesToAdd(NSArray(array: [agsFeature]) as [AnyObject], toUpdate: nil, toDelete: nil)
        self.agsFeatureLayer.editingDelegate = self
        
    }
    
    
    func featureLayer(featureLayer: AGSFeatureLayer!, operation op: NSOperation!, didFailFeatureEditsWithError error: NSError!) {
        
        println("Error:\(error)")

    }
    
    
    func featureLayer(featureLayer: AGSFeatureLayer!, operation op: NSOperation!, didFeatureEditsWithResults editResults: AGSFeatureLayerEditResults!) {
        
        //新規に作成したフィーチャに対してAGSAttachmentManagerを作成
        let results = editResults.addResults[0] as! AGSEditResult
        let agsFeature = self.agsFeatureLayer.lookupFeatureWithObjectId(results.objectId)
        self.agsAttachmentMgr = self.agsFeatureLayer.attachmentManagerForFeature(agsFeature)
        self.agsAttachmentMgr.delegate = self
        
        //フォトライブリから選択した写真に名前を指定してフィーチャに添付
        self.agsAttachmentMgr.addAttachmentAsJpgWithImage(self.image, name: "temp.jpg")
        
        if(self.agsAttachmentMgr .hasLocalEdits()){
            self.agsAttachmentMgr.postLocalEditsToServer()
        }
        
    }
    
    
    func attachmentManager(attachmentManager: AGSAttachmentManager!, didPostLocalEditsToServer attachmentsPosted: [AnyObject]!) {
        
        var success = true
        
        for attachment in attachmentsPosted as! [AGSAttachment] {
            
            //写真の添付に失敗
            if attachment.networkError != nil || attachment.editResultError != nil {
            
                success = false
                
                if attachment.networkError != nil {
                    let reason = attachment.networkError.localizedDescription
                    println("Error:\(reason)")

                } else if attachment.editResultError != nil {
                    let reason = attachment.editResultError.errorDescription
                    println("Error:\(reason)")
                }

            }
            
            //写真の添付に成功
            if (success){
                println("didPostLocalEditsToServer")
            }
        

        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}