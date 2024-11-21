//
//  Instrumet.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 17.11.24.
//

import Foundation

struct Instrumet: Decodable {
    let title: String
    let name: String
    let description: String
    let historical_filename: String?
    let special: Bool
    let pipValue: Double

    let base_currency: String
    let quote_currency: String

    let tag_list: [String]
}

struct InstrumetInfo {
    let name: String

    let baseCurrency: String
    let quoteCurrency: String
    let pipValue: Double

    let tags: [String]
}

struct InstrumetHistoryFileInfo {
    let filename: String
}

/*

 "title": "0027.HK/HKD",
 "special": false,
 "name": "0027.HK/HKD",
 "description": "Galaxy Entertainment Group",
 "historical_filename": "0027HKHKD",
 "pipValue": 0.01,
 "base_currency": "0027.HK",
 "quote_currency": "HKD",
 "commodities_per_contract": null,
 "tag_list": [
   "CFD_INSTRUMENTS",
   "GLOBAL_ACCOUNTS"
 ],
 "history_start_tick": "1514854800158",
 "history_start_10sec": "1537925400000",
 "history_start_60sec": "1514854800000",
 "history_start_60min": "1514854800000",
 "history_start_day": "0",
 "unit": null,

 */
