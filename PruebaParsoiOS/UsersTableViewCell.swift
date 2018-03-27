//
//  UsersTableViewCell.swift
//  PruebaParsoiOS
//
//  Created by Innova Media on 26/03/2018.
//  Copyright © 2018 Parso. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var viewUser: UIView!
    @IBOutlet weak var imgUserPicture: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
