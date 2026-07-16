// Exit 0 when the macOS screen is locked, 1 otherwise.
// Build: swiftc -O islocked.swift -o islocked
import CoreGraphics
import Foundation
let d = CGSessionCopyCurrentDictionary() as? [String: Any] ?? [:]
exit(d["CGSSessionScreenIsLocked"] != nil ? 0 : 1)
