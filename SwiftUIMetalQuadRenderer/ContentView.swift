//
//  ContentView.swift
//  SwiftUIMetalQuadRenderer
//
//  Created by Yasuo Hasegawa on 2024/12/19.
//

import SwiftUI
import MetalKit

struct Vertex {
    var position: simd_float2
    var uv: simd_float2
}

struct MetalView: UIViewRepresentable {
    class Coordinator: NSObject, MTKViewDelegate {
        let vertices: [Vertex] = [
            Vertex(position: simd_float2(-1.0, -1.0), uv: simd_float2(0.0, 1.0)), // Bottom left
            Vertex(position: simd_float2( 1.0, -1.0), uv: simd_float2(1.0, 1.0)), // Bottom right
            Vertex(position: simd_float2( 1.0,  1.0), uv: simd_float2(1.0, 0.0)), // Top right
            
            Vertex(position: simd_float2( 1.0,  1.0), uv: simd_float2(1.0, 0.0)), // Top right
            Vertex(position: simd_float2(-1.0,  1.0), uv: simd_float2(0.0, 0.0)), // Top left
            Vertex(position: simd_float2(-1.0, -1.0), uv: simd_float2(0.0, 1.0))  // Bottom left
        ]
        
        var device: MTLDevice
        var commandQueue: MTLCommandQueue
        var pipelineState: MTLRenderPipelineState
        
        var vertexBuffer: MTLBuffer?
        var resolutionBuffer: MTLBuffer?
        var timeBuffer: MTLBuffer?
        
        var viewWidth: Float = 0.0
        var viewHeight: Float = 0.0
        var startDate:Date?
        
        init(device: MTLDevice) {
            startDate = Date()
            
            self.device = device
            self.commandQueue = device.makeCommandQueue()!
            
            guard let library = device.makeDefaultLibrary() else {fatalError()}
            let vertexFunction = library.makeFunction(name: "vertex_main")
            let fragmentFunction = library.makeFunction(name: "fragment_main")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            
            self.pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            
            self.vertexBuffer = device.makeBuffer(bytes: vertices,
                                                  length: vertices.count * MemoryLayout<Vertex>.stride,
                                                  options: .storageModeShared)!
 
            self.timeBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: .storageModeShared)!
            
        }
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                      let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
                
            let commandBuffer = commandQueue.makeCommandBuffer()!
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
   
            let timePointer = timeBuffer?.contents().bindMemory(to: Float.self, capacity: 1)
            timePointer?.pointee = Float(Date().timeIntervalSince(startDate!))
            
            let viewport = MTLViewport(
                originX: 0,
                originY: 0,
                width: Double(view.drawableSize.width),
                height: Double(view.drawableSize.height),
                znear: 0.0,
                zfar: 1.0
            )
            renderEncoder.setViewport(viewport)
            
            // set up the pipeline state and vertex buffer
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

            // Set up the resolution and time buffers, similar to passing uniform values for use in the shader.
            renderEncoder.setFragmentBuffer(resolutionBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentBuffer(timeBuffer, offset: 0, index: 2)

            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
            
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            self.viewWidth = Float(size.width)
            self.viewHeight = Float(size.height)

            let resolution: [Float] = [viewWidth, viewHeight]
            resolutionBuffer = device.makeBuffer(bytes: resolution,
                                                 length: MemoryLayout<SIMD2<Float>>.size,
                                                 options: .storageModeShared)!
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(device: MTLCreateSystemDefaultDevice()!)
    }
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = context.coordinator.device
        mtkView.delegate = context.coordinator
        mtkView.framebufferOnly = false
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        mtkView.contentMode = .scaleAspectFill
        mtkView.preferredFramesPerSecond = 60
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        MetalView()
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
