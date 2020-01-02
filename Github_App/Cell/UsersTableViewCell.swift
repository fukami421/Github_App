//
//  UsersTableViewCell.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/28.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import UIKit
import RxSwift

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    var disposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 再利用時にdisposeBagに溜まっていたものを破棄
        self.disposeBag = DisposeBag()
    }
}
