//
//  RenderGLKView.swift
//  OpenGLES_Ch5_1
//
//  Created by jiao qing on 11/2/16.
//
//

import UIKit
import GLKit

class RenderGLKView: GLKView {
    static let sharedInstance = RenderGLKView(frame: CGRectMake(0, 0, 400, 400))
    
    let baseEffect = GLKBaseEffect()
    var vertexPositionBuffer : AGLKVertexAttribArrayBuffer!
    var vertexTextureCoordBuffer : AGLKVertexAttribArrayBuffer!
    
    var vertexCount : Int32 = 0
    var posVertices = [GLfloat]()
    var texVertices = [GLfloat]()
    var framebufferWidth = GLint(0)
    var framebufferHeight = GLint(0)
    
    var reshapedImage : UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.enableSetNeedsDisplay = true
        
        let glview = self as GLKView
        if UIDevice.isIPhone5() || UIDevice.isIPhone4() || UIDevice.isIPad() || UIDevice.isIPod() {
            glview.context = AGLKContext(API: .OpenGLES2)
        }else{
            glview.context = AGLKContext(API: .OpenGLES3)
        }
        //Makes the specified context the current rendering context for the calling thread.
        AGLKContext.setCurrentContext(glview.context)
        
        self.opaque = false
        
        glClearColor(0, 0, 0, 0)
        glEnable(UInt32(GL_BLEND))
        glBlendFunc(UInt32(GL_SRC_ALPHA), UInt32(GL_ONE_MINUS_SRC_ALPHA))
        
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        //GL_TEXTURE_MIN_FILTER在图像绘制时小于贴图的原始尺寸时采用
        //GL_TEXTURE_MAG_FILTER在图像绘制时大于贴图的原始尺寸时采用
        
        fakePointIfNull()
        vertexCount = Int32(min(posVertices.count / 2, texVertices.count / 2))
        vertexPositionBuffer = AGLKVertexAttribArrayBuffer(attribStride: 2 * sizeof(GLfloat), numberOfVertices: vertexCount, bytes: posVertices, usage: UInt32( GL_DYNAMIC_DRAW))
        vertexTextureCoordBuffer = AGLKVertexAttribArrayBuffer(attribStride: 2 * sizeof(GLfloat), numberOfVertices: vertexCount, bytes: texVertices, usage: UInt32(GL_DYNAMIC_DRAW))
        
        baseEffect.texture2d0.target = .Target2D
    }
    
    func fakePointIfNull(){
        if posVertices.count == 0 {
            posVertices = [1, 1]
        }
        if texVertices.count == 0 {
            texVertices = [1, 1]
        }
    }
    
    func reinitBuffer(){
        fakePointIfNull()
        vertexCount = Int32(min(posVertices.count / 2, texVertices.count / 2))
        
        vertexTextureCoordBuffer.reinitWithAttribStride(2 * sizeof(GLfloat), numberOfVertices: vertexCount, bytes: texVertices)
        vertexPositionBuffer.reinitWithAttribStride(2 * sizeof(GLfloat), numberOfVertices: vertexCount, bytes: posVertices)
    }
    
    func reshapeImageWith(texImage : UIImage, imageRect : CGRect, textureData : String?, positionData : String?) -> Bool{
        if textureData == nil || positionData == nil {
            return false
        }
        parseTextureData(textureData!)
        parsePositionData(positionData!)
        if posVertices.count == 0 || texVertices.count == 0 {
            return false
        }
        reinitBuffer()
        
        let newSize = CGSizeMake(kDJModelViewWidth3x, kDJModelViewHeight3x)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        texImage.drawInRect(imageRect)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let resultImageRef = resultImage!.CGImage {
            do {
                let textureInfo = try GLKTextureLoader.textureWithCGImage(resultImageRef, options: [GLKTextureLoaderOriginBottomLeft : true])
                var name = baseEffect.texture2d0.name
                glDeleteTextures(1, &name);
                
                baseEffect.texture2d0.name = textureInfo.name
            }catch{}
        }
        setNeedsDisplay()
        
        reshapedImage = snapshot;
        return true
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let glview = self as GLKView
        AGLKContext.setCurrentContext(glview.context)
        
        glClear(UInt32(GL_COLOR_BUFFER_BIT) | UInt32(GL_DEPTH_BUFFER_BIT))
        baseEffect.prepareToDraw()
        vertexPositionBuffer.prepareToDrawWithAttrib(UInt32(GLKVertexAttrib.Position.rawValue), numberOfCoordinates: 2, attribOffset: 0, shouldEnable: true)
        vertexTextureCoordBuffer.prepareToDrawWithAttrib(UInt32(GLKVertexAttrib.TexCoord0.rawValue), numberOfCoordinates: 2, attribOffset: 0, shouldEnable: true)
        AGLKVertexAttribArrayBuffer.drawPreparedArraysWithMode(UInt32(GL_TRIANGLES), startVertexIndex:0, numberOfVertices: vertexCount)
        
        //If enabled, the values in the generic vertex attribute array will be accessed and used for rendering when calls are made to vertex array commands such as glDrawArrays or glDrawElements.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func parseTextureData(fileData : String){
        texVertices = [GLfloat]()
        let allLinedStrings = fileData.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        for oneLine in allLinedStrings {
            let singleStrs = oneLine.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " "))
            if singleStrs.count < 6 {
                return
            }
            var lineCnt = 0
            for str in singleStrs{
                if lineCnt > 5 {
                    break
                }
                var rawF = GLfloat(str)! / 10000
                if rawF < 0 {
                    rawF = 0
                }
                if lineCnt % 2 != 0 {
                    rawF = 1 - rawF
                }
                texVertices.append(rawF)
                lineCnt += 1
            }
        }
        
    }
    
    func parsePositionData(fileData : String){
        posVertices = [GLfloat]()
        
        let allLinedStrings = fileData.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        for oneLine in allLinedStrings {
            let singleStrs = oneLine.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " "))
            if singleStrs.count < 6 {
                return
            }
            var lineCnt = 0
            for str in singleStrs{
                if lineCnt > 5 {
                    break
                }
                
                var rawF : GLfloat = GLfloat(str)!
                if lineCnt % 2 == 0 {
                    rawF = ((rawF - Float(kDJModelViewWidth3x) / 2) / (Float(kDJModelViewWidth3x) / 2))
                }else{
                    rawF = -(rawF - Float(kDJModelViewHeight3x / 2)) / (Float(kDJModelViewHeight3x) / 2)
                }
                posVertices.append(rawF)
                lineCnt += 1
            }
        }
    }
    
    deinit{
        AGLKContext.setCurrentContext(nil)
    }
}
