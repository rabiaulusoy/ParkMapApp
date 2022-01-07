//
//  File.swift
//  ParkMapApp
//
//  Created by rabia on 26.12.2021.
//

import Foundation

enum ImageSource {
        case photoLibrary
        case camera
    }

enum ParkLocationEntityAttributes : String {
    case ParkLocationEntity = "ParkLocationEntity"
    case title = "title"
    case parkDescription = "parkDescription"
    case latitude = "latitude"
    case longitude = "longitude"
    case datetime = "datetime"
    case image = "image"
}

enum ErrorCode {
    case SaveParkLocationError
    case AccesDenied
    case ImageNotFound
    case CantGetValuesFromDB
}
