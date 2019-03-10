//
//  Scene.swift
//  VidEngine
//
//  Created by David Gavilan on 9/1/16.
//  Copyright © 2016 David Gavilan. All rights reserved.
//

import Foundation
import UIKit
import simd

open class Scene {
    static let arPlanesPrimitiveName = "ARPlanes"
    public var primitives: [Primitive] = []
    public var groups2D: [Group2D] = []
    public var lights: [LightSource] = []
    /// When deserializing a Scene, this will have the initial
    /// camera position. The actual camera used in rendering
    /// is passed in the `update` function from the `VidController`.
    public var camera: Camera? = nil
    /// An object that it's placed where the camera view vector
    /// intersects with the scene
    public var cursor: Cursor3D?

    /// Add & queue for rendering
    public func queue(_ primitive: Primitive) {
        primitives.append(primitive)
        primitive.queue()
    }
    
    /// Remove & dequeue
    public func dequeue(_ primitive: Primitive) {
        let index = primitives.index { $0 === primitive }
        if let i = index {
            primitives.remove(at: i)
            primitive.dequeue()
        }
    }
    
    /// Adds all elements to their respective rendering queues
    public func queueAll() {
        for p in primitives {
            p.queue()
        }
        for p in groups2D {
            p.queue()
        }
        for l in lights {
            l.queue()
        }
    }
    
    /// Removes all elements from the rendering queues.
    /// They will stop being rendered, but the elements aren't destroyed.
    public func dequeueAll() {
        for p in primitives {
            p.dequeue()
        }
        for p in groups2D {
            p.dequeue()
        }
        for l in lights {
            l.dequeue()
        }
    }
    
    /// Removes all elements from rendering and remove them from the scene.
    public func removeAll() {
        dequeueAll()
        primitives.removeAll()
        groups2D.removeAll()
        lights.removeAll()
    }
    
    open func update(_ currentTime: CFTimeInterval, camera: Camera) {
        let ray = camera.getGazeRay()
        updateCursor(gazeRay: ray)
    }
    
    public init() {
    }
    
    public func findPrimitive(by name: String) -> Primitive? {
        let index = primitives.index { $0.name == name }
        if let i = index {
            return primitives[i]
        }
        return nil
    }
    
    public func findPrimitiveInstance(by uuid: UUID) -> (Primitive, Int)? {
        let index = primitives.index { $0.uuidInstanceMap[uuid] != nil }
        if let i = index {
            let prim = primitives[i]
            let instanceIndex = prim.uuidInstanceMap[uuid]!
            return (prim, instanceIndex)
        }
        return nil
    }
    
    private func updateCursor(gazeRay: Ray) {
        guard let c = cursor else {
            return
        }
        var prims: [Primitive] = []
        switch c.targetSurface {
        case .arPlanes:
            if let p = findPrimitive(by: Scene.arPlanesPrimitiveName) {
                prims = [p]
            }
        case .all:
            prims = self.primitives
        }
        var intersection: SurfaceIntersection?
        var distance = Float.greatestFiniteMagnitude
        for p in prims {
            if let si = p.getSurfaceIntersection(ray: gazeRay), si.distance < distance {
                distance = si.distance
                intersection = si
            }
        }
        if let si = intersection {
            c.update(intersection: si)
        }
    }
}
