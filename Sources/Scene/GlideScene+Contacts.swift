//
//  GlideScene+ContactTestMap.swift
//  glide
//
//  Copyright (c) 2019 cocoatoucher user on github.com (https://github.com/cocoatoucher/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

extension GlideScene {
    
    public func mapContact(between mask: CategoryMask, and otherMask: CategoryMask) {
        if let mapped = contactTestMap[mask.rawValue] {
            contactTestMap[mask.rawValue] = mapped | otherMask.rawValue
        } else {
            contactTestMap[mask.rawValue] = otherMask.rawValue
        }
    }
    
    public func canHaveContact(between mask: CategoryMask, and otherMask: CategoryMask) -> Bool {
        if let mapped = contactTestMap[mask.rawValue] {
            if mapped & otherMask.rawValue == otherMask.rawValue {
                return true
            }
        }
        
        if let mapped = contactTestMap[otherMask.rawValue] {
            if mapped & mask.rawValue == mask.rawValue {
                return true
            }
        }
        
        return false
    }
    
    public func unregisterContacts(for mask: CategoryMask) {
        contactTestMap[mask.rawValue] = nil
    }
    
    public func reset() {
        contactTestMap = [:]
    }
    
    // MARK: - Internal
    
    func notifyEnteredAndStayedContacts() {
        for contact in collisionsController.contacts {
            guard let state = collisionsController.stateForContact(contact) else {
                continue
            }
            
            notifyOriginalObjectForEnteredAndStayedContacts(contactContext: contact, state: state)
            notifyOtherObjectForEnteredAndStayedContacts(contactContext: contact, state: state)
        }
    }
    
    func notifyExitedContacts() {
        for contactContext in collisionsController.exitContacts {
            let contact = contactContext.contactForCollider
            for component in contact.collider.entity?.components ?? [] {
                if let colliderResponder = component as? GlideComponent {
                    if contactContext.isCollision {
                        colliderResponder.handleFinishedCollision(contact)
                    } else {
                        colliderResponder.handleFinishedContact(contact)
                    }
                }
            }
            
            if let contactForOther = contactContext.contactForOtherObject {
                for component in contactForOther.collider.entity?.components ?? [] {
                    if let colliderResponder = component as? GlideComponent {
                        if contactContext.isCollision {
                            colliderResponder.handleFinishedCollision(contactForOther)
                        } else {
                            colliderResponder.handleFinishedContact(contactForOther)
                        }
                    }
                }
            }
        }
    }
    
    private func notifyOriginalObjectForEnteredAndStayedContacts(contactContext: ContactContext,
                                                                 state: CollisionsController.ContactState) {
        let contact = contactContext.contactForCollider
        for component in contact.collider.entity?.components ?? [] {
            if let colliderResponder = component as? GlideComponent {
                switch state {
                case .entered:
                    if contactContext.isCollision {
                        colliderResponder.handleNewCollision(contact)
                    } else {
                        colliderResponder.handleNewContact(contact)
                    }
                case .stayed:
                    if contactContext.isCollision {
                        colliderResponder.handleExistingCollision(contact)
                    } else {
                        colliderResponder.handleExistingContact(contact)
                    }
                }
            }
        }
    }
    
    private func notifyOtherObjectForEnteredAndStayedContacts(contactContext: ContactContext,
                                                              state: CollisionsController.ContactState) {
        guard let contactForOther = contactContext.contactForOtherObject else {
            return
        }
        
        for component in contactForOther.collider.entity?.components ?? [] {
            if let colliderResponder = component as? GlideComponent {
                switch state {
                case .entered:
                    if contactContext.isCollision {
                        colliderResponder.handleNewCollision(contactForOther)
                    } else {
                        colliderResponder.handleNewContact(contactForOther)
                    }
                case .stayed:
                    if contactContext.isCollision {
                        colliderResponder.handleExistingCollision(contactForOther)
                    } else {
                        colliderResponder.handleExistingContact(contactForOther)
                    }
                }
            }
        }
    }
}
