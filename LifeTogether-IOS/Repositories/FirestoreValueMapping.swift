//
//  FirestoreValueMapping.swift
//  LifeTogether-IOS
//
//  Created by OpenAI on 15/06/2026.
//

import FirebaseFirestore
import Foundation

func firestoreDate(_ value: Any?) -> Date? {
    if let timestamp = value as? Timestamp {
        return timestamp.dateValue()
    }

    if let date = value as? Date {
        return date
    }

    return nil
}

func firestoreValueTypeDescription(_ value: Any?) -> String {
    guard let value else { return "nil" }
    return String(describing: type(of: value))
}
