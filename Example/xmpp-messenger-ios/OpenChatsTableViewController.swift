//
//  GroupChatTableViewController.swift
//  OneChat
//
//  Created by Paul on 02/03/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit
import xmpp_messenger_ios
import XMPPFramework


class OpenChatsTableViewController: UITableViewController, OneRosterDelegate {
	
	var chatList = NSArray()
//    var msg : String?
    
	// Mark: Life Cycle
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
        
        
		OneRoster.sharedInstance.delegate = self
		OneChat.sharedInstance.connect(username: kXMPP.myJID, password: kXMPP.myPassword) { (stream, error) -> Void in
			if let _ = error {
				self.performSegueWithIdentifier("One.HomeToSetting", sender: self)
			} else {
				//set up online UI
			}
		}
		
		//self.tableView.rowHeight = 50
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		OneRoster.sharedInstance.delegate = nil
	}
	
	// Mark: OneRoster Delegates
	
	func oneRosterContentChanged(controller: NSFetchedResultsController) {
		//Will reload the tableView to reflet roster's changes
		tableView.reloadData()
	}
	
	// Mark: UITableView Datasources
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return OneChats.getChatsList().count
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		//let sections: NSArray? = OneRoster.sharedInstance.fetchedResultsController()!.sections
		return 1//sections
	}
	
	// Mark: UITableView Delegates
	
	override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView()
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: TableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? TableViewCell
		let user = OneChats.getChatsList().objectAtIndex(indexPath.row) as! XMPPUserCoreDataStorageObject
		
        print("Chat list controller + \(user)")
        
		cell!.userName!.text = user.displayName
        
//        if let message = msg {
//            cell!.userMessage!.text = message
//        }
		
		OneChat.sharedInstance.configurePhotoForCell(cell!, user: user)
		
        cell!.userImage!.layer.cornerRadius = cell!.userImage!.frame.size.width / 2
		cell!.userImage!.clipsToBounds = true
        
        cell!.unreadMessages!.text = String(user.unreadMessages)
        
        switch user.unreadMessages {
        case 0:
            cell!.unreadMessages!.hidden = true
        default:
            cell!.unreadMessages!.text = String(user.unreadMessages)
        }
        
        cell!.unreadMessages!.layer.cornerRadius = cell!.unreadMessages.frame.size.width/2;
        cell!.unreadMessages!.clipsToBounds = true
        
        switch user.sectionNum {
        case 0:
            cell!.statusLabel!.backgroundColor = UIColor.greenColor()
        case 1:
            cell!.statusLabel!.backgroundColor = UIColor.brownColor()
        default:
            cell!.statusLabel!.backgroundColor = UIColor.whiteColor()
        }
        
        cell!.statusLabel!.layer.cornerRadius = cell!.statusLabel.frame.size.width/2;
        cell!.statusLabel!.clipsToBounds = true
        
		
		return cell!
	}
    
    // Mark: Chat message Delegates
    
//    func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject) {
//         msg = (message.elementForName("body")?.stringValue())!
//        
//    }

    
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
			let refreshAlert = UIAlertController(title: "", message: "Are you sure you want to clear the entire message history? \n This cannot be undone.", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            		refreshAlert.addAction(UIAlertAction(title: "Clear message history", style: .Destructive, handler: { (action: UIAlertAction!) in
                		OneChats.removeUserAtIndexPath(indexPath)
                		tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            		}))
            
            		refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in

            		}))
            
            		presentViewController(refreshAlert, animated: true, completion: nil)
		}
	}
	
	// Mark: Segue support
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if identifier == "chat.to.add" {
			if !OneChat.sharedInstance.isConnected() {
				let alert = UIAlertController(title: "Attention", message: "You have to be connected to start a chat", preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
				
				self.presentViewController(alert, animated: true, completion: nil)
				
				return false
			}
		}
		return true
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
		if segue?.identifier == "chats.to.chat" {
			if let controller = segue?.destinationViewController as? ChatViewController {
				if let cell: UITableViewCell? = sender as? UITableViewCell {
					let user = OneChats.getChatsList().objectAtIndex(tableView.indexPathForCell(cell!)!.row) as! XMPPUserCoreDataStorageObject
					controller.recipient = user
				}
			}
		}
	}
	
	// Mark: Memory Management
	
	override func didReceiveMemoryWarning() {
		
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
