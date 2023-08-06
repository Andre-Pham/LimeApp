//
//  NodeUtil.swift
//  Lime
//
//  Created by Andre Pham on 9/4/2023.
//

import Foundation
import SceneKit

enum NodeUtil {
    
    static func printHierarchy(for node: SCNNode) {
        Self.printNodes(node: node)
    }
    
    private static func printNodes(node: SCNNode, prefix: String = "|") {
        print("\(prefix) \(node.toString())")
        for childNode in node.childNodes {
            self.printNodes(node: childNode, prefix: prefix + "|")
        }
    }
    
    static func getHierarchy(for node: SCNNode) -> [SCNNode] {
        var result = [SCNNode]()
        Self.getNodes(parent: node, collection: &result)
        return result
    }
    
    private static func getNodes(parent: SCNNode, collection: inout [SCNNode]) {
        collection.append(parent)
        for childNode in parent.childNodes {
            Self.getNodes(parent: childNode, collection: &collection)
        }
    }
    
}
