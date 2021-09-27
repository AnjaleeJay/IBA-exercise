//
//  tvShowController.swift
//  TVMazeBrowser
//
//  Created by Anjalee Jayasooriya on 25/9/21.
//  Copyright © 2021 Itty Bitty Apps. All rights reserved.
//
import UIKit
class tvShowController: UIViewController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { if segue.destination is tvShowController { let vc = segue.destination as? tvShowController?;.username = "Arthur Dent" } }
}

