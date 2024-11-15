//
//  RequestProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

import HTTPTypes

protocol HTTPRequestProvider {
    
    func request() -> HTTPRequest
    
}
