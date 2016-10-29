//
//  MainViewController.swift
//  OneChat
//
//  Created by Paul on 13/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit
import XMPPFramework
import xmpp_messenger_ios

protocol ContactPickerDelegate{
	func didSelectContact(recipient: XMPPUserCoreDataStorageObject)
}

class ContactListTableViewController: UITableViewController, OneRosterDelegate, UIGestureRecognizerDelegate {
	
	var delegate:ContactPickerDelegate?
	
	// Mark : Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ContactListTableViewController.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.allowableMovement = 15 // 15 points
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
        
		OneRoster.sharedInstance.delegate = self
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if OneChat.sharedInstance.isConnected() {
			navigationItem.title = "Contacts"
		}
        self.tableView.rowHeight = 75
	}
    
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		OneRoster.sharedInstance.delegate = nil
	}
    
	
	func oneRosterContentChanged(controller: NSFetchedResultsController) {
		tableView.reloadData()
	}
    
    
    // Mark: Gesture Handler
    
    func handleLongPress(longPressGesture:UILongPressGestureRecognizer) {
        
        
        
        let p = longPressGesture.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        
        if indexPath == nil {
            print("Long press on table view, not row.")
        }
        else if (longPressGesture.state == UIGestureRecognizerState.Began) {
            print("Long press on row, at \(indexPath!.row)")
            
            let cell: TableViewCell = self.tableView.cellForRowAtIndexPath(indexPath!)! as! TableViewCell
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
    }
	
	// Mark: UITableView Datasources
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sections: NSArray? =  OneRoster.buddyList.sections
		
		if section < sections!.count {
			let sectionInfo: AnyObject = sections![section]
			
			return sectionInfo.numberOfObjects
		}
		
		return 0;
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
		return OneRoster.buddyList.sections!.count
	}
	
	// Mark: UITableView Delegates
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sections: NSArray? = OneRoster.sharedInstance.fetchedResultsController()!.sections
        if section < sections!.count {
			let sectionInfo: AnyObject = sections![section]
			let tmpSection: Int = Int(sectionInfo.name)!
			
			switch (tmpSection) {
			case 0 :
				return "Online"
				
			case 1 :
				return "Away"
				
			default :
				return "Offline"
				
			}
		}
		
		return ""
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		_ = OneRoster.userFromRosterAtIndexPath(indexPath: indexPath)
		
		delegate?.didSelectContact(OneRoster.userFromRosterAtIndexPath(indexPath: indexPath))
		close(self)
        
        print("didSelectRowAtIndexPAth")
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
		let cell: TableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? TableViewCell

		let user = OneRoster.userFromRosterAtIndexPath(indexPath: indexPath)
        
		print("Contact list controller \(user)")
        cell!.userName!.text = user.displayName
        
        cell!.statusLabel!.layer.cornerRadius = cell!.statusLabel!.frame.size.width/2;
        cell!.statusLabel!.clipsToBounds = true
        switch user.sectionNum {
        case 0:
            cell!.statusLabel!.backgroundColor = UIColor.greenColor()
        case 1:
            cell!.statusLabel!.backgroundColor = UIColor.brownColor()
        default:
            cell!.statusLabel!.backgroundColor = UIColor.whiteColor()
        }
		
		if user.unreadMessages.intValue > 0 {
			cell!.backgroundColor = .orangeColor()
		} else {
			cell!.backgroundColor = .whiteColor()
		}
		
		OneChat.sharedInstance.configurePhotoForCell(cell!, user: user)
        cell!.userImage!.image = cell!.imageView?.image
        cell!.imageView!.image = nil
        cell!.userImage!.layer.cornerRadius = cell!.userImage!.frame.size.width/2
        cell!.userImage!.clipsToBounds = true
        cell!.userImage!.contentMode = .ScaleAspectFill
        
		return cell!;
	}
	
	// Mark: Segue support
	
	override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
		if segue?.identifier != "contactsToChat" {
			if let controller: ChatViewController? = segue?.destinationViewController as? ChatViewController {
				if let cell: UITableViewCell? = sender as? UITableViewCell {
					let user = OneRoster.userFromRosterAtIndexPath(indexPath: tableView.indexPathForCell(cell!)!)
					controller!.recipient = user
				}
			}
		}
	}
	
	// Mark: IBAction
	
	@IBAction func close(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	// Mark: Memory Management
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}