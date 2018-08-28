//
//  Photo.swift
//  VirtualTourist
//
//  Created by Bruno W on 28/08/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
extension Photo{
    //sempre que um objeto foto for criado, a data de criação será configurada
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.creationDate = Date()
    }
}
