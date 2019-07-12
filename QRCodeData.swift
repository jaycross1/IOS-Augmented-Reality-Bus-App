//
//  UploadResponse.swift
//  ImageDetect


import Foundation

class QRCodeData{
    var _id: String?
    var stopid: String?
    var stopabbr: String?
    var stopname: String?
    var onstreet: String?
    var atstreet: String?
    var inservice: String?
    var bus: String?
    var direction: String?
    var bus_time: String?
    var other_stops: [OtherStop]?
    // created values for variables
    init(_id: String?,
         //these are all the initalisers variables when the page is loaded
        //when the spinner pops up it is parsing the data and sending the data into these variables
        //we then create values when we initalise them
         stopid: String?,
         stopabbr: String?,
         stopname: String?,
         onstreet: String?,
         atstreet: String?,
         inservice: String?,
         bus: String?,
         direction: String?,
         bus_time: String?,
         other_stops: [OtherStop]?) {
        self._id = _id
        self.stopid = stopid
        self.stopabbr = stopabbr
        self.stopname = stopname
        self.onstreet = onstreet
        self.atstreet = atstreet
        self.inservice = inservice
        self.bus = bus
        self.direction = direction
        self.bus_time = bus_time
        self.other_stops = other_stops
    }
    
    //created functions which parsed through a dictionary and created qr data objects.
    static func getInstance(dictionary: [String: Any]) -> QRCodeData? {
        var qrCodeData: QRCodeData?
        if let _id = dictionary["_id"] as? String,
            let stopid = dictionary["stopid"] as? String,
            let stopabbr = dictionary["stopabbr"] as? String,
            let stopname = dictionary["stopname"] as? String,
            let onstreet = dictionary["onstreet"] as? String,
            let atstreet = dictionary["atstreet"] as? String,
            let inservice = dictionary["inservice"] as? String,
            let bus = dictionary["bus"] as? String,
            let direction = dictionary["direction"] as? String,
            let bus_time = dictionary["bus_time"] as? String,
            let other_stops = dictionary["other_stops"] as? [[String: Any]] {
            let otherStops = OtherStop.getList(array: other_stops)
            qrCodeData = QRCodeData(_id: _id,
                                    stopid: stopid,
                                    stopabbr: stopabbr,
                                    stopname: stopname,
                                    onstreet: onstreet,
                                    atstreet: atstreet,
                                    inservice: inservice,
                                    bus: bus,
                                    direction: direction,
                                    bus_time: bus_time,
                                    other_stops: otherStops)
        }
        return qrCodeData
    }
    //this functions parses the array
    static func getList(array: [[String: Any]]) -> [QRCodeData]? {
        var list: [QRCodeData] = []
        for object in array {
            if let qrCodeData = QRCodeData.getInstance(dictionary: object) {
                list.append(qrCodeData)
            }
        }
        return list.count > 0 ? list : nil
        
    //checks if this has a value or not if it is equal to zero then it is nil
    }
}
// this parses the array also
class OtherStop {
    var stop: String?
    var bus_time: String?
    
    init(stop: String?, bus_time: String?) {
        self.stop = stop
        self.bus_time = bus_time
    }
    // this parses the array also
    static func getInstance(dictionary: [String: Any]) -> OtherStop? {
        var otherStop: OtherStop?
        if let stop = dictionary["stop"] as? String,
            let bus_time = dictionary["bus_time"] as? String {
            otherStop = OtherStop(stop: stop, bus_time: bus_time)
        }
        return otherStop
    }
    // this parses the array also
    static func getList(array: [[String: Any]]) -> [OtherStop]? {
        var list: [OtherStop] = []
        for object in array {
            if let otherStop = OtherStop.getInstance(dictionary: object) {
                list.append(otherStop)
            }
        }
        return list.count > 0 ? list : nil
    }// if it is equal to zero then it does not parse but if it is more than zero then it continues
}
