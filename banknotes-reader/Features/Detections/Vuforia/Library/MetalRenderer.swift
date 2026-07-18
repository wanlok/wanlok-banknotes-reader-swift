/*===============================================================================
Copyright (c) 2023 PTC Inc. and/or Its Subsidiary Companies. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other
countries.
===============================================================================*/

import UIKit
import MetalKit


/// Class to encapsulate Metal rendering for the sample
class MetalRenderer {

    private var mMetalDevice:MTLDevice

    private var mVideoBackgroundPipelineState:MTLRenderPipelineState!
    private var mUniformColorShaderPipelineState:MTLRenderPipelineState!

    private var mDefaultSamplerState:MTLSamplerState?

    private var mVideoBackgroundTexture:MTLTexture!
    private var mVideoBackgroundWidth:Int32 = 0
    private var mVideoBackgroundHeight:Int32 = 0
    private var mVideoBackgroundVertices:MTLBuffer!
    private var mVideoBackgroundIndices:MTLBuffer!
    private var mVideoBackgroundTextureCoordinates:MTLBuffer!

    private var mSquareVertices:MTLBuffer!
    private var mSquareIndices:MTLBuffer!
    private var mSquareWireframeIndices:MTLBuffer!

    // Buffers for augmentation model-view-projection matrices
    private var mAugmentationMVP:MTLBuffer!
    private var mAugmentationScaledMVP:MTLBuffer!

    private let colorGreen = vector_float4(Float(0), Float(1), Float(0), Float(1))


    /// Initialize the renderer ready for use
    init(metalDevice: MTLDevice, layer: CAMetalLayer, library: MTLLibrary?, depthAttachmentPixelFormat: MTLPixelFormat) {
        mMetalDevice = metalDevice
        
        let stateDescriptor = MTLRenderPipelineDescriptor()

        //
        // Video background
        //
        
        stateDescriptor.vertexFunction = library?.makeFunction(name: "texturedVertex")
        stateDescriptor.fragmentFunction = library?.makeFunction(name: "texturedFragment")
        stateDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        stateDescriptor.depthAttachmentPixelFormat = depthAttachmentPixelFormat
        
        // And create the pipeline state with the descriptor
        do {
            try self.mVideoBackgroundPipelineState = metalDevice.makeRenderPipelineState(descriptor: stateDescriptor)
        } catch {
            print("Failed to create video background render pipeline state:",error)
        }
        
        //
        // Augmentations
        //

        // Create pipeline for transparent object overlays
        stateDescriptor.vertexFunction = library?.makeFunction(name: "uniformColorVertex")
        stateDescriptor.fragmentFunction = library?.makeFunction(name: "uniformColorFragment")
        stateDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat;
        stateDescriptor.colorAttachments[0].isBlendingEnabled = true
        stateDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperation.add
        stateDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperation.add
        stateDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactor.sourceAlpha
        stateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactor.sourceAlpha
        stateDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        stateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        stateDescriptor.depthAttachmentPixelFormat = depthAttachmentPixelFormat
        do {
            try self.mUniformColorShaderPipelineState = metalDevice.makeRenderPipelineState(descriptor: stateDescriptor)
        } catch {
            print("Failed to create augmentation render pipeline state:",error)
            return
        }

        mDefaultSamplerState = MetalRenderer.defaultSampler(device: metalDevice)

        // Allocate space for rendering data for Video background
        mVideoBackgroundVertices = mMetalDevice.makeBuffer(length: MemoryLayout<Float>.size * 3 * 4, options: [])
        mVideoBackgroundTextureCoordinates = mMetalDevice.makeBuffer(length: MemoryLayout<Float>.size * 2 * 4, options: [])
        mVideoBackgroundIndices = mMetalDevice.makeBuffer(length: MemoryLayout<UInt32>.size * 6, options: [])

        // Load rendering data for square
        mSquareVertices = metalDevice.makeBuffer(bytes: Models.squareVertices, length: MemoryLayout<Float>.size * 3 * Int(Models.NUM_SQUARE_VERTEX), options: [])
        mSquareIndices = metalDevice.makeBuffer(bytes: Models.squareIndices, length: MemoryLayout<UInt16>.size * Int(Models.NUM_SQUARE_INDEX), options: [])
        mSquareWireframeIndices
            = metalDevice.makeBuffer(bytes: Models.squareWireframeIndices, length: MemoryLayout<UInt16>.size * Int(Models.NUM_SQUARE_WIREFRAME_INDEX), options: [])

        mAugmentationMVP = mMetalDevice.makeBuffer(length: MemoryLayout<Float>.size * 16)
        mAugmentationScaledMVP = mMetalDevice.makeBuffer(length: MemoryLayout<Float>.size * 16)
    }

    func configureVideoBackgroundTexture() {
        // Create the video background texture by querying the video background information from Vuforia. This should be called
        // only after Vuforia has been started successfully and the render view has been configured with vuRenderControllerSetRenderViewConfig.
        var textureSize: VuVector2I = VuVector2I(data: (0, 0))
        if (!getVideoBackgroundTextureSize(&textureSize)) {
            NSLog("Error: Failed to retrieve video-background texture size")
            return
        }

        if (textureSize.data.0 != mVideoBackgroundWidth || textureSize.data.1 != mVideoBackgroundHeight) {
            let videoBackgroundTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.bgra8Unorm,
                                                                                            width: Int(textureSize.data.0), height: Int(textureSize.data.1),
                                                                                            mipmapped: false)
            videoBackgroundTextureDescriptor.usage = [.renderTarget, .shaderRead]

            mVideoBackgroundTexture = mMetalDevice.makeTexture(descriptor: videoBackgroundTextureDescriptor)

            mVideoBackgroundWidth = textureSize.data.0
            mVideoBackgroundHeight = textureSize.data.1
        }
    }

    func getVideoBackgroundTexture() -> MTLTexture! {
      return mVideoBackgroundTexture;
    }

    /// Render the video background
    func renderVideoBackground(encoder: MTLRenderCommandEncoder?, projectionMatrix: MTLBuffer, mesh: VuMesh) {

        // Copy mesh data into metal buffers
        mVideoBackgroundVertices.contents().copyMemory(from: mesh.pos, byteCount: MemoryLayout<Float>.size * Int(mesh.numVertices) * 3)
        mVideoBackgroundTextureCoordinates.contents().copyMemory(from: mesh.tex, byteCount: MemoryLayout<Float>.size * Int(mesh.numVertices) * 2)
        mVideoBackgroundIndices.contents().copyMemory(from: mesh.faceIndices, byteCount: MemoryLayout<CUnsignedInt>.size * Int(mesh.numFaces) * 3)
        
        // Set the render pipeline state
        encoder?.setRenderPipelineState(mVideoBackgroundPipelineState)
        
        // Set the texture coordinate buffer
        encoder?.setVertexBuffer(mVideoBackgroundTextureCoordinates, offset: 0, index: 2)
        
        // Set the vertex buffer
        encoder?.setVertexBuffer(mVideoBackgroundVertices, offset: 0, index: 0)
        
        // Set the projection matrix
        encoder?.setVertexBuffer(projectionMatrix, offset: 0, index: 1)
       
        encoder?.setFragmentSamplerState(mDefaultSamplerState, index: 0)

        // Draw the geometry
        encoder?.drawIndexedPrimitives(type: MTLPrimitiveType.triangle,indexCount: 6, indexType: .uint32, indexBuffer: mVideoBackgroundIndices, indexBufferOffset: 0)
    }


    /// Render a bounding box augmentation on an Image Target
    func renderImageTarget(encoder: MTLRenderCommandEncoder?,
                           projectionMatrix: matrix_float4x4,
                           modelViewMatrix: matrix_float4x4, scaledModelViewMatrix: matrix_float4x4) {

        var modelViewProjection = projectionMatrix * modelViewMatrix
        mAugmentationMVP.contents().copyMemory(from: &modelViewProjection.columns, byteCount: MemoryLayout<Float>.size * 16)
        var scaledModelViewProjectionMatrix = projectionMatrix * scaledModelViewMatrix
        mAugmentationScaledMVP.contents().copyMemory(from: &scaledModelViewProjectionMatrix.columns, byteCount: MemoryLayout<Float>.size * 16)

        // Draw translucent bounding box overlay
        encoder?.setRenderPipelineState(mUniformColorShaderPipelineState)

        encoder?.setVertexBuffer(mSquareVertices, offset: 0, index: 0)
        encoder?.setVertexBuffer(mAugmentationScaledMVP, offset: 0, index: 1)

        var color = colorGreen
        // Draw translucent square
        color[3] = 0.2
        encoder?.setFragmentBytes(&color, length: MemoryLayout.size(ofValue: color), index: 0)
        encoder?.drawIndexedPrimitives(type: .triangle, indexCount: Int(Models.NUM_SQUARE_INDEX), indexType: .uint16, indexBuffer: mSquareIndices, indexBufferOffset: 0)
        // Draw solid wireframe
        color[3] = 1.0
        encoder?.setFragmentBytes(&color, length: MemoryLayout.size(ofValue: color), index: 0)
        encoder?.drawIndexedPrimitives(type: .line, indexCount: Int(Models.NUM_SQUARE_WIREFRAME_INDEX), indexType: .uint16, indexBuffer: mSquareWireframeIndices, indexBufferOffset: 0)
    }


    class func defaultSampler(device: MTLDevice) -> MTLSamplerState? {
        let sampler = MTLSamplerDescriptor()
        sampler.minFilter             = MTLSamplerMinMagFilter.linear
        sampler.magFilter             = MTLSamplerMinMagFilter.linear
        sampler.mipFilter             = MTLSamplerMipFilter.linear
        sampler.maxAnisotropy         = 1
        sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge
        sampler.normalizedCoordinates = true
        sampler.lodMinClamp           = 0
        sampler.lodMaxClamp           = .greatestFiniteMagnitude
        return device.makeSamplerState(descriptor: sampler)
    }
}
