//
//  SSHConnectionManager.swift
//  Tunneler
//
//  Created by Jonas Höchst on 08.03.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

import Foundation

protocol SSHConnectionManagerDelegate {
    func sessionConnected(index: Int)
    func sessionDisconnected(index: Int, message: String?)
}

class SSHConnectionManager: SSHConnectionDelegate {
    var connections: [SSHConnection] = []
    let delegate: SSHConnectionManagerDelegate?
    
    init (theDelegate: SSHConnectionManagerDelegate?) {
        self.delegate = theDelegate
        loadSSHConfig()
    }
    
    func loadSSHConfig () {
        let filepath = NSString(string: "~/.ssh/config").stringByExpandingTildeInPath
        let fileContent = try! String(contentsOfFile: filepath, encoding: NSUTF8StringEncoding)
        
        var currentHost: SSHConnection?
        
        let lines = fileContent.componentsSeparatedByString("\n") //.characters.split{$0 == "\n"}.map(String.init)
        for line in lines{
            let array = line.characters.split{$0 == " "}.map(String.init)
            if array.count == 0 || array[0].characters.first! == "#" {
                // This is a empty line or a comment
                continue
            }
            
            if array.first!.lowercaseString == "host" {
                if let host = currentHost {
                    if let _ = host.dynamicForward {
                        connections.append(host)
                    }
                }
                currentHost = SSHConnection(theHost: array[1], theDelegate: self)
                continue
            }
            
            if array.first!.lowercaseString == "dynamicforward" {
                currentHost?.dynamicForward = array[1]
            }
            
            currentHost?.config[array.first!] = array[1]
        }
        
        if let host = currentHost {
            if let _ = host.dynamicForward {
                connections.append(host)
            }
        }
    }
    
    func terminate () {
        for c in connections{ c.disconnect() }
    }
    
    // MARK: - SSHConnectionDelegate Methods
    func sessionConnected(connection: SSHConnection) {
        let index = self.connections.indexOf({$0 === connection})
        self.delegate?.sessionConnected(index!)
    }
    
    func sessionDisconnected(connection: SSHConnection, message: String?){
        let index = self.connections.indexOf({$0 === connection})
        self.delegate?.sessionDisconnected(index!, message: message)
    }
    
}