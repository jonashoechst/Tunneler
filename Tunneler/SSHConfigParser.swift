//
//  SSHConfigParser.swift
//  Tunneler
//
//  Created by Jonas Höchst on 22.05.16.
//  Copyright © 2016 Jonas Höchst. All rights reserved.
//

import Foundation

class SSHConfig {
    var hosts = Dictionary<String, [String : String]>()
    var configPath: String?
    var parentConfig: SSHConfig?
    
    init (theConfigPath: String?, theParentConfig:SSHConfig?) {
        configPath = theConfigPath
        parentConfig = theParentConfig
        reloadConfig()
    }
    
    func reloadConfig () {
        hosts = Dictionary<String, [String : String]>()
        if let parentHosts = parentConfig?.hosts { for (k, v) in parentHosts { hosts[k] = v } }
        
        if let path = configPath {
            let fileContent = try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            var currentHost = ""
            
            let lines = fileContent.componentsSeparatedByString("\n")
            for line in lines{
                let params = line.characters.split{$0 == " "}.map(String.init) // ToDo: quotes in paramenter
                if params.count == 0 || params[0].characters.first! == "#" { continue }
                let key = params[0].lowercaseString
                let value = params[1..<params.count].joinWithSeparator(" ")
                
                if key == "host" { currentHost = value }
                
                if hosts[currentHost] != nil { hosts[currentHost]![key] = value }
                else { hosts[currentHost] = [key:value] }
            }
        }
    }
    
}