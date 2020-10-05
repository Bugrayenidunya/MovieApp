//
//  UIViewController+Extension.swift
//  MobilliumMovieApp
//
//  Created by Bugra's Mac on 30.09.2020.
//

import UIKit

extension UIViewController {
    // Hide keyboard when touch outside the textfield
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
