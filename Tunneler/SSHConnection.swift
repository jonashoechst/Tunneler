//
//  SSHConnection.swift
//  Tunnler
//
//  Created by Jonas Höchst on 07.03.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

import Foundation

protocol SSHConnectionDelegate {
    func sessionConnected(connection: SSHConnection)
    func sessionDisconnected(connection: SSHConnection, message: String?)
}

enum SSHConnectionStatus {
    case connected, disconnected, failed
}

class SSHConnection {
    var host: String
    var socksPort: Int
    var compression = false
    var remoteHostsAllowed = false
    
    // optionals
    var user: String?
    var cipher: String?
    
    // statics
    let outpipe = NSPipe()
    let task = NSTask()
    
    // delegate
    let delegate: SSHConnectionDelegate?
    
    // state management
    var status = SSHConnectionStatus.disconnected {
        didSet {
            if status == SSHConnectionStatus.connected { delegate?.sessionConnected(self) }
            else {
                let messageData = outpipe.fileHandleForReading.readDataToEndOfFile()
                let message = String(data: messageData, encoding: NSUTF8StringEncoding)
                delegate?.sessionDisconnected(self, message: message)
            }
        }
    }
    
    init (theHost: String, theSocksPort: Int, theDelegate: SSHConnectionDelegate?) {
        self.host = theHost
        self.socksPort = theSocksPort
        self.delegate = theDelegate
        
        self.task.standardOutput = outpipe
        self.task.standardError = outpipe
        self.task.launchPath = "/usr/bin/env"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("taskTerminated:"), name: NSTaskDidTerminateNotification, object: self.task)
    }
    
    dynamic func taskTerminated (notification: NSNotification) {
        self.status = SSHConnectionStatus.disconnected
    }
    
    func craftCommand () -> [String] {
        var command = ["ssh", "-N", "-D", String(socksPort)]

        if let cipher = cipher { command += ["-c", cipher] }
        if compression { command.append("-C") }
        if remoteHostsAllowed { command.append("-g") }
        
        if let user = user { command.append(user+"@"+host) }
        else { command.append(host) }
        
        return command
    }
    
    func connect () {
        task.arguments = self.craftCommand()
        print("Connecting with command: "+task.arguments!.joinWithSeparator(" "))
        task.launch()
        self.status = SSHConnectionStatus.connected
    }
    
    func disconnect () {
        task.terminate()
    }

}