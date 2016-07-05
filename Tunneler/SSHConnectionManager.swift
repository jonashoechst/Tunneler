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
        let systemSSHConfigPath = NSString(string: "/etc/ssh/ssh_config").stringByExpandingTildeInPath
        let userSSHConfigPath = NSString(string: "~/.ssh/config").stringByExpandingTildeInPath
        let systemSSHConfig = SSHConfig(theConfigPath: systemSSHConfigPath, theParentConfig: nil);
        let userSSHConfig = SSHConfig(theConfigPath: userSSHConfigPath, theParentConfig: systemSSHConfig);
        
        for (host, params) in userSSHConfig.hosts {
            let connection = SSHConnection(theHost: host, theDelegate: self)
            if let dynamicforward = params["dynamicforward"] {
                connection.dynamicForward = dynamicforward
                connections.append(connection)
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