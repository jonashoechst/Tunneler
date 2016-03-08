//
//  AppDelegate.swift
//  Tunnler
//
//  Created by Jonas Höchst on 07.03.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SSHConnectionDelegate {
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    var connections: [SSHConnection] = []

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
        }
        
        connections.append(SSHConnection(theHost: "jonashoechst.de", theSocksPort: 1080, theDelegate: self))
        connections.append(SSHConnection(theHost: "rechenschieber", theSocksPort: 1080, theDelegate: self))
        
        let menu = NSMenu()
        for c in connections {
            let index = connections.indexOf({$0 === c})
            let item = NSMenuItem(title: c.host, action: Selector("itemClicked:"), keyEquivalent: String(index!+1))
            item.state = NSOffState
            menu.addItem(item)
        }
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func itemClicked(sender: NSMenuItem) {
        let index = statusItem.menu?.indexOfItem(sender)
        let connection = connections[index!]
        
        if connection.status == SSHConnectionStatus.connected {
            connection.disconnect()
        } else {
            connection.connect()
        }
    }
    
    func sessionConnected(connection: SSHConnection) {
        let index = connections.indexOf({$0 === connection})
        statusItem.menu?.itemAtIndex(index!)?.state = NSOnState
    }
    
    func sessionDisconnected(connection: SSHConnection, message: String?) {
        let index = connections.indexOf({$0 === connection})
        statusItem.menu?.itemAtIndex(index!)?.state = NSOffState
    }
    


}

