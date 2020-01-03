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
    
    var isFavorite: Bool = false
    
    var disposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.disposeBag = DisposeBag()
        self.setUpUI()
    }

    private func setUpUI()
    {
        self.favoriteBtn.layer.cornerRadius = 0.5 * self.favoriteBtn.bounds.size.width
        self.favoriteBtn.layer.borderWidth = 1.0
        self.favoriteBtn.layer.borderColor = UIColor.black.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
        self.isFavorite = false
        self.favoriteBtn.backgroundColor = .white
    }
}
