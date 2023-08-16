//
//  DatabaseSession.swift
//  Lime
//
//  Created by Andre Pham on 16/8/2023.
//

import Foundation
import SwiftSerialization

class DatabaseSession {
    
    private static let SETTINGS_ID = "lime-settings"
    
    /// Singleton instance
    public static let inst = DatabaseSession()
    
    private let database: DatabaseTarget = SQLiteDatabase()
    
    private init() { }
    
    func readSettings() -> LimeSettings? {
        return self.database.read(id: Self.SETTINGS_ID)
    }
    
    func saveSettings(_ settings: LimeSettings, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            let outcome = self.database.write(Record(id: Self.SETTINGS_ID, data: settings))
            DispatchQueue.main.async {
                if outcome { print("Settings successfully saved") }
                completion(outcome)
            }
        }
    }
    
}
