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

enum SSHConnectionError: ErrorType{
    case AlreadyConnected
}

class SSHConnection: CustomStringConvertible{
    var host: String
    var config = [String: String]()
    var dynamicForward: String?
    
    // task handling
    let outpipe = NSPipe()
    var task: NSTask?
    
    // delegate
    let delegate: SSHConnectionDelegate?
    
    // state management
    var status = SSHConnectionStatus.disconnected {
        didSet {
            if status == SSHConnectionStatus.connected { delegate?.sessionConnected(self) }
            else {
//                let messageData = outpipe.fileHandleForReading.readDataToEndOfFile()
//                let message = String(data: messageData, encoding: NSUTF8StringEncoding)
                delegate?.sessionDisconnected(self, message: "")
            }
        }
    }
    
    init (theHost: String, theDelegate: SSHConnectionDelegate?) {
        self.host = theHost
        self.delegate = theDelegate
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SSHConnection.taskTerminated(_:)), name: NSTaskDidTerminateNotification, object: self.task)
    }

    func connect () throws {
        if status == SSHConnectionStatus.connected { throw SSHConnectionError.AlreadyConnected }
        
        self.task = NSTask()
//        self.task!.standardOutput = outpipe
//        self.task!.standardError = outpipe
        self.task!.launchPath = "/usr/bin/env"
        self.task!.arguments = ["ssh", "-N", host]
        self.task!.launch()
        
        self.status = SSHConnectionStatus.connected
    }
    
    func disconnect () {
        if let task = self.task { task.terminate() }
    }
    
    dynamic func taskTerminated (notification: NSNotification) {
        self.status = SSHConnectionStatus.disconnected
    }
    
    // MARK: CustomStringConvertible Method
    var description: String {
        return "ssh \(host): \(config)"
    }
    
}