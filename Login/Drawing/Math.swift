//
//  Math.swift
//  Login
//
//  Created by Spencer Grossarth on 3/6/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import Foundation
import SceneKit

func crossProduct(vec1: SCNVector3, vec2: SCNVector3) -> SCNVector3{
    return SCNVector3(x: vec1.y * vec2.z - vec1.z * vec2.y, y: vec1.z * vec2.x - vec1.x * vec2.z, z: vec1.x * vec2.y - vec1.y * vec2.x)
}

func resizeVector(vector: SCNVector3, scalingFactor: Float) -> SCNVector3{
    let length = sqrtf(powf(vector.x, 2) + powf(vector.y, 2) + powf(vector.z, 2))
    return SCNVector3((vector.x/length) * scalingFactor, (vector.y/length) * scalingFactor, (vector.z/length) * scalingFactor)
}

func distanceBetweenPoints(vec1: SCNVector3, vec2: SCNVector3) -> Float {
    return sqrt(powf((vec1.x - vec2.x), 2) + powf((vec1.y - vec2.y), 2) + powf((vec1.z - vec2.z), 2))
}


