//
//  DefaultsManager.swift
//  GatetoPayOnboarding
//
//  Created by areej sadaqa on 29/05/2022.
//

import Foundation
import UIKit

final class DefaultsManager: NSObject {
    
    static let shared = DefaultsManager()
    let userDefaults = UserDefaults.standard
    
    private override init() {
        super.init()
    }
    
    func setScanDocumentsValue(value: Bool?) {
        userDefaults.set(value, forKey: "ScanDocumentsValue")
    }
    
    func getScanDocumentsValue() -> Bool? {
        return userDefaults.bool(forKey: "ScanDocumentsValue") 
    }
    
    func setScreeningValue(value: Bool?) {
        userDefaults.set(value, forKey: "ScreeningValue")
    }
    
    func getScreeningValue() -> Bool? {
        return userDefaults.bool(forKey: "ScreeningValue") 
    }
    
    func setLivenessCheckValue(value: Bool?) {
        userDefaults.set(value, forKey: "LivenessCheckValue")
    }
    
    func getLivenessCheckValue() -> Bool? {
        return userDefaults.bool(forKey: "LivenessCheckValue") 
    }
    
    func setCloseJourneyValue(value: Bool?) {
        userDefaults.set(value, forKey: "CloseJourneyValue")
    }
    
    func getCloseJourneyValue() -> Bool? {
        return userDefaults.bool(forKey: "CloseJourneyValue") 
    }

}
