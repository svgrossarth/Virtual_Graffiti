//
//  Stroke.swift
//  Login
//
//  Created by Spencer Grossarth on 3/6/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import Foundation
import SceneKit


class Stroke : SCNNode {
    let scalingFactor : Float = 0.005
    var strokeVertices = [SCNVector3]()
    var previousPoint = SCNVector3()
    var indices = [UInt32]()
    let initialIndices : [UInt32]  = [
        2,5,1, //front
        5,2,6,
        
        
        6,7,4, //second square
        6,4,5,

        3,1,0, //first square
        3,2,1,


        7,0,4, //back
        0,7,3,

        3,6,2, //bottom
        6,3,7,
        
        1,4,0, //top
        1,5,4
        
    ]
    
    init(firstPoint : SCNVector3) {
        self.previousPoint = firstPoint
        super.init()
    }
    
    required init?(coder: NSCoder) {
        self.previousPoint = SCNVector3()
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func addVertices(point3D: SCNVector3, initialNearFarLine: SCNVector3, lineBetweenNearFar: SCNVector3){
        
        let x = point3D.x
        let y = point3D.y
        let z = point3D.z
        
        
        let prevX = previousPoint.x
        let prevY = previousPoint.y
        let prevZ = previousPoint.z
        let lineBetweenPoints = SCNVector3(x: x - prevX, y: y - prevY, z: z - prevZ)
        
        if strokeVertices.count == 0 {
            let prevResizedNearFar = resizeVector(vector: initialNearFarLine, scalingFactor: scalingFactor)
            let prevResizedNormal = resizeVector(vector: crossProduct(vec1: prevResizedNearFar, vec2: lineBetweenPoints), scalingFactor: scalingFactor)
            strokeVertices = [
                SCNVector3(prevX - prevResizedNearFar.x + prevResizedNormal.x, prevY - prevResizedNearFar.y + prevResizedNormal.y, prevZ - prevResizedNearFar.z + prevResizedNormal.z),
                
                SCNVector3(prevX + prevResizedNearFar.x + prevResizedNormal.x, prevY + prevResizedNearFar.y + prevResizedNormal.y, prevZ + prevResizedNearFar.z + prevResizedNormal.z),
                
                SCNVector3(prevX + prevResizedNearFar.x - prevResizedNormal.x, prevY + prevResizedNearFar.y - prevResizedNormal.y, prevZ + prevResizedNearFar.z - prevResizedNormal.z),
                
                SCNVector3(prevX - prevResizedNearFar.x - prevResizedNormal.x, prevY - prevResizedNearFar.y - prevResizedNormal.y, prevZ - prevResizedNearFar.z - prevResizedNormal.z)
            ]
        }
        let resizedNearFar = resizeVector(vector: lineBetweenNearFar, scalingFactor: scalingFactor)
        let resizedNormal = resizeVector(vector: crossProduct(vec1: resizedNearFar, vec2: lineBetweenPoints), scalingFactor: scalingFactor)
        strokeVertices += [
            SCNVector3(x - resizedNearFar.x + resizedNormal.x, y - resizedNearFar.y + resizedNormal.y, z - resizedNearFar.z + resizedNormal.z),
            
            SCNVector3(x + resizedNearFar.x + resizedNormal.x, y + resizedNearFar.y  + resizedNormal.y, z + resizedNearFar.z + resizedNormal.z),
            
            SCNVector3(x + resizedNearFar.x - resizedNormal.x, y + resizedNearFar.y  - resizedNormal.y, z + resizedNearFar.z - resizedNormal.z),
            
            SCNVector3(x - resizedNearFar.x - resizedNormal.x, y - resizedNearFar.y  - resizedNormal.y, z - resizedNearFar.z - resizedNormal.z),
        ]
        connectVertices()
    }
    
    func connectVertices(){
        if indices.count == 0 {
            indices = initialIndices
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            let source = SCNGeometrySource(vertices: strokeVertices)
            let customGeom = SCNGeometry(sources: [source], elements: [element])
            
            let material = SCNMaterial()
            material.diffuse.contents = PKCanvas().sendColor()
            customGeom.materials = [material]
            
            //points[points.count - 1].material = material
            self.geometry = customGeom
        } else {
            // (number of points - 2 becuase already did first 2 points) * 4 becuase 4 vertices per point
            let indexAdder = UInt32(((strokeVertices.count / 4) - 2) * 4)
            
            var newIndices = [UInt32]()
            
            for index in initialIndices {
                newIndices.append(index + indexAdder)
            }
            
            indices += newIndices
            
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            let source = SCNGeometrySource(vertices: strokeVertices)
            let customGeom = SCNGeometry(sources: [source], elements: [element])
            
            let material = SCNMaterial()
            material.diffuse.contents = PKCanvas().sendColor()
            customGeom.materials = [material]

            self.geometry = customGeom
        }
    }

    
    
    
    
    
}
