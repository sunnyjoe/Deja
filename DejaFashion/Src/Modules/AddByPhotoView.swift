//
//  AddByPhotoView.swift
//  DejaFashion
//
//  Created by jiao qing on 1/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

protocol AddByPhotoViewDelegate : NSObjectProtocol{
    func addByPhotoViewDidSelectTemplateIndex(addByPhotoView: AddByPhotoView, index : Int)
}


class AddByPhotoView: CameraView, TemplateSelectionViewDelegate{
    weak var delegate : AddByPhotoViewDelegate?
    
    var templateId : String = ""
    private let tempArray = DJSelectionModels.getTemplatesInfo()
    
    private var bottomView = TemplateSelectionView()
    override init(frame: CGRect) {
        super.init(frame: frame)
 
        let theTemp = tempArray[0] as! TemplateInfo
        templateId = theTemp.id
        mask = theTemp.template
        cropMask = theTemp.mask
        
        var templateInfos = [String]()
        var templateIcons = [UIImage]()
        for tmp in tempArray{
            templateInfos.append(tmp.info)
            templateIcons.append(tmp.icon)
        }
        bottomView.templateIcon = templateIcons
        bottomView.templateInfo = templateInfos
        bottomView.delegate = self
        addSubview(bottomView)
        
        setSelectedMaskRelated(0)
    }
    
    class func formatPoints(array : [Int]) -> [CGPoint] {
        let scale = UIScreen.mainScreen().bounds.size.width / 375
        var index = 0
        var points = [CGPoint]()
        while index + 1 < array.count {
            let x = CGFloat(array[index]) * scale / 2
            let y = CGFloat(array[index + 1]) * scale / 2 - 64
            points.append(CGPointMake(x, y))
            index += 2
        }
        return points
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var offSet : CGFloat = 0
        if self.frame.size.width <= 320 {
            offSet = 40
        }else if self.frame.size.width <= 375{
            offSet = 35
        }else{
            offSet = 25
        }
        if previewLayer == nil{
            return
        }
        previewLayer.frame = CGRectMake(0, frame.size.height - UIScreen.mainScreen().bounds.height - offSet, frame.size.width, UIScreen.mainScreen().bounds.height - offSet)
        maskImageView.frame = previewLayer.frame
        
        bottomView.frame = CGRectMake(0, frame.size.height - 211, frame.size.width, 98)
    }
    
    func setSelectedMaskRelated(index : Int){
        if index < 0 || index > tempArray.count - 1{
            return
        }
        let theTemp = tempArray[index] as! TemplateInfo
        mask = theTemp.template
        cropMask = theTemp.mask
        templateId = theTemp.id
        bottomView.selectIndex(index)
    }
    
    func setSelectedMaskWithId(id : String?){
        var index = 0
        for tmp in tempArray{
            let theTmp = tmp as! TemplateInfo
            if theTmp.id == id{
                setSelectedMaskRelated(index)
                break
            }
            index += 1
        }
    }
    
    func getTemplateId() -> String{
        return templateId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showScanning(show: Bool) {
      
        bottomView.userInteractionEnabled = !show
    }
    
    func templateSelectionViewDidSelectIndex(templateSelectionView: TemplateSelectionView, index: Int) {
        self.delegate?.addByPhotoViewDidSelectTemplateIndex(self, index: index)
    }
}
