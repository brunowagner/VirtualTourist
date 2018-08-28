//
//  ErrorTreatment.swift
//  VirtualTourist
//
//  Created by Bruno W on 28/08/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
struct ErrorTreatment {
    enum ErrorCode : Int{
        case The_Internet_connection_appears_to_be_offline = -1009
        case The_request_timed_out = -1001
        case No_error = 0
        case Response_statusCode_400_Bad_Request = 400
        case Response_statusCode_401_Unauthorized = 401
        case Response_statusCode_403_Forbidden = 403
        case Response_statusCode_404_Not_Found = 404
        case Response_statusCode_500_Internal_Server_Error = 500
        case Response_statusCode_no_2XX = 10000
        case Response_statusCode_error = 10001
        case No_data_or_unexpected_data_was_returned = 20000
        case Could_not_parse_the_data = 20001
    }
}
