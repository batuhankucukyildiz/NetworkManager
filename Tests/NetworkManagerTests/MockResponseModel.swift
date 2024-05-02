//
//  File.swift
//  
//
//  Created by Sucu, Ege on 2.05.2024.
//

import Foundation

/*
 "userId": 1,
   "id": 1,
   "title": "delectus aut autem",
   "completed": false
 */

struct MockResponseModel: Codable {
    let userId: Int?
    let id: Int?
    let title: String?
    let completed: Bool?
}
