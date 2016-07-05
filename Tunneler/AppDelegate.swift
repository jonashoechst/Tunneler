//
//  AppDelegate.swift
//  Tunnler
//
//  Created by Jonas Höchst on 07.03.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, SSHConnectionManagerDelegate {
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    var manager: SSHConnectionManager?
    
    // MARK: NSApplicationDelegate Methods
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.manager = SSHConnectionManager(theDelegate: self)
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
        }
        
        let menu = NSMenu()
        for (index, c) in manager!.connections.enumerate() {
            let item = NSMenuItem(title: "\(c.host) (\(c.dynamicForward!))", action: #selector(AppDelegate.itemClicked(_:)), keyEquivalent: String(index+1))
            item.tag = index
            menu.addItem(item)
        }
        
//        menu.addItem(NSMenuItem.separatorItem())
//        menu.addItem(NSMenuItem(title: "Refresh Menu", action: Selector("refresh:"), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.sharedApplication().terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func applicationWillTerminate(notification: NSNotification) {
        manager!.terminate()
    }
    
    // MARK: NSMenuItem Methods
    func itemClicked(sender: NSMenuItem) {
        let connection = manager!.connections[sender.tag]
        
        if connection.status == SSHConnectionStatus.connected {
            connection.disconnect()
        } else {
            do { try connection.connect() }
            catch { print("The connection could not be initiated... Already connected?") }
        }
    }

    
    // MARK: SSHConnectionManagerDelegate Methods
    func sessionConnected(index: Int) {
        statusItem.menu?.itemAtIndex(index)?.state = NSOnState
    }
    
    func sessionDisconnected(index: Int, message: String?){
        statusItem.menu?.itemAtIndex(index)?.state = NSOffState
    }

}

