//
//  CardHud.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 12/03/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import CleanroomLogger

class CardHud : NSWindowController {

    @IBOutlet weak var hud: CardHudHoverView!
    var entity: Entity?
    var card: Card?
    var floatingCard: FloatingCard?

    @IBOutlet weak var label: NSTextFieldCell!
    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var costReduction: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window!.styleMask = NSBorderlessWindowMask
        self.window!.ignoresMouseEvents = true
        self.window!.acceptsMouseMovedEvents = true
        self.window!.level = Int(CGWindowLevelForKey(CGWindowLevelKey.ScreenSaverWindowLevelKey))

        self.window!.opaque = false
        self.window!.hasShadow = false
        self.window!.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        hud.setDelegate(self)
    }

    func setEntity(entity: Entity?) {
        self.entity = entity
        var text = ""
        var image: String? = nil
        var cost = 0
        
        if let entity = entity {
            text += "\(entity.info.turn)"

            switch entity.info.cardMark {
            case .Coin: image = "coin"
            case .Kept: image = "kept"
            case .Mulliganed: image = "mulliganed"
            case .Returned: image = "returned"
            case .Created: image = "created"
            default: break
            }
            cost = entity.info.costReduction
            
            if entity.info.cardMark == .Coin {
                image = "small-card"
                card = Cards.byId(CardIds.NonCollectible.Neutral.TheCoin)
            }
            else if !String.isNullOrEmpty(entity.cardId) && !entity.info.hidden {
                image = "small-card"
                card = Cards.byId(entity.cardId)
            }
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .Center
        label.attributedStringValue = NSAttributedString(string: text, attributes: [
            NSFontAttributeName: NSFont(name: "Belwe Bd BT", size: 20)!,
            NSForegroundColorAttributeName: NSColor.whiteColor(),
            NSStrokeWidthAttributeName: -2,
            NSStrokeColorAttributeName: NSColor.blackColor(),
            NSParagraphStyleAttributeName: paragraph
            ])
        costReduction.attributedStringValue = NSAttributedString(string: "-\(cost)", attributes: [
            NSFontAttributeName: NSFont(name: "Belwe Bd BT", size: 16)!,
            NSForegroundColorAttributeName: NSColor(red: 0.117, green: 0.56, blue: 1, alpha: 1),
            NSStrokeWidthAttributeName: -2,
            NSStrokeColorAttributeName: NSColor.blackColor()
            ])
        costReduction.hidden = cost < 1
        if let image = image {
            icon.image = ImageCache.asset(image)
        }
        else {
            icon.image = nil
        }
    }
    
    // MARK: - mouse hover
    func hover() {
        if let card = self.card, windowFrame = self.window?.frame {
            floatingCard = FloatingCard(windowNibName: "FloatingCard")
            floatingCard?.showWindow(self)
            floatingCard?.setCard(card)
            
            let frame = NSMakeRect(windowFrame.origin.x + NSWidth(windowFrame) - 30,
                                   windowFrame.origin.y - 250,
                                   200, 303)
            floatingCard?.window?.setFrame(frame, display: true)
        }
    }
    
    func out() {
        floatingCard?.window?.orderOut(self)
    }
}

class CardHudHoverView : NSView {
    private var _delegate: CardHud?
    private var trackingArea: NSTrackingArea?
    
    func setDelegate(delegate: CardHud?) {
        self._delegate = delegate
    }
    
    // MARK: - mouse hover
    func ensureTrackingArea() {
        if trackingArea == nil {
            trackingArea = NSTrackingArea(rect: NSZeroRect,
                                          options: [NSTrackingAreaOptions.InVisibleRect, NSTrackingAreaOptions.ActiveAlways, NSTrackingAreaOptions.MouseEnteredAndExited],
                                          owner: self,
                                          userInfo: nil)
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        ensureTrackingArea()
        
        if !self.trackingAreas.contains(trackingArea!) {
            self.addTrackingArea(trackingArea!)
        }
    }
    
    override func mouseEntered(event: NSEvent) {
        _delegate?.hover()
    }
    
    override func mouseExited(event: NSEvent) {
        _delegate?.out()
    }
}